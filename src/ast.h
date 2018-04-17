#ifndef AST_H
#define AST_H

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

extern int yylineno;
void yyerror(char *s);

typedef enum {
	nBLOCK, nVAR_DECLARATION, nVAR_SPECS, nVAR_SPEC, nARRAY_DIMENSIONS, nEXPR,
	
	nFUN_DECLARATION, nFUN_BLOCK, nPARAMETERS, nBASIC_ARRAY_DIMENSION,
	
	nCONS_DECLARATIONS, nTYPE_LIST, nTYPE, nNOT, nCMP, nDECLARATIONS, nCONS_DECL, 

	nFUN_BODY, nPROG_STMTS, nIF, nWH, nRE, nAS, nPR, nCA, nLOCATION, nCASE_LIST, 

	nADD, nSUB, nMUL, nDIV, nOR, nAND, nINT_TERM, nINT_EXPR, nARGUMENTS, nCASE,

	nFLOAT, nFLOOR, nCEIL, nINT_FACTOR_ID, nINT_FACTOR_SUB, nINT_FACTOR_CID,

	nIVAL, nRVAL, nBVAL, nID, nCID, nCVAL, nBASIC_DECLARATION, nDATA_DECLARATION,

	nVAR_LIST, nEQ, nLT, nGT, nLE, nGE, nSIZE, nPROG
}Nodetype;

typedef enum{
	thINT, thREAL, thBOOL, thCHAR, thID
}typeHelper;

// Parse Tree Containers
struct ast_one{
	Nodetype nodetype;
	struct ast *a;
};
struct ast{ 
	Nodetype nodetype;
	struct ast *l;
	struct ast *r;
};
struct ast_three{
	Nodetype nodetype;
	struct ast *l;
	struct ast *m;
	struct ast *r;
};

struct ast_sval{
	Nodetype nodetype;
	char *s;
};
struct ast_ival{
	Nodetype nodetype;
	int i;
};
struct ast_rval{
	Nodetype nodetype;
	double d;
};
struct ast_bval{
	Nodetype nodetype;
	bool b;
};
struct ast_cval{
	Nodetype nodetype;
	char c;
};

// AST Nodes
struct var{
	Nodetype nodetype;
	int type;
	char *id;
	int num_dimensions;
	struct ast *array_dimensions;
};
struct fun{
	Nodetype nodetype;
	int type;
	char *id;
	struct ast *param_list;
	struct ast *fun_block;
};
struct data{
	Nodetype nodetype;
	char *id;
	struct ast *cons_declarations;
};


struct ast *new_one(Nodetype n, struct ast *a);
struct ast *new_ast(Nodetype n, struct ast *l, struct ast *r);
struct ast *new_three(Nodetype n, struct ast *l, struct ast *m, struct ast *r);
struct ast *new_sval(Nodetype n, char *a);
struct ast *new_ival(Nodetype n, int i);
struct ast *new_rval(Nodetype n, double d);
struct ast *new_bval(Nodetype n, bool b);
struct ast *new_cval(Nodetype n, char c);

struct ast *new_function(Nodetype n, struct ast *id, struct ast *param_list, struct ast *type, struct ast *fun_block);
struct ast *new_data(char *id, struct ast *cons_declarations);
struct ast *new_stmt(Nodetype n, struct ast *l, struct ast *m, struct ast *r);
struct ast *new_var_declaration(struct ast *var_specs, struct ast  *type);

void free_ast(struct ast *a);
void print_ast(struct ast *a);
int count(struct ast *a);

#endif
