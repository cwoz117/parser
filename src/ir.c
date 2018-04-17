#include <stdio.h>
#include "ast.h"
#include "symbol_table.h"
#include "ir.h"

void semantics(struct ast *a, struct table *t){
	switch(a->nodetype){
		case(nBLOCK):
			add_scope(&t);
			semantics(a->l, t);
			semantics(a->r, t);
			delete_scope(&t);	
			break;
		case(nVAR_DECLARATION):
		case(nFUN_DECLARATION):
		case(nDATA_DECLARATION):
			add_symbol(t, a);
			break;
		default:
			semantics(a->l, t);
			semantics(a->r, t);

	};
};
