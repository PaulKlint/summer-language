#
/*
 * SUMMER -- bits
 */

#include "summer.h"

SUBR BITS _bits(){
	ARGCNT(3);
	ARGTYPE(1,DT_INTEGER);
	ARGTYPE(2,DT_INTEGER);
	return(newbits(INTVAL(ARG1), INTVAL(ARG2)));
}

SUBR BITS F_Bconj(){
	register int i, n, sizeb;
	struct bits *a, *b, *r;
	int maskb;


	ARGCNT(2);
	ARGTYPE(0,DT_BITS);
	ARGTYPE(1,DT_BITS);
	n = max(T_BITS(ARG0)->bits_size, T_BITS(ARG1)->bits_size);
	r = newbits(n, 0);
	if(T_BITS(ARG0)->bits_size == n){
		a = T_BITS(ARG0);
		b = T_BITS(ARG1);
	} else {
		a = T_BITS(ARG1);
		b = T_BITS(ARG0);
	}
	sizeb = b->bits_size;
	maskb = ~((1 << (sizeb%BPW)) - 1);
	sizeb = (sizeb + BPW) / BPW;	/* turn bit size into word size */
	n = (n + BPW) / BPW;		/* idem */

	for(i = 0; i < n; i++){
		r->bits_elements[i] = a->bits_elements[i] &
				((i < sizeb-1) ? b->bits_elements[i] :
				(i == sizeb-1) ? (b->bits_elements[i] | maskb) :
				~0);
	}
	return(r);
}

SUBR BITS F_Bdisj(){
        register int i, n, sizeb;
        struct bits *a, *b, *r;

        ARGCNT(2);
        ARGTYPE(0,DT_BITS);
        ARGTYPE(1,DT_BITS);
	a = T_BITS(ARG0);
	b = T_BITS(ARG1);
        n = max(a->bits_size, b->bits_size);
	r = newbits(n, 0);
        if(a->bits_size < n){
		struct bits *t;

		t = a; a = b; b = t;
        }
        sizeb = (b->bits_size + BPW) / BPW; /* size in words */
	n = (n + BPW) / BPW;

        for(i = 0; i < n; i++){
                r->bits_elements[i] = a->bits_elements[i] |
				((i < sizeb) ? b->bits_elements[i] : 0);
	}
	return(r);
}

SUBR BITS F_Bcompl(){
	register int i, n;
	struct bits *a, *r;

	ARGCNT(1);
	ARGTYPE(0,DT_BITS);
	n = T_BITS(ARG0)->bits_size;
	r = newbits(n, 0);
	a = T_BITS(ARG0);
	n = (n + BPW) / BPW;
	for(i = 0; i < n; i++)
		r->bits_elements[i] = ~a->bits_elements[i];
	return(r);
}
SUBR ARRAY F_Bnext(){
	int n;
	INTEGER val;
	ARGTYPE(0,DT_BITS);
	if(DT(ARG1) == DT_UNDEFINED)
		n = 0;
	else {
		ARGTYPE(1,DT_INTEGER);
		n = INTVAL(ARG1);
	}
	if(n < T_BITS(ARG0)->bits_size){
		if(T_BITS(ARG0)->bits_elements[n/BPW] & (1 << (n%BPW)))
			val = ONE;
		else
			val = ZERO;
		return(ret2(val, newinteger(n + 1)));
	} else
		FAIL;
}

SUBR INTEGER F_Bsize(){
	ARGCNT(1);
	ARGTYPE(0,DT_BITS);
	return(newinteger(T_BITS(ARG0)->bits_size));
}
SUBR DATATYPE F_Bupdate(){
	register int n, rhs;
	register BITS b;

	ARGCNT(3);
	ARGTYPE(0,DT_BITS);
	ARGTYPE(1,DT_INTEGER);
	ARGTYPE(2,DT_INTEGER);
	b = T_BITS(ARG0);
	n = INTVAL(ARG1);
	if((n < 0) || (n >= b->bits_size))
		error("%v exceeds size of 'bits' value", ARG1);
	rhs = INTVAL(ARG2);
	if(curcache != NIL){
		struct cache *c, *ctop;
		SUMDP sb;

		ctop = cachetop;
		T_BITS(sb) = b;
		c = save_in_cache(sb, n);
		if(ctop != cachetop){
			/*
			 * A new cache entry was added.
			 */
			T_INTEGER(c->val_old) =
				((b->bits_elements[n/BPW] & (1 << (n%BPW))) != 0)
				? ONE : ZERO;
		}
	}
	if(rhs == 0)
		b->bits_elements[n/BPW] &= ~(1 << (n%BPW));
	else
	if(rhs == 1)
		b->bits_elements[n/BPW] |= (1 << (n%BPW));
	else
		error("%v can not be assigned to 'bits'", ARG2);
	return(T_DATATYPE(ARG2));
}

SUBR DATATYPE F_Bretrieve(){
	register int n;
	register BITS b;
	register int bpw = BPW;

	ARGCNT(2);
	ARGTYPE(0,DT_BITS);
	ARGTYPE(1,DT_INTEGER);
	b = T_BITS(ARG0);
	n = INTVAL(ARG1);
	if((n < 0) || (n >= b->bits_size))
		error("%v exceeds size of 'bits'", ARG1);
	if(b->bits_elements[n/bpw] & (1 << (n%bpw)))
		return(CAST(DATATYPE) ONE);
	else
		return(CAST(DATATYPE) ZERO);
}

SUBR ARRAY F_Bindex(){
	register int n;
	extern CLASS _interval();

	ARGCNT(1);
	ARGTYPE(0,DT_BITS);
	n = T_BITS(ARG0)->bits_size - 1;
	T_INTEGER(ARG0) = newinteger(n);	/* use ARG0 as safe loc */
	return(CAST(ARRAY) call(4, _interval,undefined, ZERO, ARG0, ONE));
}
struct subr Bconj, Bcompl, Bdisj, Bindex, Bnext, Bretrieve, Bsize, Bupdate;

bits_init(){
	extern struct fld f_conj, f_compl, f_disj, f_index, f_next,
		      f_retrieve, f_size, f_update;
	DCLSUBR(Bconj,F_Bconj,&f_conj,cvt_bits);
	DCLSUBR(Bcompl,F_Bcompl,&f_compl,cvt_bits);
	DCLSUBR(Bdisj,F_Bdisj,&f_disj,cvt_bits);
	DCLSUBR(Bindex,F_Bindex,&f_index,cvt_array);
	DCLSUBR(Bnext,F_Bnext,&f_next,cvt_array);
	DCLSUBR(Bretrieve,F_Bretrieve,&f_retrieve,cvt_datatype);
	DCLSUBR(Bsize,F_Bsize,&f_size,cvt_integer);
	DCLSUBR(Bupdate,F_Bupdate,&f_update,cvt_datatype);
}
