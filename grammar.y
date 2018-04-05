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

%type <n> block declarations prog declaration var_declaration
%type <n> var_specs var_spec array_dimensions more_var_specs
%type <ival> type

%type <n> fun_declaration fun_block param_list parameters more_parameters
%type <n> basic_declaration basic_array_dimensions

%type <n> data_declaration cons_declarations more_cons_decl
%type <n> cons_decl type_list more_type

%type <n> program_body fun_body prog_stmts prog_stmt location case_list
%type <n> more_case case var_list var_list1 more_var_list1

%type <n> expr bint_term bint_factor compare_op int_expr addop
%type <n> mulop int_factor modifier_list fun_argument_list
%type <n> cons_argument_list arguments more_arguments int_term

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
								/* INITIAL SETUP*/

prog:
	block;   
block:
	declarations program_body { $$ = new_ast($1, $2);};


								/* DECLARATIONS */

declarations:
	declaration SEMICOLON declarations {$$ = new_declarations($1, $3);}
	| {$$ = NULL;};
declaration:
	var_declaration
	| fun_declaration
	| data_declaration;
var_declaration:
	VAR var_specs COLON type { $$ = new_ast(new_type($4), $2); };
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

								/* FUNCTIONS */

fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR {};
fun_block:
	declarations fun_body {};
param_list:
	LPAR parameters RPAR {};
parameters:
	basic_declaration more_parameters {}
	| {$$ = NULL;};
more_parameters:
	COMMA basic_declaration more_parameters {}
	| {$$ = NULL;};
basic_declaration:
	ID basic_array_dimensions COLON type {};
basic_array_dimensions:
	SLPAR SRPAR basic_array_dimensions {}
	| {$$ = NULL;};
	
								/* Datatypes */

data_declaration:
	DATA ID EQUAL cons_declarations {};
cons_declarations:
	cons_decl more_cons_decl {};
more_cons_decl:
	SLASH cons_decl more_cons_decl {}
	| {$$ = NULL;};
cons_decl:
	CID OF type_list {}
	| CID {};
type_list:
	type more_type {};
more_type:
	MUL type more_type {}
	| {$$ = NULL;};

								/* Statements*/

program_body:
	BEGIN prog_stmts END {}
	| prog_stmts {};
fun_body:
	BEGIN prog_stmts RETURN expr SEMICOLON END {}
	|prog_stmts RETURN expr SEMICOLON {};
prog_stmts:
	prog_stmt SEMICOLON prog_stmts {}
	| {$$ = NULL;};
prog_stmt:
	IF expr THEN prog_stmt ELSE prog_stmt {}
	| WHILE expr DO prog_stmt {}
	| READ location {}
	| location ASSIGN expr {}
	| PRINT expr {}
	| CLPAR block CRPAR {}
	| CASE expr OF CLPAR case_list CRPAR {};
location:
	ID array_dimensions {};
case_list:
	case more_case {};
more_case:
	SLASH case more_case {}
	| {$$ = NULL;};
case:
	CID var_list ARROW prog_stmt {};
var_list:
	LPAR var_list1 RPAR {}
	| {$$ = NULL;};
var_list1:
	ID more_var_list1 {};
more_var_list1:
	COMMA ID more_var_list1 {}
	| {$$ = NULL;};

								/* Expressions */

expr:
	expr OR bint_term {}
	| bint_term {};
bint_term:
	bint_term AND bint_factor {}
	| bint_factor {};
bint_factor:
	NOT bint_factor {}
	| int_expr compare_op int_expr {}
	| int_expr {};
compare_op:
	EQUAL {}
	| LT {}
	| GT {}
	| LE {}
	| GE {};
int_expr:
	int_expr addop int_term {}
	| int_term {};
addop:
	ADD {}
	| SUB {};
int_term:
	int_term mulop int_factor {}
	| int_factor {};
mulop:
	MUL {}
	| DIV {};
int_factor:
	LPAR expr RPAR {}
	| SIZE LPAR ID basic_array_dimensions RPAR {}
	| FLOAT LPAR expr RPAR {}
	| FLOOR LPAR expr RPAR {}
	| CEIL LPAR expr RPAR {}
	| ID modifier_list {}
	| CID cons_argument_list {}
	| IVAL {}
	| RVAL {}
	| BVAL {}
	| CVAL {}
	| SUB int_factor {};
modifier_list:
	fun_argument_list {}
	| array_dimensions {};
fun_argument_list:
	LPAR arguments RPAR {};
cons_argument_list:
	fun_argument_list {}
	| {$$ = NULL;};
arguments:
	expr more_arguments {}
	| {$$=NULL;};
more_arguments:
	COMMA expr more_arguments {}
	| {$$ = NULL;};
%%

void yyerror(char *a){
	fprintf(stderr, "%d: error: ", yylineno);
	fprintf(stderr, s);
}

int main(){
	return yyparse();
}
