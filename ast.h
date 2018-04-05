#ifndef AST_H

#include <stdbool.h>

extern int yylineno;
void yyerror(char *s);

struct ast{ 
	int nodetype; //0
	struct ast *l;
	struct ast *r;
};

struct ast_variable {//1
	int nodetype;
	int declaredtype; // Symbol Table inc
	char *name;
	struct ast *array_dimensions;
};

struct type_container{//2  TODO DELETE AND STUFF... WHEREVER U SEE A CASE
	int nodetype;
	int type;
};
struct id_container{//3 TODO DELETE AND STUFF... WHEREVER U SEE A CASE
	int nodetype;
	char * id;
};
struct ast *new_ast(struct ast *l, struct ast *r);
struct ast *new_declarations(struct ast *declaration, struct ast *declarations);
struct ast *new_type(int type);
struct ast *new_id(char *id);
void free_ast(struct ast *a);
void print_ast(struct ast *a);
#endif
