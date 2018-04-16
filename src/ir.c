#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ir.h"
#include "symbol_table.h"

struct iprog *semantic_check(struct ast *a){
	struct table *sym = new_table();	
	struct iprog *ir = malloc(sizeof(struct iprog));
	if (!ir)
		exit 1;
	traverse(a, sym, ir);		
			
	return ir;
}

void traverse(struct ast *a, struct table *t, struct iprog *ir){
	switch(a->nodeType){
		case(nPROG):
			traverse(((struct ast_one *)a)->a, t, ir);
			break;
		case(nBLOCK):
			add_scope(t);
			fill_declarations(a->l, t, ir); // ----------------------------
			fill_statements(a->r, t, ir->body);
			break;
	};
};
