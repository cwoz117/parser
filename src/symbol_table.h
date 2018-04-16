#ifndef SYMBOL_TABLE

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
			int space_requirement;
		};
		struct arg_record{ //Used in functions, maybe progs for input args too.. prolly not implemented
			SymType type;
			struct record *next;
			char *id;
			int datatype;
			int arraydims;
		};
		struct fun_record{
			SymType type;
			struct record *next;		
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
			char *id;
			struct arg_record *arg_types;
			char *datatype;
		};


struct table * new_table();
void add_symbol(struct table *t, struct record *r);
int add_scope(struct table **t);
int delete_scope(struct table **t);
struct record *lookup(struct table *t, char *name);

void print_table(struct table *t);
void free_table(struct table *t);


struct record *new_var_record(char *id, int datatype, int arraydims, int space_requirement);
struct record *new_arg_record(char *id, int datatype, int arraydims);
struct record *new_fun_record(char *id,  struct arg_record *args);
struct record *new_con_record(char *cid, struct arg_record *arg_types, char *datatype);


#endif
