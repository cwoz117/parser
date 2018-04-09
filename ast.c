#include "ast.h"

void *mal_node(int size, Nodetype nodetype){
	void * a = malloc(size);
	if(!a){
		yyerror("Ran out of space\n");
		exit(1);
	}
	((struct ast_one *)a)->nodetype = nodetype;
	return a;
}


struct ast *new_one( Nodetype t, struct ast *b){
	struct ast_one *a = mal_node(sizeof(struct ast_one), t);
	a->a = b;
	return (struct ast *)a;
};
struct ast *new_two( Nodetype t, struct ast *l, struct ast *r){
	struct ast_two *a = mal_node(sizeof(struct ast_two), t);
	a->l = l;
	a->r = r;
	return (struct ast *)a;
};
struct ast *new_three( Nodetype t, struct ast *l, struct ast *m, struct ast *r){
	struct ast_three *a = mal_node(sizeof(struct ast_three), t);
	a->l = l;
	a->m = m;
	a->r = r;
	return (struct ast *)a;
};
struct ast *new_four( Nodetype t, struct ast *l, struct ast *m, struct ast *r, struct ast *s){
	struct ast_four *a = mal_node(sizeof(struct ast_four), t);
	a->l = l;
	a->m = m;
	a->r = r;
	a->s = s;
	return (struct ast *)a;
};

struct ast *new_sval(Nodetype n, char *s){
	struct ast_sval *a = mal_node(sizeof(struct ast_sval), n);
	a->s = s;
	return (struct ast *)a;
};
struct ast *new_ival(Nodetype n, int i){
	struct ast_ival *a = mal_node(sizeof(struct ast_ival), n);
	a->i = i;
	return (struct ast *)a;
};
struct ast *new_rval(Nodetype n, double d){
	struct ast_rval *a = mal_node(sizeof(struct ast_rval), n);
	a->d = d;
	return (struct ast *)a;
};

struct ast *new_bval(Nodetype n, bool b){
	struct ast_bval *a = mal_node(sizeof(struct ast_bval), n);
	a->b = b;
	return (struct ast *)a;
};
struct ast *new_cval(Nodetype n, char c){
	struct ast_cval *a = mal_node(sizeof(struct ast_cval), n);
	a->c = c;
	return (struct ast *)a;
};

// IN THIS BOX BITCHEZ

void free_ast(struct ast *a){

};


void print_ast(struct ast *a){
};
