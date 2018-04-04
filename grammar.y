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
	declarations program_body { $$ = new_ast($1, $2);};

declarations:
	declaration SEMICOLON declarations {$$ = new_declaration($1, $3);}
	| {$$ = NULL;};

declaration:
	var_declaration
	| fun_declaration
	| data_declaration;

var_declaration:
	VAR var_specs COLON type { $$ = new_ast($4, $2); };
	
var_specs:
	var_spec more_var_specs { $$ = new_ast($1, $2);};

more_var_specs:
	COMMA var_spec more_var_specs { $$ = new_ast($2, $3);}
	| {$$ = NULL;};

var_spec:
	ID array_dimensions { $$ = new_ast($1, $2); };

array_dimensions:
	SLPAR expr SRPAR array_dimensions { $$ = new_ast($2, $4);}
	|{ $$ = NULL;};

type:
	INT 	{ $$ = INT; }
	| REAL 	{ $$ = REAL; }
	| BOOL 	{ $$ = BOOL; }
	| CHAR 	{ $$ = CHAR; }
	| ID 	{ $$ = ID; };


%%

void yyerror(char *a){
	fprintf(stderr, "%d: error: ", yylineno);
	fprintf(stderr, s);
}

int main(){
	return yyparse();
}
