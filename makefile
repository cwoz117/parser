cc = gcc
archiver = ar
lexer = flex
std = c11
flags = -Wall -Werror

symbol = symbol_table/symbol_table
libsymbol = libsymbol_table.a
libir = libir.a


parse: 
	bison -d grammar.y
	flex grammar.l grammar.tab.h
	$(cc) -o parse ast.h ast.c grammar.tab.c lex.yy.c

tokenize: lex.yy.c
	$(cc) -std=$(std) $(flags) lex.yy.c -o tokenize

intermediate_representation_library: ir.o
	$(archiver) -cvq $(libir) ir.o
	mv ir.o ir/ir.o
	mv $(libir) ir/$(libir)

symbol_table_library: symbol_table.o
	$(archiver) -cvq $(libsymbol) symbol_table.o
	mv symbol_table.o symbol_table/symbol_table.o
	mv $(libsymbol) symbol_table/$(libsymbol)

symbol_table.o: $(symbol).h $(symbol).c
	$(cc) -std=$(std) $(flags) $(symbol).h $(symbol).c -c

test_symbol_table: $(symbol).h $(symbol).c $(symbol)_test.c
	$(cc) -std=$(std) $(flags) $(symbol).h $(symbol).c $(symbol)_test.c -o symbol_test

clean: 
	rm -f lex.yy.c a.out *.gch *.o $(libsymbol) symbol_test
	rm -f grammar.tab.c lex.yy.c grammar.tab.h parse
