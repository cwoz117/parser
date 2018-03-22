%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "grammar.h"

int yylex();
%}

%union {
	int ival;
	char *sval;
	float rval;
	bool bval;
}


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
	block {$$ = new_prog();};   

block:
	declarations program_body {};

declarations:
	declaration SEMICOLON declarations {}
	|;

declaration:
	var_declaration {}
	| fun_declaration {}
	| data_declaration {};

var_declaration:
	VAR var_specs COLON type {};
	
var_specs:
	COMMA var_spec more_var_specs {}
	|;

var_spec:
	ID array_dimensions {};

array_dimensions:
	SLPAR expr SRPAR array_dimensions {}
	|;

type:
	INT {}
	| REAL {}
	| BOOL {}
	| CHAR {}
	| ID {};

%%

struct ast *
new_ast(int type, void *attribute, struct ast *l, struct ast *r){
	struct ast *a = malloc(sizeof(struct ast));
	if (!a){
		yyerror("out of space\n");
		exit(1);
	}
	a->type = type;
	a->attribute = *attribute;
	a->left = l;
	a->right = r;
	return a;
}


struct ast *
free_ast(struct ast *a){
	if (!a->l)
		free_ast(a->l);
	if (!a->r)
		free_ast(a->r);
	free(a);
}

void 
yyerror(char *a){
	fprintf(stderr, "%d: error: ", yylineno);
	fprintf(stderr, s);
}

int
main(){
	return yyparse();
}
