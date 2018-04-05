#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ast.h"

void *mal_node(int size, int nodetype){
	void * a = malloc(size);
	if(!a){
		yyerror("Ran out of space\n");
		exit(1);
	}
	(struct ast a)->nodetype = nodetype;
}

// GENERIC AST
struct ast *new_ast(struct ast *l, struct ast *r){
	struct ast *a = mal_node(sizeof(struct ast));
	a->type = 0;
	a->left = l;
	a->right = r;
	return a;
}

// DECLARATION
struct ast * new_type(int type){
	struct type_container *t = mal_node(sizeof(struct type_container), 2);
	t->type = t;
	return t;
}

struct ast * get_declarations(struct ast *a){
	int type = (struct type_container *(a->l))->type;
	decls->r = NULL;
	struct ast *out = decls;

	//Sift through var_specs for the good stuff
	while(in){
		out->l = mal_node(sizeof(struct ast_variable), 1);
		out->l->declaredtype = a->l;
		out->l->name = in->l->l;
		out->l->array_dimensions = in->l->r;	
		
		in = in->r;
		if(in){
			out->r = mal_node(sizeof(strict ast), 0);
			out = out->r;
			out->r = NULL;
			out->l = NULL;
		}
	}
	return decls;
}

struct ast *new_declarations(struct ast *declaration, struct ast *declarations){
	struct ast *d = get_declarations(struct ast *declaration);
	
	struct ast *ds = NULL;
	if(declarations)
		ds = new_declaration(declarations->l, declarations->r);

	struct ast *tmp = d;
	while(d->r)
		tmp = d->r;
	d->r = ds;
	
	return d;
}


// FREE AST
void free_ast(struct ast *a){
	if(a){
		switch(a->nodetype){
			case 0:
				free_ast(a->l);
				free_ast(a->r);
				free(a);
				break;
			case 1;
				free_ast(((struct ast_variable *)a)->declarations);
				free_ast(a);
				break;
		}
	}
}

// PRINT THE AST
void print_ast(struct ast *a){
	if(a){
		printf("TB Fuckin' D\n");
	}
}


/*




fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR {} ;

fun_block:
	declarations fun_body {};

param_list:
	LPAR parameters RPAR {};

*/
