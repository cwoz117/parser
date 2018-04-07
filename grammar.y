%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

extern int yylineno;
void yyerror(char *s);

typedef enum {
	ntBLOCK, ntDECLARATIONS, ntVAR_DECLARATION, ntVAR_SPECS, ntVAR_SPEC, ntARRAY_DIMENSIONS, ntEXPR,
	
	ntFUN_DECLARATION, ntFUN_BLOCK, ntPARAMETERS, ntBASIC_ARRAY_DIMENSION,
	
	ntCONS_DECLARATIONS, ntTYPE_LIST,

	ntFUN_BODY, ntPROG_STMTS, ntIF, ntWH, ntRE, ntAS, ntPR, ntBL, ntCA, ntLOCATION, ntCASE_LIST, ntVAR_LIST,
	
	
	astVARIABLE, astFUNCTION_DECLARATION, astBASIC_DECLARATION, astDATA_DECLARATION, astCONS_DECL, astCASE,
	
	trmID
}Nodetype;

struct ast{ 
	Nodetype nodetype;
	struct ast *l;
	struct ast *r;
};
struct ast_variable {
	Nodetype nodetype;
	int declaredtype;
	char *name;
	struct ast *dimensions;
};
struct ast_function {
	Nodetype nodetype;
	int declaredtype;
	char *id;
	struct ast *params;
	struct ast *block;
};
struct ast_data_declaration{
	Nodetype nodetype;
	char *id;
	struct ast *constructors;
};
struct ast_constructor{
	Nodetype nodetype;
	char *cid;
	struct ast *types;
};
struct ast_flow{
	Nodetype nodetype;
	struct ast *l;
	struct ast *m;
	struct ast *r;
};
struct ast_id{
	Nodetype nodetype;
	char *id;
	struct ast *array;
};
struct ast_type_list{
	Nodetype nodetype;
	int type;
	struct ast *more_type;
};
struct ast_case{
	Nodetype nodetype;
	char *cid;
	struct ast *var_list;
	struct ast *prog_stmt;
};

struct ast *new_ast( Nodetype t, struct ast *l, struct ast *r);

struct ast *new_var_spec(char *id, struct ast *array_dims);
struct ast *new_variable(int type, struct ast *var_spec);
struct ast *new_variable_declaration(int type, struct ast *var_specs);

struct ast *new_function(char *id, struct ast *param_list, int type, struct ast *fun_block);
struct ast *new_basic_declaration(char *id, struct ast *a, int type);

struct ast *new_data_declaration(char *id, struct ast *constructors);
struct ast *new_type_list(int type, struct ast *more_types);
struct ast *new_cons_decl(char *cid, struct ast *type_list);

struct ast *new_flow(Nodetype nodetype, struct ast *expr, struct ast *then, struct ast *els);
struct ast *new_location(char *id, struct ast *array);
struct ast *new_case(char *cid, struct ast *vars, struct ast *stmt);
struct ast *new_var_list(char *id, struct ast *more_vars);

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
%type <ival> type

%type <n> fun_declaration fun_block param_list parameters more_parameters
%type <n> basic_declaration basic_array_dimensions

%type <n> data_declaration cons_declarations more_cons_decl
%type <n> cons_decl type_list more_type cons_argument_list

%type <n> program_body fun_body prog_stmts prog_stmt location case_list
%type <n> more_case case var_list var_list1 more_var_list1

%type <n> expr bint_term bint_factor arguments more_arguments

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
	declarations program_body { $$ = new_ast(ntBLOCK, $1, $2);};


								/* DECLARATIONS */

declarations:
	declaration SEMICOLON declarations {$$ = new_ast(ntDECLARATIONS, $1, $3);}
	| {$$ = NULL;};
declaration:
	var_declaration
	| fun_declaration
	| data_declaration;
var_declaration:
	VAR var_specs COLON type { $$ = new_variable_declaration($4, $2); };
var_specs:
	var_spec more_var_specs { $$ = new_ast(ntVAR_SPECS, $1, $2);};
more_var_specs:
	COMMA var_spec more_var_specs { $$ = new_ast(ntVAR_SPECS, $2, $3);}
	| {$$ = NULL;};
var_spec:
	ID array_dimensions { $$ = new_var_spec($1, $2); };
array_dimensions:
	SLPAR expr SRPAR array_dimensions { $$ = new_ast(ntARRAY_DIMENSIONS, $2, $4);}
	|{ $$ = NULL;};
