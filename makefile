cc = gcc
lexer = flex
std = c17
flags = -Wall -Werror

parse: grammar.lex grammar.y ast.h
	bison -d gramar.y
	flex grammar.lex

tokenize: lex.yy.c
	$(cc) -std=$(std) $(flags) lex.yy.c -o tokenize


symbol_table_test: symbol_table/symbol_table.h symbol_table/symbol_table.c symbol_table/symbol_table_test.c
	$(cc) -std=$(std) $(flags) symbol_table/symbol_table.h symbol_table/symbol_table.c

clean: 
	rm -f lex.yy.c a.out
