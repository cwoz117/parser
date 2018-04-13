%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "ast.h"

struct ast * parse_tree = NULL;
%}

%code requires{
	#include <stdbool.h>
	#include "ast.h"
}

%union {
	struct ast *n;
	int ival;
	char *sval;
	float rval;
	bool bval;
	char cval;
	Nodetype nt;
}

%type <n> block declarations prog declaration var_declaration
%type <n> var_specs var_spec array_dimensions more_var_specs
%type <n> type int_expr int_factor fun_argument_list
%type <n> fun_declaration fun_block param_list parameters more_parameters
%type <n> basic_declaration basic_array_dimensions modifier_list
%type <n> data_declaration cons_declarations more_cons_decl
%type <n> cons_decl type_list more_type cons_argument_list
%type <n> program_body fun_body prog_stmts prog_stmt location case_list
%type <n> more_case case var_list var_list1 more_var_list1
%type <n> expr bint_term bint_factor arguments more_arguments int_term
%type <nt> compare_op addop mulop

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
	declarations program_body { $$ = new_ast(nPROG, $1, $2);};

								/* DECLARATIONS */

declarations:
	declaration SEMICOLON declarations {$$ = new_ast(nDECLARATIONS, $1, $3);}
	| {$$ = NULL;};
declaration:
	var_declaration
	| fun_declaration
	| data_declaration;
var_declaration:
	VAR var_specs COLON type { $$ = new_var_declaration($2, $4); };
var_specs:
	var_spec more_var_specs { $$ = new_ast(nVAR_SPECS, $1, $2);};
more_var_specs:
	COMMA var_spec more_var_specs { $$ = new_ast(nVAR_SPECS, $2, $3);}
	| {$$ = NULL;};
var_spec:
	ID array_dimensions {$$ = new_ast(nVAR_SPEC, new_sval(nID, $1), $2); };
array_dimensions:
	SLPAR expr SRPAR array_dimensions { $$ = new_ast(nARRAY_DIMENSIONS, $2, $4);}
	|{ $$ = NULL;};
type:
	INT 	{ $$ = new_ival(nTYPE, thINT); }
	| REAL 	{ $$ = new_ival(nTYPE, thREAL); }
	| BOOL 	{ $$ = new_ival(nTYPE, thBOOL); }
	| CHAR 	{ $$ = new_ival(nTYPE, thCHAR); }
	| ID 	{ $$ = new_ival(nTYPE, thID); };

								/* FUNCTIONS */

fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR 
		{ $$ = new_function(nFUN_DECLARATION, new_sval(nID, $2), $3, $5, $7);};
fun_block:
	declarations fun_body { $$ = new_ast(nFUN_BLOCK, $1, $2);};
param_list:
	LPAR parameters RPAR { $$ = $2; };
parameters:
	basic_declaration more_parameters {$$ = new_ast(nPARAMETERS, $1, $2);}
	| {$$ = NULL;};
more_parameters:
	COMMA basic_declaration more_parameters {$$ = new_ast(nPARAMETERS, $2, $3);}
	| {$$ = NULL;};
basic_declaration:
	ID basic_array_dimensions COLON type 
		{$$ =new_three(nBASIC_DECLARATION, new_sval(nID, $1), $2, $4);};
basic_array_dimensions:
	SLPAR SRPAR basic_array_dimensions { $$ = new_one(nBASIC_ARRAY_DIMENSION, $3);}
	| {$$ = NULL;};
	
								/* Datatypes */

data_declaration:
	DATA ID EQUAL cons_declarations { $$ = new_data($2, $4);};
cons_declarations:
	cons_decl more_cons_decl {$$ = new_ast(nCONS_DECLARATIONS, $1, $2);};
more_cons_decl:
	SLASH cons_decl more_cons_decl { $$ = new_ast(nCONS_DECLARATIONS, $2, $3);}
	| {$$ = NULL;};
cons_decl:
	CID OF type_list { $$ = new_ast(nCONS_DECL, new_sval(nCID,$1), $3);}
	| CID { $$ = new_sval(nCID, $1);};
type_list:
	type more_type { $$ = new_ast(nTYPE_LIST, $1, $2); };
more_type:
	MUL type more_type { $$ = new_ast(nTYPE_LIST, $2, $3);}
	| {$$ = NULL;};

								/* Statements*/

program_body:
	BEGI prog_stmts END { $$ = $2; }
	| prog_stmts;
