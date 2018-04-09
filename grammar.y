%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

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

struct ast * parse_tree = NULL;
%}

%code requires{
	#include <stdbool.h>
}

%union {
	struct ast *n;
	int ival;
	char *sval;
	float rval;
	bool bval;
	char cval;
}

%type <n> block declarations prog declaration var_declaration
%type <n> var_specs var_spec array_dimensions more_var_specs
%type <n> type int_expr compare_op addop mulop int_factor fun_argument_list
%type <n> fun_declaration fun_block param_list parameters more_parameters
%type <n> basic_declaration basic_array_dimensions modifier_list
%type <n> data_declaration cons_declarations more_cons_decl
%type <n> cons_decl type_list more_type cons_argument_list
%type <n> program_body fun_body prog_stmts prog_stmt location case_list
%type <n> more_case case var_list var_list1 more_var_list1
%type <n> expr bint_term bint_factor arguments more_arguments int_term

%token <sval> ADD OR NOT EQUAL LT GT LE GE ASSIGN AND ARROW DIV MUL SUB
%token <sval> LPAR RPAR CLPAR CRPAR SLPAR SRPAR SLASH COLON SEMICOLON COMMA
%token <sval> IF THEN WHILE DO READ ELSE BEGI END CASE OF PRINT FLOOR CEIL
%token <sval> INT BOOL CHAR REAL VAR DATA SIZE FLOAT FUN RETURN CID ID
%token <rval> RVAL
%token <ival> IVAL
%token <bval> BVAL
%token <cval> CVAL

%start prog;



%%
								/* INITIAL SETUP*/

prog:
	block  {parse_tree = $$;};
block:
	declarations program_body { $$ = new_two(nBLOCK, $1, $2);};


								/* DECLARATIONS */

declarations:
	declaration SEMICOLON declarations {$$ = new_two(nDECLARATIONS, $1, $3);}
	| {$$ = NULL;};
declaration:
	var_declaration
	| fun_declaration
	| data_declaration;
var_declaration:
	VAR var_specs COLON type { $$ = new_two(nVAR_DECLARATION, $2, $4); };
var_specs:
	var_spec more_var_specs { $$ = new_two(nVAR_SPECS, $1, $2);};
more_var_specs:
	COMMA var_spec more_var_specs { $$ = new_two(nVAR_SPECS, $2, $3);}
	| {$$ = NULL;};
var_spec:
	ID array_dimensions { $$ = new_two(nVAR_SPEC, new_sval(nID, $1), $2); };
array_dimensions:
	SLPAR expr SRPAR array_dimensions { $$ = new_two(nARRAY_DIMENSIONS, $2, $4);}
	|{ $$ = NULL;};
type:
	INT 	{ $$ = new_ival(nTYPE, INT); }
	| REAL 	{ $$ = new_ival(nTYPE, REAL); }
	| BOOL 	{ $$ = new_ival(nTYPE, BOOL); }
	| CHAR 	{ $$ = new_ival(nTYPE, CHAR); }
	| ID 	{ $$ = new_ival(nTYPE, ID); };

								/* FUNCTIONS */

fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR 
		{ $$ = new_four(nFUN_DECLARATION, new_sval(nID, $2), $3, $5, $7);};
fun_block:
	declarations fun_body { $$ = new_two(nFUN_BLOCK, $1, $2);};
param_list:
	LPAR parameters RPAR { $$ = $2; };
parameters:
	basic_declaration more_parameters {$$ = new_two(nPARAMETERS, $1, $2);}
	| {$$ = NULL;};
more_parameters:
	COMMA basic_declaration more_parameters {$$ = new_two(nPARAMETERS, $2, $3);}
	| {$$ = NULL;};
basic_declaration:
	ID basic_array_dimensions COLON type 
		{$$ =new_three(nBASIC_DECLARATION, new_sval(nID, $1), $2, $4);};
basic_array_dimensions:
	SLPAR SRPAR basic_array_dimensions { $$ = new_one(nBASIC_ARRAY_DIMENSION, $3);}
	| {$$ = NULL;};
	
								/* Datatypes */

data_declaration:
	DATA ID EQUAL cons_declarations 
		{ $$ = new_two(nDATA_DECLARATION, new_sval(nID, $2), $4);};
cons_declarations:
	cons_decl more_cons_decl {$$ = new_two(nCONS_DECLARATIONS, $1, $2);};
more_cons_decl:
	SLASH cons_decl more_cons_decl { $$ = new_two(nCONS_DECLARATIONS, $2, $3);}
	| {$$ = NULL;};
cons_decl:
	CID OF type_list { $$ = new_two(nCONS_DECL, new_sval(nCID, $1), $3);}
	| CID { $$ = new_sval(nCID, $1);};
type_list:
	type more_type { $$ = new_two(nTYPE_LIST, $1, $2); };
more_type:
	MUL type more_type { $$ = new_two(nTYPE_LIST, $2, $3);}
	| {$$ = NULL;};

								/* Statements*/

program_body:
	BEGI prog_stmts END { $$ = $2; }
	| prog_stmts;
