open S 

type id = string 

module type Node = sig
  type instr = 
  | I_alloc of id * int 
  | I_assign of lv * exp 
  | I_assume of exp 
  | I_skip
  | I_read of id 
  | I_print of exp 
  type t 
  val create_alloc : id -> int -> t  
  val create_assign : lv -> exp -> t 
  val create_assume : exp -> t 
  val create_skip : unit -> t 
  val create_read : id -> t 
  val create_print : exp -> t 
  val get_nodeid : t -> int 
  val get_instr : t -> instr 
  val to_string : t -> string
  val compare : t -> t -> int   
end

module Node : Node = struct
  type instr = 
  | I_alloc of id * int 
  | I_assign of lv * exp 
  | I_assume of exp 
  | I_skip
  | I_read of id 
  | I_print of exp 
  type t = int * instr
  let new_id : unit -> int =
    let id =  ref 0 in 
      fun _ -> (id := !id + 1; !id)
  let create_alloc x n = (new_id(), I_alloc (x, n))
  let create_assign x a = (new_id(), I_assign (x, a))
  let create_assume b = (new_id(), I_assume b)
  let create_skip () = (new_id(), I_skip)
  let create_read x = (new_id(), I_read x)
  let create_print e = (new_id(), I_print e)
  let get_nodeid (id, _) = id
  let get_instr (_, instr) = instr
  let compare = Stdlib.compare
  let to_string n = 
    match n with
    | (id, I_alloc (x, n)) -> string_of_int id ^ ": " ^ " " ^ x ^ " := alloc " ^ string_of_int n
    | (id, I_assign (lv, e)) -> string_of_int id ^ ": " ^ " " ^ string_of_lv lv ^ " := " ^ string_of_exp e
    | (id, I_assume b) -> string_of_int id ^ ": " ^ "assume"  ^ " " ^ string_of_exp b
    | (id, I_skip) -> string_of_int id ^ ": " ^ "skip"
    | (id, I_read x) -> string_of_int id ^ ": " ^ "read " ^ x 
    | (id, I_print e) -> string_of_int id ^ ": " ^ "print " ^ string_of_exp e
end

module NodeSet = Set.Make(Node)
module NodeMap = Map.Make(Node)

module type Cfg = sig 
  type t 
  val empty : t 
  val nodesof : t -> Node.t list 
  val succs : Node.t -> t -> NodeSet.t
  val preds : Node.t -> t -> NodeSet.t
  val add_node : Node.t -> t -> t
  val add_nodes : Node.t list -> t -> t
  val add_edge : Node.t -> Node.t -> t -> t
  val add_loophead : Node.t -> t -> t 
  val is_loophead : Node.t -> t -> bool 
  val get_entry : t -> Node.t 
  val get_exit : t -> Node.t
  val remove_node : Node.t -> t -> t 
  val remove_edge : Node.t -> Node.t -> t -> t 
  val remove_unnecessary_skips : t -> t 
  val print : t -> unit 
  val dot : t -> unit
end 

