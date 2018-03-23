%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "ast.h"

%}

%union {
	struct ast *n;
	int ival;
	char *sval;
	float rval;
	bool bval;
	NodeType typeval;
}

%type <n> block program_body declarations
%type <n> declaration var_declaration fun_declaration data_declaration
%type <n> var_specs var_spec array_dimensions more_var_specs
%type <n> expr
%type <ival> type

%token <sval> ADD SUB MUL DIV ARROW AND OR NOT EQUAL LT GT LE GE ASSIGN
%token <sval> LPAR RPAR CLPAR CRPAR SLPAR SRPAR SLASH COLON SEMICOLON COMMA
%token <sval> IF THEN WHILE DO READ ELSE BEGIN END CASE OF PRINT FLOOR CEIL
%token <sval> INT BOOL CHAR REAL VAR DATA SIZE FLOAT FUN RETURN CID ID
%token <rval> RVAL
%token <ival> IVAL
%token <bval> BVAL
%token <sval> CVAL

%start prog;



%%
prog:
	block;   

block:
	declarations program_body { $$ = new_ast('a', $1, $2);};

declarations:
	declaration SEMICOLON declarations {$$ = new_ast('b', $1, $3);}
	| {$$ = NULL;};

declaration:
	var_declaration
	| fun_declaration
	| data_declaration;

var_declaration:
	VAR var_specs COLON type { $$ = new_var('c', $2, $4); };
	
var_specs:
	var_spec more_var_specs { $$ = new_ast('d', $1, $2);};

more_var_specs:
	COMMA var_spec more_var_specs { $$ = new_ast('e', $2, $3);}
	| {$$ = NULL;};

var_spec:
	ID array_dimensions { $$ = new_id('f', $1, $2); };

array_dimensions:
	SLPAR expr SRPAR array_dimensions { $$ = new_ast('g', $2, $4);}
	|{ $$ = NULL;};

type:
	INT 	{ $$ = INT; }
	| REAL 	{ $$ = REAL; }
	| BOOL 	{ $$ = BOOL; }
	| CHAR 	{ $$ = CHAR; }
	| ID 	{ $$ = ID; };



fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR {} ;

fun_block:
	declarations fun_body {};

param_list:
	LPAR parameters RPAR {};















%%

void 
yyerror(char *a){
	fprintf(stderr, "%d: error: ", yylineno);
	fprintf(stderr, s);
}

int
main(){
	return yyparse();
}
