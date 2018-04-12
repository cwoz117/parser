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
struct ast *new_ast( Nodetype t, struct ast *l, struct ast *r){
	struct ast *a = mal_node(sizeof(struct ast), t);
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


struct ast *make_vars(struct ast *var_spec, struct ast *type){
	struct var *v = mal_node(sizeof(struct var), nVAR_DECLARATION);
	v->type = ((struct ast_ival *)type)->i;
	v->id = ((struct ast_sval *)(var_spec->l))->s;
	v->array_dimensions = var_spec->r;
	
	return (struct ast *)v;
};
struct ast *new_var_declaration(struct ast *var_specs, struct ast *type){
	if (!var_specs)
		return NULL;
	struct ast *vars = mal_node(sizeof(struct ast), nVAR_SPECS);
	vars->l = make_vars(var_specs->l, type);
	vars->r = new_var_declaration(var_specs->r, type);
	return vars;
};


struct ast *new_function(Nodetype n, struct ast *id, struct ast *param_list, 
						 struct ast *type, struct ast *fun_block){
	struct fun *f = mal_node(sizeof(struct fun), nFUN_DECLARATION);

	f->id = ((struct ast_sval *)id)->s;
	f->type = ((struct ast_ival *)type)->i;
	f->param_list = param_list;
	f->fun_block = fun_block;
	return (struct ast *)f;
};


struct ast *new_data(char *id, struct ast *cons_declarations){
	struct data *d = mal_node(sizeof(struct data), nDATA_DECLARATION);
	d->id = id;
	d->cons_declarations = cons_declarations;
	return (struct ast *)d;
};


struct ast *new_stmt(Nodetype n, struct ast *l, struct ast *m, struct ast *r){
	struct ast_three *s = mal_node(sizeof(struct ast_three), n);
	s->l = l;
	s->m = m;
	s->r = r;	
	return (struct ast *)s;
};

// IN THIS BOX BITCHEZ
void free_ast(struct ast *a){
	
};

void print_tab(int tab){
	int i = tab;
	while(i > 0){
		printf("\t");
		i--;
	};
};
void print_ast(struct ast *a){
	static int tabcount = 0;
	if (a){
		switch(a->nodetype){
		
			
		case(nPROG):
			tabcount ++;
			print_ast(a->l);
			print_ast(a->r);
			tabcount --;
			break;
		case(nTYPE_LIST):
		case(nVAR_LIST):
		case(nPARAMETERS):
			print_ast(a->l);
			if (a->r)
				printf(", ");
			print_ast(a->r);
			break;
		case(nARRAY_DIMENSIONS):
			printf("[");
			print_ast(a->l);
			printf("]");
			print_ast(a->r);
			break;
		case(nTYPE):
		case(nIVAL):
			printf("%d", ((struct ast_ival *)a)->i);
			break;
		case(nID):
		case(nCID):
			printf("%s", ((struct ast_sval *)a)->s);
			break;
		
		case(nVAR_DECLARATION): // Var: x:int
			print_tab(tabcount);
			printf("Var: %s", ((struct var *)a)->id);
			print_ast(((struct var *)a)->array_dimensions);
			printf(":%d\n", ((struct var *)a)->type);
			break;
		case(nFUN_DECLARATION):
			print_tab(tabcount);
			printf("Fun: %s(", ((struct fun *)a)->id);
			print_ast(((struct fun *)a)->param_list);
			printf("):%d\n", ((struct fun *)a)->type);
			tabcount++;
			print_ast(((struct fun *)a)->fun_block);
			tabcount--;
			break;
		case(nBASIC_DECLARATION):
			printf("%s", ((struct ast_sval *)(((struct ast_three *)a)->l))->s);
			print_ast(((struct ast_three *)a)->m);
			printf(":");
			printf("%d", ((struct ast_ival *)((struct ast_three *)a)->r)->i);
			break;
		case(nBASIC_ARRAY_DIMENSION):
			printf("[]");
			print_ast(((struct ast_one *)a)->a);
			break;
		case(nFUN_BODY):
			print_ast(a->l);
			print_tab(tabcount);
			printf("return: ");
			print_ast(a->r);
			printf("\n");
			break;
		case(nCONS_DECL):
			print_tab(tabcount);
			printf("%s:", ((struct ast_sval *)(a->l))->s);
			print_ast(a->r);
			printf("\n");
			break;
		case(nDATA_DECLARATION):
			print_tab(tabcount);
			printf("Data: %s\n", ((struct data *)a)->id);
			tabcount++;
			print_ast(((struct data *)a)->cons_declarations);
			tabcount--;
			break;
		
		
		case(nPROG_STMTS):
			print_tab(tabcount);
			print_ast(a->l);
			printf("\n");
			if (a->r){
				print_ast(a->r);
			};
			break;
		case(nBLOCK):
			printf("{\n");
			print_ast(((struct ast_three *)a)->l);
			print_tab(tabcount);
			printf("}");
			break;
		case(nCA):
			printf("CASE ");
			print_ast(((struct ast_three *)a)->l);
			printf(" OF ");
			print_ast(((struct ast_three *)a)->m);
			break;
		case(nCASE_LIST):
			print_ast(a->l);
			if(a->r){
				printf(" | ");
				print_ast(a->r);
			};		
			break;
		case(nCASE):
			print_ast(((struct ast_three *)a)->l);
			if (((struct ast_three *)a)->m){
				printf(" (");
				print_ast(((struct ast_three *)a)->m);
				printf(")");
			}	
			printf(" becomes ");
			print_ast(((struct ast_three *)a)->r);
			break;
		case(nAS):
			printf("ASSIGN ");
			print_ast(((struct ast_three *)a)->m);
			printf(" into ");
			print_ast(((struct ast_three *)a)->l);
			break;
		case(nPR):
			printf("PRINT ");
			print_ast(((struct ast_three *)a)->l);
			break;
		case(nRE):
			printf("READ ");
			print_ast(((struct ast_three *)a)->l);
			break;
		case(nWH):
			printf("WHILE ");
			print_ast(((struct ast_three *)a)->l);
			printf(" DO ");
			print_ast(((struct ast_three *)a)->m);
			break;
		case(nIF):
			printf("IF ");
			print_ast(((struct ast_three *)a)->l);
			printf(" THEN ");
			print_ast(((struct ast_three *)a)->m);
			printf(" ELSE ");
			print_ast(((struct ast_three *)a)->r);
			break;


		case(nOR):

			break;
		case(nAND):

			break;
		case(nNOT):

			break;
		case(nADD):

			break;
		case(nSUB):

			break;
		case(nMUL):

			break;
		case(nDIV):

			break;
		case(nEQ):

			break;
		case(nLT):

			break;
		case(nGT):

			break;
		case(nLE):

			break;
		case(nGE):

			break;


		default:
			print_ast(a->l);
			print_ast(a->r);
			break;
		};
	}
};
