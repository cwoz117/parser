data inttree = #LEAF of int
		| #BRAN of inttree * inttree;

fun coll(t:intree):intlist{ 
	var L:intlist;
	case t of { #LEAF(n) => L:= #CONS(n,#NIL)
		  | #BRAN(t1,t2) => L:= append(coll(t1),coll(t2)) };
	return L;
};
