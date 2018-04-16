#ifndef IR_H
#define IR_H
#include "ast.h"
#include "ir.h"
#include <stdbool.h>

struct iexpr;
struct constructor_description;
struct array_description;
struct ifbody;

typedef enum{
	iASSIGN, iWHILE, iCOND, iCASE, 
	iRETURN, iBLOCK,
	iREAD_bool, iPRINT_bool, 
	iREAD_int, iPRINT_int,
	iREAD_float, iPRINT_float,
	iREAD_char, iPRINT_char,
}StmtType; 

struct istmt{
	StmtType type;	
};
		struct iassign{
			StmtType type;
			int level;
			int offset;
			struct iexpr *array_indices;
			struct iexpr *expressions;
			struct istmt *next;
		};
		struct iwhile{
			StmtType type;
			struct iexpr *condition;
			struct istmt *expressions;
			struct iexpr *next;
		};
		struct icond{
			StmtType type;
			struct iexpr *condition;
			struct istmt *cond_true;
			struct istmt *cond_else;
			struct istmt *next;
		};
		struct icase{
			StmtType type;
			struct iexpr *expr_acted_on; // case --> L <-- of #NIL => L:= #NIL | #cons(x,xs) => L := xs;
			struct constructor_description *constructors;
			struct istmt *next;
		};
		struct iread{
			StmtType type; // bool, int, char, float are all done in here
			int level;
			int offset;
			struct array_description *indices;
			struct istmt *next;
		};
		struct iprint{
			StmtType type; // bool, int, char, float are all done in here
			struct iexpr *value;
			struct istmt *next;
		};
		struct ireturn{
			StmtType type;
			struct iexpr *value;
			struct istmt *next;
		};
		struct iblock{
			StmtType type;
			struct ifbody *functions;
			int num_local_vars;
			struct array_description *arrays;
			struct istmt *body;
			struct istmt *next;
		};


typedef enum{
	iIVAL, iBVAL, iRVAL, iCVAL, iID, iAPP, iREF, iSIZE
}ExpType;
struct iexpr{
	ExpType type;
};
		struct iival{
			ExpType type;
			int i;
			struct iexpr *next;
		};
		struct irval{
			ExpType type;
			double d;
			struct iexpr *next;
		};
		struct bval{
			ExpType type;
			bool b;
			struct iexpr *next;
		};
		struct icval{
			ExpType type;
			double d;
			struct iexpr *next;
		};
		struct iid{
			ExpType type;
			int level;
			int offset;
			struct array_description *indices;
			struct iexpr *next;
		};
		struct iapp{ // [add, 2->3] --> add(2, 3)
			ExpType type;
			struct iopn *iopn; 
			struct expr *expressions; //conditioned AST means we can be ambiguous! woo!
		};
		struct iref{	// For array passing to a function
			ExpType type;
			int level;
			int ofset;
		};
		struct isize{ // Getting the dimension of an array
			ExpType type;
			int level;
			int offset;
			int dimension;
		};


typedef enum{
	iADD_int, iADD_real, iLT_int, iLT_real, iLT_char,
	iMUL_int, iMUL_real, iLE_int, iLE_real, iLE_char,
	iSUB_int, iSUB_real, iGT_int, iGT_real, iGT_char,
	iDIV_int, iDIV_real, iGE_int, iGE_real, iGE_char,
	iNEG_int, iNEG_real, iEQ_int, iEQ_real, iEQ_char,

	iNOT, iAND, iOR, iFLOAT, iFLOOR, iCEIL
}OpnType;
struct iopn{
	OpnType type;
};
		struct icall{
			OpnType type;
			char *label;
			int level;
		};
		struct icons{
			OpnType type;
			int cons_num;
			int num_args;
		};

struct array_description{
	typeHelper type;
	struct iexpr *dims;
};
struct constructor_description{
	int number;
	int num_args;
	struct stmt *stmt;
	struct constructor_description *next;
};
struct ifbody{
	char *start_label;
	struct ifbody *inner_functions;
	int num_local_vars;
	int num_args;
	struct array_description *arrays;
	struct istmt *body;
	struct ifbody *next;

};
struct iprog {
	struct functions *functions;
	int num_local_vars;
	struct array_description *arrays;
	struct istmt *body;
};


struct iprog *semantic_check(struct ast *a);




#endif
