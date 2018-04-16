#include "../../src/headers/symbol_table.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *args[]){
	struct table *t = new_table();

	char *a = malloc(sizeof(char)*6);
	char *b = malloc(sizeof(char)*5);
	a= "hello";
	b= "Daka";
	
	print_table(t);

	// Inserting a Record
	struct record *r = new_var_record(a, 'i', 0, 4);
	add_symbol(t, r);
	print_table(t);


	// Adding a Scope
	add_scope(&t);
	struct record *v = new_var_record(b, 'i', 1, 8);
	add_symbol(t, v);
	print_table(t);

	// Lookup a record
	struct record *d = lookup(t, "hello");
	struct record *e = lookup(t, "Daka");
	printf("d = %s, e = %s\n", d->id, e->id);

	// Deleting a Scope
	delete_scope(&t);
	print_table(t);
	
	// Freeing the table
	free_table(t);
	return 0;
}
