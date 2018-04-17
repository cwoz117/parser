#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol_table.h"
#include "ast.h"

/*******************************
/ Table Constructor
********************************/
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

/*******************************
/ Record Constructors
********************************/
struct record *new_var_record(struct var *a){
	struct var_record *r = malloc(sizeof(struct var_record));
	if (!r)
		return NULL;
	
	r->type = sVAR;
	r->next = NULL;
	r->id = a->id;
	r->datatype = a->type;
	r->arraydims = a->num_dimensions;
	return (struct record *)r;
}
struct arg_record *new_arg_record(struct ast *a){
	if (!a)
		return NULL;
	struct arg_record *r = malloc(sizeof(struct arg_record));
	if (!r)
		return NULL;
	
	struct ast_three *tmp = (struct ast_three *)a;
	r->type = sARG;
	r->next = new_arg_record(a->r);
	r->id = ((struct ast_sval *)(tmp->l))->s;
	r->datatype = ((struct ast_ival *)(tmp->l))->i;
	r->arraydims = count(tmp->m);
	return r;
};
struct record *new_fun_record(struct fun *a){
	struct fun_record *r = malloc(sizeof(struct fun_record));
	if (!r)
		return NULL;
	r->type = sFUN;
	r->next = NULL;
	r->returntype = a->type;
	r->id = a->id;
	r->args = new_arg_record(a->param_list);
	return (struct record *)r;
};
struct record *new_con_record(struct ast *a, char *defined_type){
	struct con_record *r = malloc(sizeof(struct con_record));
	if (!r)
		return NULL;
	r->type = sCON;
	r->next = new_con_record(a->r, defined_type);
	r->con_name = ((struct ast_sval *)(a->l))->s;
	r->argument_types = new_arg_record(a->l->r);
	r->user_defined_datatype = defined_type;
	return (struct record *)r;
};
struct record *new_data_record(struct data *d){
	struct data_record *r = malloc(sizeof(struct data_record));
	if (!r)
		exit(1);
	r->type = sDAT;
	r->next = new_con_record(d->cons_declarations, d->id);
	r->id = d->id;
	return (struct record *)r;
};

/*******************************
/ Symbol Insert
********************************/
void add_symbol_help(struct record *list, struct record *symbol){
	if(!(list->next))
		list->next = symbol;
	else
		add_symbol_help(list->next, symbol);
};
void add_symbol(struct table *t, struct ast *a){
	if (!t)
		exit(1);

	struct record *r = NULL;
	switch(a->nodetype){
		case(nVAR_DECLARATION):
			r = new_var_record((struct var *)a);
			break;
		case(nFUN_DECLARATION):
			r = new_fun_record((struct fun *)a);
			break;
		case(nDATA_DECLARATION):
			r = new_data_record((struct data *)a);
			break;
		default:
			yyerror("Undefined nodetype appeared in symbol_table.c:add_symbol():105\n");
	};
	if (!(t->symbols))
		t->symbols = r;
	else
		add_symbol_help(t->symbols, r);
};

/*******************************
/ Lookup
********************************/
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

/*******************************
/ Scope
********************************/
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

/*******************************
/ Print
********************************/
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

/*******************************
/ Cleanup
********************************/
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
