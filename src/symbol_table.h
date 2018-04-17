#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "ast.h"

typedef enum {
	sVAR, sARG, sFUN, sDAT, sCON
}SymType;

struct table{
	struct record *symbols;
	struct table *tables;

};

struct record{
	SymType type;
	struct record *next;
	char *id;
};
		struct var_record{
			SymType type;
			struct record *next;
			char *id;
			int datatype;
			int arraydims;
		};
		struct arg_record{ //Used in functions, maybe progs for input args too.. prolly not implemented
			SymType type;
			struct arg_record *next;
			char *id;
			int datatype;
			int arraydims;
		};
		struct fun_record{
			SymType type;
			struct record *next;
			int returntype;
			char *id;
			struct arg_record *args;
		};
		struct data_record{
			SymType type;
			struct record *next;
			char *id;
		};
		struct con_record{
			SymType type;
			struct record *next;
			char *con_name;
			struct arg_record *argument_types;
			char *user_defined_datatype;
		};


struct table * new_table();

void add_symbol(struct table *t, struct ast *a);
int add_scope(struct table **t);
int delete_scope(struct table **t);
struct record *lookup(struct table *t, char *name);

void print_table(struct table *t);
void free_table(struct table *t);

#endif
