# COSE312 Compiler Project, Korea University

The goal of this project is to implement a translator, a semantic analyzer, and an optimizer for the S language.
The source language ("S") and target languages ("G" and "T") are defined in lecture slides.

This package includes the following files:
- [lexer.mll]: the lexer specification for ocamllex
- [parser.mly]: the parser specification for ocamlyacc
- [s.ml]: abstract syntax and interpreter definitions for the S language
- [t.ml]: abstract syntax and interpreter definitions for the T language
- [g.ml]: control-flow graph ("G") and interpreter 
- [translator.ml]: the translators that compile S to T and G
- [analyzer.ml]: the semantic analyzer for checking the absence of runtime errors in S 
- [optimizer.ml]: an optimizer that translates a T program to an efficient T program

Your job is to complete the implementation of the translator, the analyzer, and the optimizer:
- HW3: Implement the translator from S to T and G in [translator.ml]
- HW4: Implement the semantic analyzer in [analyzer.ml]
- HW5: Implement an optimizer for T in [optimizer.ml]

Regarding the optimizer, try to do your best effort. The score will be based on the
correctness (i.e., semantics-preserveness) of the optimizer and the quality of the
final code (i.e., the reduction in the number of instructions being executed).

# How to run
```
$ Make
$ dune exec -- ./main.exe test/t0.s
```

If everything is properly done, you will get the following output:
```
== S ==                             
{
int x;
x = 0;
print x + 1;
}
== translating S to CFG ==
cfg has been saved in cfg.dot
== translating S to T ==
0 : x = 0
0 : .t1 = 0
0 : x = .t1
0 : .t3 = x
0 : .t4 = 1
0 : .t2 = .t3 + .t4
0 : write .t2
0 : HALT
== semantic analyzer ==
no error detected
== executing S ==
1
== executing CFG ==
1
== executing T ==
1
The number of instructions executed : 7
== optimized T ==
0 : x = 0
0 : .t4 = 1
0 : .t2 = x + .t4
0 : write .t2
0 : HALT
== executing T ==
1
The number of instructions executed : 4
```
You can visualize the cfg as follows:
```
dot -Tpng cfg.dot > cfg.png
open cfg.png 
```
