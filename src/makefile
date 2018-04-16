cc = gcc
archiver = ar
lexer = flex
flags =-std=c11 -Wall -Werror

###########################
# Build the Parser
###########################
parse: lex sym ir
	gcc -o parse ast.c grammar.tab.c lex.yy.c -L../bin -lir -lsym
	mv parse ../bin/parse

###########################
# Build Libraries
###########################
ir: ir.o
	ar -cvq libir.a ir.o;
	rm ir.o
	mv libir.a ../bin/libir.a
ir.o: 
	gcc $(flags) ir.c -c


sym: symbol_table.o
	ar -cvq libsym.a symbol_table.o; 
	rm symbol_table.o;
	mv libsym.a ../bin/libsym.a
symbol_table.o:
	gcc $(flags) symbol_table.c -c


lex: grammar
	flex grammar.l
grammar:
	bison -d grammar.y

###########################
# Test Code
###########################
symtest:
	gcc -$(flags) symbol_table.c ../tests/unit/symbol_table_test.c -o symbol_test
	mv symbol_test ../bin/symbol_test


###########################
# Clean any current builds
###########################
clean: 
	rm -rf ../bin/*
	rm -rf grammar.tab.h
	rm -rf grammar.tab.c
	rm -rf lex.yy.c
