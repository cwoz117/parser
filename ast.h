#ifndef AST_H

#include <stdbool.h>
extern int yylex();
extern int yyerror(char *c);
extern int yyleng;
extern char *yytext();


/* Node Types
	1 - Program
	2 - declaration
	3 - var specs
	4 - var spec
   */
struct ast{ // p, d, i
	int type;
	struct ast *left;
	struct ast *right;
};

struct var { // v
	int type;
	int var_type;
	char *name;
	int *array; //Dynamic array size.
};

struct id {
	int type;
	char *ident;
	struct ast *array_dimensions;
};

struct ast *new_ast(int type, struct ast *l, struct ast *r);
struct ast *new_var(int type, struct ast *var_specs, int var_type);
struct ast *new_id(int type, char *ident, struct ast *array_dimension);
void free_ast(struct ast *a);
#endif





// var x, y[4]: int 	-->	 	(x, [2][3], int) -> (y, [4], int) -> NULL
