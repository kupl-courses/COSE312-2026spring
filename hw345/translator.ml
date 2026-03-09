open G

exception Not_implemented 

let tmp_index = ref 0
let label_index = ref 1
let new_temp() = tmp_index := !tmp_index + 1; ".t" ^ (string_of_int !tmp_index)
let new_label() = label_index := !label_index + 1; !label_index

(*************************************)
(*          translation to T         *)
(*************************************)
 
let s2t : S.program -> T.program
=fun s -> ignore s; raise Not_implemented

(*************************************)
(*     translation from S to Cfg     *)
(*************************************)

let s2cfg : S.program -> Cfg.t 
=fun s -> ignore s; raise Not_implemented