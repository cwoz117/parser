#ifndef AST_H

#include <stdbool.h>

extern int yylineno;
void yyerror(char *s);

union Data {
	int ival;
	double rval;
	bool bval;
	char cval;
	char * id;
};

struct ast{ 
	int nodetype; //0
	struct ast *l;
	struct ast *r;
};

struct declaration {//1
	int nodetype;
	int declaredtype; // Symbol Table inc
	char *name;
	struct ast *array_dimensions;
};

struct ast *new_ast(struct ast *l, struct ast *r);
struct ast *new_declaration(struct ast *declaration, struct ast *declarations);
void free_ast(struct ast *a);
void print_ast(struct ast *a);
#endif





// var x, y[4]: int 	-->	 	(x, [2][3], int) -> (y, [4], int) -> NULL
