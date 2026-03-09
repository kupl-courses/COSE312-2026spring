module Translator = Translator
module Analyzer = Analyzer

let read_s () = 
	let file_channel = 	
		if Array.length Sys.argv != 2 then 
			raise (Failure "No input is given")
		else 
			Stdlib.open_in (Sys.argv.(1)) in
	let lexbuf = Lexing.from_channel file_channel in
	let s_pgm = Parser.program Lexer.start lexbuf in
		print_endline "== S =="; 
		S.pp s_pgm; 
		s_pgm  

let analyze (s_pgm, cfg, t_pgm) = 
	print_endline "== semantic analyzer ==";
	let res = Analyzer.analyze cfg in 
	let _ = 
		if res 
		then print_endline "no error detected"
		else print_endline "error detected; aborted" in 
		if res then (s_pgm, cfg, t_pgm )
		else (exit 1)

let run_s (s_pgm, cfg, t_pgm) = 
	print_endline "== executing S ==";
	S.execute s_pgm; 
	(s_pgm, cfg, t_pgm)

let translate s_pgm = 
	let _ = print_endline "== translating S to CFG ==" in 
	let cfg = Translator.s2cfg s_pgm in 
	let _ = 
		G.Cfg.dot cfg; 
		print_endline "cfg has been saved in cfg.dot" in
	let _ = print_endline "== translating S to T ==" in 
	let t_pgm = Translator.s2t s_pgm in
	let _ = T.pp t_pgm in
	  (s_pgm, cfg, t_pgm)

let run_g (s_pgm, cfg, t_pgm) = 
	print_endline "== executing CFG ==";
	ignore (G.execute_cfg cfg);
	(s_pgm, cfg, t_pgm) 

let run_t (s_pgm, cfg, t_pgm) = 
	print_endline "== executing T ==";
	ignore (T.execute t_pgm); 
	(s_pgm, cfg, t_pgm)

let optimize_t (s_pgm, cfg, t_pgm) = 
	let t_opt = Optimizer.optimize t_pgm in 
	print_endline "== optimized T ==";
	T.pp t_opt; 
	(s_pgm, cfg, t_opt )

let main () =
	() 
	|> read_s
	|> translate
	|> analyze
	|> run_s
	|> run_g 
	|> run_t 
	|> optimize_t 
	|> run_t 

let _ = main ()
