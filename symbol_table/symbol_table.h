#ifndef SYMBOL_TABLE

struct table;

struct record{
	int type;
	char * name;
};


int insert_symbol(struct table *t,char *name, int type);
int add_scope(struct table **t);
int delete_scope(struct table **t);
void free_table(struct table *t);
void print_table(struct table *t);
struct record lookup(struct table *t, char *name);
struct table * new_table();



#endif
