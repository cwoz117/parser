#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"

struct table * new_table(){
	struct table *t = malloc(sizeof(struct table));
	if (!t){
		printf("Table is null\n");
		return NULL;
	}
	t->symbols = NULL;
	t->tables = NULL;
	return t;
}

struct record *lookup_help(struct record *symbol, char *name){
	if (!symbol)
		return NULL;
	if (strcmp(name, symbol->id) == 0)
		return symbol;
 	else
		return lookup_help(symbol->next, name);
}
struct record *lookup(struct table *t, char *name){
	struct record *r = NULL;
	if (t){
		r = lookup_help(t->symbols, name);
		if (!r)
			r = lookup(t->tables, name);
	}
	return r;
}


void add_symbol_help(struct record *list, struct record *symbol){
	if(!(list->next))
		list->next = symbol;
	else
		add_symbol_help(list->next, symbol);
};
void add_symbol(struct table *t, struct record *symbol){
	if (!t)
		exit(1);
	if (!(t->symbols))
		t->symbols = symbol;
	else
		add_symbol_help(t->symbols, symbol);
};


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

void free_symbols(struct record *s){
	if(s){
		free_symbols(s->next);
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

void print_symbols(struct record *s){
	if (s){
		switch(s->type){
			case(sVAR):
				printf("(%s, %d)", s->id, s->type);
				break;
			case(sARG):
				printf("%s", s->id);

				break;
			case(sFUN):
				printf("%s", s->id);

				break;
			case(sDAT):
				printf("%s", s->id);

				break;
			case(sCON):
				printf("%s", s->id);

				break;
		};
		print_symbols(s->next);
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

struct record *new_var_record(char *id, int datatype, int arraydims, int space_requirement){
	struct var_record *r = malloc(sizeof(struct var_record));
	if (!r)
		return NULL;
	r->type = sVAR;
	r->next = NULL;
	r->id = id;
	r->datatype = datatype;
	r->arraydims = arraydims;
	r->space_requirement = space_requirement;
	return (struct record *)r;
}
struct record *new_arg_record(char *id, int datatype, int arraydims){
	struct arg_record *r = malloc(sizeof(struct arg_record));
	if (!r)
		return NULL;
	r->type = sARG;
	r->next = NULL;
	r->id = id;
	r->datatype = datatype;
	r->arraydims = arraydims;
	return (struct record *)r;
};
struct record *new_fun_record(char *id,  struct arg_record *args){
	struct fun_record *r = malloc(sizeof(struct fun_record));
	if (!r)
		return NULL;
	r->type = sFUN;
	r->next = NULL;
	r->id = id;
	r->args = args;
	return (struct record *)r;
};
struct record *new_con_record(char *cid, struct arg_record *arg_types, char *datatype){
	struct con_record *r = malloc(sizeof(struct con_record));
	if (!r)
		return NULL;
	r->type = sCON;
	r->next = NULL;
	r->id = cid;
	r->arg_types = arg_types;
	return (struct record *)r;
};














