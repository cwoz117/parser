#ifndef AST_H

#include <stdbool.h>

void yyerror(char *s);
extern int yylineno;


struct prog{
	int type;
	struct ast *block;
};

struct ast{
	int type;
	union{
		char *sval;
		int ival;
		float rval;
		bool bval;
	} attribute;
	struct ast *left;
	struct ast *right;
};



struct ast *new_ast(int type, void *attribute, struct ast *l, struct ast *r);
struct ast *new_prog(int type, NULL, struct ast *block);



void free_ast(struct ast *a);
#endif