fun_body:
	BEGI prog_stmts RETURN expr SEMICOLON END { $$ = new_ast(nFUN_BODY, $2, $4);}
	|prog_stmts RETURN expr SEMICOLON { $$ = new_ast(nFUN_BODY, $1, $3);};
prog_stmts:
	prog_stmt SEMICOLON prog_stmts { $$ = new_ast(nPROG_STMTS, $1, $3);}
	| {$$ = NULL;};
prog_stmt:
	IF expr THEN prog_stmt ELSE prog_stmt 	{ $$ = new_stmt(nIF, $2, $4, $6);}
	| WHILE expr DO prog_stmt 		{ $$ = new_stmt(nWH, $2, $4, NULL);}
	| READ location 			{ $$ = new_stmt(nRE, $2, NULL, NULL);}
	| location ASSIGN expr 			{ $$ = new_stmt(nAS, $1, $3, NULL);}
	| PRINT expr 				{ $$ = new_stmt(nPR, $2, NULL, NULL);}
	| CLPAR block CRPAR 			{ $$ = new_stmt(nBLOCK, $2, NULL, NULL);}
	| CASE expr OF CLPAR case_list CRPAR 	{ $$ = new_stmt(nCA, $2, $5, NULL);};
location:
	ID array_dimensions { $$ = new_ast(nLOCATION, new_sval(nID, $1), $2);};
case_list:
	case more_case { $$ = new_ast(nCASE_LIST, $1, $2);};
more_case:
	SLASH case more_case {$$ = new_ast(nCASE_LIST, $2, $3);}
	| {$$ = NULL;};
case:
	CID var_list ARROW prog_stmt { $$ = new_three(nCASE, new_sval(nCID, $1), $2, $4);};
var_list:
	LPAR var_list1 RPAR { $$ = $2; }
	| {$$ = NULL;};
var_list1:
	ID more_var_list1 { $$ = new_ast(nVAR_LIST, new_sval(nID, $1), $2);};
more_var_list1:
	COMMA ID more_var_list1 { $$ = new_ast(nVAR_LIST, new_sval(nID, $2), $3);}
	| {$$ = NULL;};

								/* Expressions */

expr:
	expr OR bint_term { $$ = new_ast(nOR, $1, $3);}
	| bint_term;
bint_term:
	bint_term AND bint_factor { $$ = new_ast(nAND, $1, $3);}
	| bint_factor;
bint_factor:
	NOT bint_factor { $$ = new_one(nNOT, $2);} 
	| int_expr compare_op int_expr { $$ = new_ast($2, $1, $3);}
	| int_expr;
compare_op:
	EQUAL { $$ = nEQ;}
	| LT {$$ = nLT;}
	| GT {$$ = nGT;}
	| LE {$$ = nLE;}
	| GE {$$ = nGE;};
int_expr:
	int_expr addop int_term { $$ = new_ast($2, $1, $3);}
	| int_term;
addop:
	ADD { $$ = nADD;}
	| SUB { $$ = nSUB;};
int_term:
	int_term mulop int_factor { $$ = new_ast($2, $1, $3);}
	| int_factor;
mulop:
	MUL { $$ = nMUL;}
	| DIV {$$ = nDIV;};
int_factor:
	LPAR expr RPAR { $$ = $2; }
	| SIZE LPAR ID basic_array_dimensions RPAR { $$ = new_ast(nSIZE, new_sval(nID, $3), $4);}
	| FLOAT LPAR expr RPAR { $$ = new_one(nFLOAT, $3);}
	| FLOOR LPAR expr RPAR { $$ = new_one(nFLOOR, $3);}
	| CEIL LPAR expr RPAR { $$ = new_one(nCEIL, $3);}
	| ID modifier_list { $$ = new_ast(nINT_FACTOR_ID, new_sval(nID, $1), $2);}
	| CID cons_argument_list {$$ = new_ast(nINT_FACTOR_CID, new_sval(nCID, $1), $2);}
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
	expr more_arguments { $$ = new_ast(nARGUMENTS, $1, $2);}
	| {$$=NULL;};
more_arguments:
	COMMA expr more_arguments {$$ = new_ast(nARGUMENTS, $2, $3);}
	| {$$ = NULL;};
%%


void yyerror(char *a){
	fprintf(stderr, "Line %3d: ", yylineno);
	fprintf(stderr, "%s\n", a);
};

int main(){
	yyparse();
	printf("\nprog\n");
	print_ast(parse_tree);
	return 0;
};
