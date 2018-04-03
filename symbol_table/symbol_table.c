#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"

struct symbol{
	int type; // INT REAL BOOL CHAR ID Error:-1
	char *name;
	struct symbol *symbols;
};

struct table{
	struct symbol *symbols;
	struct table *tables;

};

void print_symbols(struct symbol *s){
	if (s){
		printf("(%s, %d) ", s->name, s->type);
		print_symbols(s->symbols);
	}
}

void print_table_help(struct table *t, int i){
	if (t){
		printf("%d | ", i++);
		print_symbols(t->symbols);
		printf("\n");
		print_table_help(t->tables, i);
	}
}

void print_table(struct table *t){
	printf("-----SYMBOL TABLE-----\n");
	print_table_help(t, 0);
	printf("----------------------\n");
}

struct record find_record(struct symbol *symbol, char *name){
	struct record r = {.type = -1, .name = NULL};
	if (symbol){
		if (strcmp(name, symbol->name) == 0){
			r.type = symbol->type;
			r.name = symbol->name;
		} else
			r = find_record(symbol->symbols, name);
	}
	return r;
}

struct record lookup(struct table *t, char *name){
	struct record r = {.type = -1, .name = NULL};
	if (t){
		r = find_record(t->symbols, name);
		if (r.type == -1)
			r = lookup(t->tables, name);
	}
	return r;
}

struct table * new_table(){
	struct table *t = malloc(sizeof(struct table));
	if (!t)
		return NULL;
	t->symbols = NULL;
	t->tables = NULL;
	return t;
}

void free_symbols(struct symbol *s){
	if(s){
		free_symbols(s->symbols);
		free(s);
	}
}

void free_table(struct table *t){
	if(t){
		free_symbols(t->symbols);
		free_table(t->tables);
		free(t);
	}
}


int insert_symbol(struct table *t, char *name, int type){
	struct symbol *s = malloc(sizeof(struct symbol));
	if (!s)
		return -1;
	s->name = name;
	s->type = type;
	s->symbols = NULL;

	struct symbol *tmp = t->symbols;
	t->symbols = s;
	t->symbols->symbols = tmp;
	return 0;
}

int add_scope(struct table **t){
	struct table *tmp = malloc(sizeof(struct table));
	if (!tmp)
		return -1;

	tmp->tables = *t;
	*t= tmp;
	return 0;
}

int delete_scope(struct table **t){
	struct table *tmp = *t;
	*t = (*t)->tables;
	free(tmp);
	return 0;
}



