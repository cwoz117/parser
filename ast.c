#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ast.h"

struct ast *
new_ast(int type, struct ast *l, struct ast *r){
	struct ast *a = malloc(sizeof(struct ast));
	if (!a){
		yyerror("out of space\n");
		exit(1);
	}
	a->type = type;
	a->left = l;
	a->right = r;
	return a;
}

void
free_ast(struct ast *a){
	if (!a->left)
		free_ast(a->left);
	if (!a->right)
		free_ast(a->right);
	free(a);
}