type:
	INT 	{ $$ = INT; }
	| REAL 	{ $$ = REAL; }
	| BOOL 	{ $$ = BOOL; }
	| CHAR 	{ $$ = CHAR; }
	| ID 	{ $$ = ID; };

								/* FUNCTIONS */

fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR { $$ = new_function($2, $3, $5, $7);};
fun_block:
	declarations fun_body { $$ = new_ast(ntFUN_BLOCK, $1, $2);};
param_list:
	LPAR parameters RPAR { $$ = $2; };
parameters:
	basic_declaration more_parameters {$$ = new_ast(ntPARAMETERS, $1, $2);}
	| {$$ = NULL;};
more_parameters:
	COMMA basic_declaration more_parameters {$$ = new_ast(ntPARAMETERS, $2, $3);}
	| {$$ = NULL;};
basic_declaration:
	ID basic_array_dimensions COLON type {$$ = new_basic_declaration($1, $2, $4);};
basic_array_dimensions:
	SLPAR SRPAR basic_array_dimensions { $$ = new_ast(ntBASIC_ARRAY_DIMENSION, NULL, $3);}
	| {$$ = NULL;};
	
								/* Datatypes */

data_declaration:
	DATA ID EQUAL cons_declarations { $$ = new_data_declaration($2, $4);};
cons_declarations:
	cons_decl more_cons_decl {$$ = new_ast(ntCONS_DECLARATIONS, $1, $2);};
more_cons_decl:
	SLASH cons_decl more_cons_decl { $$ = new_ast(ntCONS_DECLARATIONS, $2, $3);}
	| {$$ = NULL;};
cons_decl:
	CID OF type_list { $$ = new_cons_decl($1, $3);}
	| CID { $$ = new_cons_decl($1, NULL);};
type_list:
	type more_type { $$ = new_type_list($1,$2); };
more_type:
	MUL type more_type { $$ = new_type_list($2, $3);}
	| {$$ = NULL;};

								/* Statements*/

program_body:
	BEGI prog_stmts END { $$ = $2; }
	| prog_stmts;
fun_body:
	BEGI prog_stmts RETURN expr SEMICOLON END { $$ = new_ast(ntFUN_BODY, $2, $4);}
	|prog_stmts RETURN expr SEMICOLON { $$ = new_ast(ntFUN_BODY, $1, $3);};
prog_stmts:
	prog_stmt SEMICOLON prog_stmts { $$ = new_ast(ntPROG_STMTS, $1, $3);}
	| {$$ = NULL;};
prog_stmt:
	IF expr THEN prog_stmt ELSE prog_stmt 	{ $$ = new_flow(ntIF, $2, $4, $6);}
	| WHILE expr DO prog_stmt 		{ $$ = new_flow(ntWH, $2, $4, NULL);}
	| READ location 			{ $$ = new_flow(ntRE, $2, NULL, NULL);}
	| location ASSIGN expr 			{ $$ = new_flow(ntAS, $1, $3, NULL);}
	| PRINT expr 				{ $$ = new_flow(ntPR, $2, NULL, NULL);}
	| CLPAR block CRPAR 			{ $$ = new_flow(ntBL, $2, NULL, NULL);}
	| CASE expr OF CLPAR case_list CRPAR 	{ $$ = new_flow(ntCA, $2, $5, NULL);};
location:
	ID array_dimensions { $$ = new_location($1, $2);};
case_list:
	case more_case { $$ = new_ast(ntCASE_LIST, $1, $2);};
more_case:
	SLASH case more_case {$$ = new_ast(ntCASE_LIST, $2, $3);}
	| {$$ = NULL;};
case:
	CID var_list ARROW prog_stmt { $$ = new_case($1, $2, $4);};
var_list:
	LPAR var_list1 RPAR { $$ = $2; }
	| {$$ = NULL;};
var_list1:
	ID more_var_list1 { $$ = new_var_list($1, $2);};
more_var_list1:
	COMMA ID more_var_list1 { $$ = new_var_list($2, $3);}
	| {$$ = NULL;};

								/* Expressions */

expr:
	expr OR bint_term {}
	| bint_term;
bint_term:
	bint_term AND bint_factor {}
	| bint_factor;
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

void *mal_node(int size, Nodetype nodetype){
	void * a = malloc(size);
	if(!a){
		yyerror("Ran out of space\n");
		exit(1);
	}
	((struct ast *)a)->nodetype = nodetype;
	return a;
}

								// GENERIC AST

struct ast *new_ast(Nodetype t, struct ast *l, struct ast *r){
	struct ast *a = mal_node(sizeof(struct ast), t);
	a->l = l;
	a->r = r;
	return a;
}

								// VAR_DECLARATION