fun_body:
	BEGI prog_stmts RETURN expr SEMICOLON END { $$ = new_two(nFUN_BODY, $2, $4);}
	|prog_stmts RETURN expr SEMICOLON { $$ = new_two(nFUN_BODY, $1, $3);};
prog_stmts:
	prog_stmt SEMICOLON prog_stmts { $$ = new_two(nPROG_STMTS, $1, $3);}
	| {$$ = NULL;};
prog_stmt:
	IF expr THEN prog_stmt ELSE prog_stmt 	{ $$ = new_three(nIF, $2, $4, $6);}
	| WHILE expr DO prog_stmt 		{ $$ = new_two(nWH, $2, $4);}
	| READ location 			{ $$ = new_one(nRE, $2);}
	| location ASSIGN expr 			{ $$ = new_two(nAS, $1, $3);}
	| PRINT expr 				{ $$ = new_one(nPR, $2);}
	| CLPAR block CRPAR 			{ $$ = new_one(nBL, $2);}
	| CASE expr OF CLPAR case_list CRPAR 	{ $$ = new_two(nCA, $2, $5);};
location:
	ID array_dimensions { $$ = new_two(nLOCATION, new_sval(nID, $1), $2);};
case_list:
	case more_case { $$ = new_two(nCASE_LIST, $1, $2);};
more_case:
	SLASH case more_case {$$ = new_two(nCASE_LIST, $2, $3);}
	| {$$ = NULL;};
case:
	CID var_list ARROW prog_stmt { $$ = new_three(nCASE, new_sval(nCID, $1), $2, $4);};
var_list:
	LPAR var_list1 RPAR { $$ = $2; }
	| {$$ = NULL;};
var_list1:
	ID more_var_list1 { $$ = new_two(nVAR_LIST, new_sval(nID, $1), $2);};
more_var_list1:
	COMMA ID more_var_list1 { $$ = new_two(nVAR_LIST, new_sval(nID, $2), $3);}
	| {$$ = NULL;};

								/* Expressions */

expr:
	expr OR bint_term { $$ = new_two(nOR, $1, $3);}
	| bint_term;
bint_term:
	bint_term AND bint_factor { $$ = new_two(nAND, $1, $3);}
	| bint_factor;
bint_factor:
	NOT bint_factor { $$ = new_one(nNOT, $2);} 
	| int_expr compare_op int_expr { $$ = new_three(nCMP, $1, $2, $3);}
	| int_expr;
compare_op:
	EQUAL { $$ = new_sval(nEQ, $1);}
	| LT {$$ = new_sval(nLT, $1);}
	| GT {$$ = new_sval(nGT, $1);}
	| LE {$$ = new_sval(nLE, $1);}
	| GE {$$ = new_sval(nGE, $1);};
int_expr:
	int_expr addop int_term { $$ = new_three(nINT_EXPR, $1, $2, $3);}
	| int_term;
addop:
	ADD { $$ = new_sval(nADD, $1);}
	| SUB { $$ = new_sval(nSUB, $1);};
int_term:
	int_term mulop int_factor { $$ = new_three(nINT_TERM, $1, $2, $3);}
	| int_factor;
mulop:
	MUL { $$ = new_sval(nMUL, $1);}
	| DIV {$$ = new_sval(nDIV, $1);};
int_factor:
	LPAR expr RPAR { $$ = $2; }
	| SIZE LPAR ID basic_array_dimensions RPAR { $$ = new_two(nSIZE, new_sval(nID, $3), $4);}
	| FLOAT LPAR expr RPAR { $$ = new_one(nFLOAT, $3);}
	| FLOOR LPAR expr RPAR { $$ = new_one(nFLOOR, $3);}
	| CEIL LPAR expr RPAR { $$ = new_one(nCEIL, $3);}
	| ID modifier_list { $$ = new_two(nINT_FACTOR_ID, new_sval(nID, $1), $2);}
	| CID cons_argument_list {$$ = new_two(nINT_FACTOR_CID, new_sval(nCID, $1), $2);}
	| IVAL { $$ = new_ival(nIVAL, $1);}
	| RVAL { $$ = new_rval(nRVAL, $1);}
	| BVAL { $$ = new_bval(nBVAL, $1);}
	| CVAL { $$ = new_cval(nCVAL, $1);}
	| SUB int_factor { $$ = new_one(nINT_FACTOR_SUB, $2);};
modifier_list:
	fun_argument_list
	| array_dimensions;
fun_argument_list:
	LPAR arguments RPAR { $$ = $2;};
cons_argument_list:
	fun_argument_list 
	| {$$ = NULL;};
arguments:
	expr more_arguments { $$ = new_two(nARGUMENTS, $1, $2);}
	| {$$=NULL;};
more_arguments:
	COMMA expr more_arguments {$$ = new_two(nARGUMENTS, $2, $3);}
	| {$$ = NULL;};
%%

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
	if(a){
		printf("TB Fuckin' D\n");
	}
};

void yyerror(char *a){
	fprintf(stderr, "%d: error: ", yylineno);
	fprintf(stderr, a);
};

int main(){
	yyparse();
	print_ast(parse_tree);
	return 0;
};