module Cfg : Cfg = struct
  type t = { 
    nodes : NodeSet.t; 
    succs : NodeSet.t NodeMap.t; 
    preds : NodeSet.t NodeMap.t; 
    loopheads : NodeSet.t 
  }
  let empty = { 
    nodes = NodeSet.empty; 
    succs = NodeMap.empty; 
    preds = NodeMap.empty; 
    loopheads = NodeSet.empty 
  }

  let nodesof : t -> Node.t list 
  =fun t -> NodeSet.elements t.nodes

  let succs : Node.t -> t -> NodeSet.t
  =fun n g -> try NodeMap.find n g.succs with _ -> NodeSet.empty

  let preds : Node.t -> t -> NodeSet.t
  =fun n g -> try NodeMap.find n g.preds with _ -> NodeSet.empty

  let add_node : Node.t -> t -> t
  =fun n g -> { g with nodes = NodeSet.add n g.nodes }

  let add_nodes : Node.t list -> t -> t
  =fun ns g -> g |> (List.fold_right add_node ns)

  let add_edge : Node.t -> Node.t -> t -> t
  =fun n1 n2 g -> 
    g 
    |> add_nodes [n1;n2] 
    |> (fun g -> { g with succs = NodeMap.add n1 (NodeSet.add n2 (succs n1 g)) g.succs }) 
    |> (fun g -> { g with preds = NodeMap.add n2 (NodeSet.add n1 (preds n2 g)) g.preds }) 

  let add_loophead : Node.t -> t -> t 
  =fun n g -> {g with loopheads = NodeSet.add n g.loopheads }

  let is_loophead : Node.t -> t -> bool 
  =fun n g -> NodeSet.mem n g.loopheads     

  let get_entry : t -> Node.t 
  =fun g -> 
    let entries = 
      NodeSet.fold (fun n res -> 
        if NodeSet.is_empty (preds n g) then n::res else res 
      ) g.nodes [] in 
      assert (List.length entries = 1); 
      List.hd entries 

  let get_exit : t -> Node.t 
  =fun g -> 
    let exits = 
      NodeSet.fold (fun n res -> 
        if NodeSet.is_empty (succs n g) then n::res else res 
      ) g.nodes [] in 
      assert (List.length exits = 1); 
      List.hd exits 

  let remove_edge : Node.t -> Node.t -> t -> t 
  =fun n1 n2 g -> 
    g 
    |> (fun g -> { g with succs = NodeMap.add n1 (NodeSet.remove n2 (succs n1 g)) g.succs }) 
    |> (fun g -> { g with preds = NodeMap.add n2 (NodeSet.remove n1 (preds n2 g)) g.preds }) 

  let remove_succs : Node.t -> t -> t 
  =fun n g -> 
    g 
    |> NodeSet.fold (remove_edge n) (succs n g)

  let remove_preds : Node.t -> t -> t 
  =fun n g -> 
    g 
    |> NodeSet.fold (fun p -> remove_edge p n) (preds n g)

  let remove_node : Node.t -> t -> t 
  =fun n g -> 
    g 
    |> remove_succs n 
    |> remove_preds n 
    |> (fun g -> { g with nodes = NodeSet.remove n g.nodes })
    
  let remove_unnecessary_skips : t -> t 
  =fun g -> 
    let rec fixpoint g = 
      let g' = 
        list_fold (fun n g -> 
          match Node.get_instr n with 
          | Node.I_skip -> 
            if NodeSet.cardinal (preds n g) = 1 && 
               NodeSet.cardinal (succs n g) = 1 then 
              let pred = NodeSet.choose (preds n g) in 
              let succ = NodeSet.choose (succs n g) in 
                remove_node n g 
                |> remove_edge pred n 
                |> remove_edge n succ
                |> add_edge pred succ 
            else g
          | _ -> g) (nodesof g) g in 
        if g = g' then g 
        else fixpoint g' in 
    fixpoint g       

  let print g = 
    print_endline "** Nodes **";
    NodeSet.iter (fun n -> 
      print_endline (Node.to_string n)
    ) g.nodes;
    print_endline "";
    print_endline "** Edges **";
    NodeMap.iter (fun n succs -> 
      NodeSet.iter (fun s ->
        print_endline (string_of_int (Node.get_nodeid n) ^ " -> " ^ string_of_int (Node.get_nodeid s))
      ) succs
    ) g.succs

  let dot g = 
    let oc = open_out "cfg.dot" in 
    Printf.fprintf oc "digraph G {";
    NodeSet.iter (fun n -> 
      Printf.fprintf oc "%s" (string_of_int (Node.get_nodeid n) ^ " ");
      Printf.fprintf oc "%s" ("[label=\"" ^ Node.to_string n ^ "\"]");
      Printf.fprintf oc "\n"
    ) g.nodes;
    NodeMap.iter (fun n succs -> 
      NodeSet.iter (fun s ->
        Printf.fprintf oc "%s\n" (string_of_int (Node.get_nodeid n) ^ " -> " ^ string_of_int (Node.get_nodeid s))
      ) succs
    ) g.succs;
    Printf.fprintf oc "}"
end

let run_node : Node.t -> Memory.t -> Memory.t option 
=fun node mem -> 
  match Node.get_instr node with 
  | I_alloc (x, n) -> Some (Memory.alloc x n mem)
  | I_assign (lv, exp) -> Some (Memory.bind (eval_lv lv mem) (eval exp mem) mem)
  | I_assume exp -> 
    begin 
      match eval exp mem with 
      | INT 0 -> None 
      | INT _ -> Some mem 
      | _ -> raise (RuntimeErr "if: condition must be integer")
    end 
  | I_skip -> Some mem 
  | I_read x -> Some (Memory.bind (VAR x) (INT (read_int ())) mem)
  | I_print exp -> 
    begin 
      match eval exp mem with
      | INT n -> print_endline (string_of_int n); Some mem
      | _ -> raise (RuntimeErr "print: arg must be integer")
    end 

let execute_cfg : Cfg.t -> Memory.t 
=fun cfg -> 
  let init_workset = [Cfg.get_entry cfg, Memory.empty] in 
  let rec iter workset = 
    match workset with 
    | [] -> raise (Failure "Interpreter.run: empty workset")
    | (node, mem)::workset' -> 
      if node = Cfg.get_exit cfg then mem 
      else 
        begin 
          match run_node node mem with 
          | None -> iter workset'
          | Some mem' -> 
            let next =  List.map (fun s -> (s, mem')) (NodeSet.elements (Cfg.succs node cfg)) in 
              iter (next@workset') 
        end in 
  let output = iter init_workset in 
    output