#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *args[]){
	struct table *t = new_table();
	char *a = malloc(sizeof(char)*6);
	char *b = malloc(sizeof(char)*5);
	a= "hello";
	b= "Daka";


	// Inserting a Record
	insert_symbol(t, a, 0);
	print_table(t);

	// Adding a Scope
	add_scope(&t);
	insert_symbol(t, b, 2);
	print_table(t);

	// Lookup a record
	struct record r = lookup(t, "hello");
	struct record s = lookup(t, "Daka");
	printf("r = %d, s = %d\n", r.type, s.type);

	// Deleting a Scope
	delete_scope(&t);
	print_table(t);
	
	// Freeing the table
	free_table(t);

	return 0;
}
