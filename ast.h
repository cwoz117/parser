#ifndef AST_H
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

	nFUN_BODY, nPROG_STMTS, nIF, nWH, nRE, nAS, nPR, nBL, nCA, nLOCATION, nCASE_LIST, 

	nADD, nSUB, nMUL, nDIV, nOR, nAND, nINT_TERM, nINT_EXPR, nARGUMENTS, nCASE,

	nFLOAT, nFLOOR, nCEIL, nINT_FACTOR_ID, nINT_FACTOR_SUB, nINT_FACTOR_CID,

	nIVAL, nRVAL, nBVAL, nID, nCID, nCVAL, nBASIC_DECLARATION, nDATA_DECLARATION,

	nVAR_LIST, nEQ, nLT, nGT, nLE, nGE, nSIZE
}Nodetype;

struct ast{
	Nodetype nodetype;
};

struct ast_one{
	Nodetype nodetype;
	struct ast *a;
};
struct ast_two{ 
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
struct ast_four{
	Nodetype nodetype;
	struct ast *l;
	struct ast *m;
	struct ast *r;
	struct ast *s;
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

struct ast *new_one( Nodetype t, struct ast *a);
struct ast *new_two( Nodetype t, struct ast *l, struct ast *r);
struct ast *new_three( Nodetype t, struct ast *l, struct ast *m, struct ast *r);
struct ast *new_four( Nodetype t, struct ast *l, struct ast *m, struct ast *r, struct ast *s);

struct ast *new_sval(Nodetype n, char *s);
struct ast *new_ival(Nodetype n, int i);
struct ast *new_rval(Nodetype n, double d);
struct ast *new_bval(Nodetype n, bool b);
struct ast *new_cval(Nodetype n, char c);

void free_ast(struct ast *a);
void print_ast(struct ast *a);


#endif
