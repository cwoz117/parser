# parser
CPSC 411 Minisculus parser (M++ Specification)
This program is designed to pretty-print an Abstract Syntax Tree for Assignment #3

## How to use Parse

1. Get the source code (dl/git)
```
[user@vagrant]$ git clone https://github.com/cwoz117
[user@vagrant]$ cd parser/
[user@vagrant parser]$
```
2. Build the software using Make
```
[user@vagrant parser]$ make
bison -d grammar.y
flex grammar.l grammar.tab.h
gcc -o parse ast.h ast.c grammar.tab.c lex.yy.c
[user@vagrant parser]$
```
3. Pipe in any M++ Specification code to see the pretty-printed Abstract Syntax Tree:
```
[vagrant@localhost parser]$ ./parse < tests/test6.M

prog
        Var: x:INT
        Var: y:INT
        Fun: exp(b:INT):INT
                Var: z:INT
                IF b == 0 THEN ASSIGN 1 into z ELSE ASSIGN (x * exp((b - 1))) into z
                return: z
        READ x
        READ y
        PRINT exp(y)
[vagrant@localhost parser]$ ./parse < tests/test8.M

prog
        Var: n:INT
        READ n
        {
                Var: a[n]:REAL
                ASSIGN 0 into n
                WHILE n < SIZE(a) DO {
                        READ a[n]
                        ASSIGN (n + 1) into n
                }
                ASSIGN 0 into n
                WHILE n < SIZE(a) DO {
                        PRINT a([n])
                        ASSIGN (n + 1) into n
                }
        }
[vagrant@localhost parser]$

```

## About Syntax Errors
This will identify simple syntax errors, but will exit instead of continuing.. this means you will only get one message at a time.
```
[vagrant@localhost parser]$ ./parse < tests/test1_BAD.M
Line   1: syntax error

prog
[vagrant@localhost parser]$
```
NOTE: test1_BAD.M isn't saved, feel free to make a change to the syntax and make your own bugs!