struct ast *new_var_spec(char *id, struct ast *array_dimensions){
	struct ast_id *leaf = mal_node(sizeof(struct ast_id), trmID);
	leaf->id = id;
	leaf->array = array_dimensions;
	return (struct ast *)leaf;
}
struct ast *new_variable(int type, struct ast *var_spec){
	struct ast_variable *v = mal_node(sizeof(struct ast_variable), astVARIABLE);
	v->declaredtype = type;
	v->name = ((struct ast_id *)(var_spec->l))->id;
	v->dimensions = var_spec->r;
	return (struct ast *)v;
}
struct ast *new_variable_declaration(int type, struct ast *var_specs){
	if(!var_specs)
		return NULL;
	struct ast *variables = mal_node(sizeof(struct ast), ntVAR_DECLARATION);
	variables->l = new_variable(type, var_specs->l);
	variables->r = new_variable_declaration(type, var_specs->r);
	return variables;
}

								// FUNCTIONS

struct ast *new_basic_declaration(char *id, struct ast *dimensions, int type) {
	struct ast_variable *a = mal_node(sizeof(struct ast_variable), astBASIC_DECLARATION);
	a->declaredtype = type;
	a->name = id;
	a->dimensions = dimensions;
	return (struct ast *)a;
}
struct ast *new_function(char *id, struct ast *param_list, 
			 int type, struct ast *fun_block) {
	struct ast_function *a = mal_node(sizeof(struct ast_function), ntFUN_DECLARATION);
	a->id = id;
	a->declaredtype = type;
	a->params = param_list;
	a->block = fun_block;
	return (struct ast*)a;
}

								// DATA TYPES

struct ast *new_data_declaration(char *id, struct ast *constructors){
	struct ast_data_declaration *a = mal_node(sizeof(struct ast_data_declaration), astDATA_DECLARATION);
	a->id =id;
	a->constructors = constructors;
	return (struct ast *)a;
};
struct ast *new_type_list(int type, struct ast *more_types){
	struct ast_type_list *a = mal_node(sizeof(struct ast_type_list), ntTYPE_LIST);
	a->type = type;
	a->more_type = more_types;
	return (struct ast *)a;
};
struct ast * new_cons_decl(char *cid, struct ast *type_list){
	struct ast_constructor *a = mal_node(sizeof(struct ast_constructor), astCONS_DECL);
	a->cid = cid;
	a->types = type_list;
	return (struct ast *)a;
};

								// STATEMENTS

struct ast * new_flow(Nodetype nt, struct ast *expr, struct ast *then, struct ast *els){
	struct ast_flow *a = mal_node(sizeof(struct ast_flow), nt);
	a->l = expr;
	a->m = then;
	a->r = els;
	return (struct ast *)a;
};
struct ast * new_location(char *id, struct ast *array_dimensions){
	struct ast_id *a = mal_node(sizeof(struct ast_id), ntLOCATION);
	a->id = id;
	a->array = array_dimensions;
	return (struct ast *)a;
};
struct ast *new_case(char *cid, struct ast *var_list, struct ast *prog_stmt){
	struct ast_case *a = mal_node(sizeof(struct ast_case), astCASE);
	a->cid = cid;
	a->var_list = var_list;
	a->prog_stmt = prog_stmt;
	return (struct ast *)a;
};
struct ast *new_var_list(char *id, struct ast *more_vars){
	struct ast_id *a = mal_node(sizeof(struct ast_id), ntVAR_LIST);
	a->id = id;
	a->array = more_vars;
	return (struct ast *)a;
};
								// EXPRESSIONS



								// FREE AST

void free_ast(struct ast *a){
	if(a){
		switch(a->nodetype){
			case 0:
				free_ast(a->l);
				free_ast(a->r);
				free(a);
				break;
			case 1:
				free_ast(((struct ast_variable *)a)->dimensions);
				free_ast(a);
				break;
		}
	}
}

// PRINT THE AST
void print_ast(struct ast *a){
	if(a){
		printf("TB Fuckin' D\n");
	}
}


/*




fun_declaration:
	FUN ID param_list COLON type CLPAR fun_block CRPAR {} ;

fun_block:
	declarations fun_body {};

param_list:
	LPAR parameters RPAR {};

*/



void yyerror(char *a){
	fprintf(stderr, "%d: error: ", yylineno);
	fprintf(stderr, a);
}

int main(){
	yyparse();
	print_ast(parse_tree);
	return 0;
}
