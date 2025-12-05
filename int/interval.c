#
/*
 * SUMMER -- interval
 */

#include "summer.h"

/*
 * Class creation procedure
 */
SUBR CLASS _interval(){
	struct class *c;
	double r;
	int reals_used = 0, i;

	ARGCNT(4);
	ARGTYPE(0,DT_UNDEFINED);
	for(i=1; i < 4; i++){
		if(DT(arg[i]) == DT_REAL)
			reals_used++;
		else
			ARGTYPE(i,DT_INTEGER);
	}
	if(reals_used){
		for(i=1; i < 4; i++)
			if(DT(arg[i]) == DT_INTEGER){
				r = INTVAL(arg[i]);
				T_REAL(arg[i]) = newreal(r);
			}
	}
	c = newclass(DT_INTERVAL, 0);
	c->class_elements[0] = ARG1;
	c->class_elements[1] = ARG2;
	c->class_elements[2] = ARG3;
	return(c);
}

SUBR ARRAY F_IVnext(){
	register CLASS c;

	ARGTYPE(0,DT_INTERVAL);
	c = T_CLASS(ARG0);
	if(DT(c->class_elements[0]) == DT_INTEGER){
		register int cur, from, to, by;
		INTEGER n;

		from = T_INTEGER(c->class_elements[0])->int_val;
		to   = T_INTEGER(c->class_elements[1])->int_val;
		by   = T_INTEGER(c->class_elements[2])->int_val;
		if(DT(ARG1) == DT_UNDEFINED)
			cur = from;
		else
			cur = INTVAL(ARG1) + by;
		if((by >= 0) ? (cur <= to) : (cur >= to)){
			n = newinteger(cur);
			return(ret2(n, n));
		} else
			FAIL;
	} else
	if(DT(c->class_elements[0]) == DT_REAL){
		double cur, from, to, by;
		REAL r;

		from = T_REAL(c->class_elements[0])->real_val;
		to   = T_REAL(c->class_elements[1])->real_val;
		by   = T_REAL(c->class_elements[2])->real_val;
		if(DT(ARG1) == DT_UNDEFINED)
			cur = from;
		else
			cur = T_REAL(ARG1)->real_val + by;
		if((by >= 0) ? (cur <= to) : (cur >= to)){
			r = newreal(cur);
			return(ret2(r, r));
                } else
                        FAIL;
	} else
		syserror("interval.next");
}


struct subr IVnext;

iv_init(){
	extern struct fld f_next;

	DCLSUBR(IVnext,F_IVnext,&f_next,cvt_array);
}
