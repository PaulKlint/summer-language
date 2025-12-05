#
/*
 * Summer -- miscellaneous built-in functions
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include	"summer.h"


#define SORT_BUG_FIXED 1
#ifdef SORT_BUG_FIXED
/*
 * The following code is erroneous and is temporarily replaced
 * by a call to the standard C-library qsort routine
 */
/*
 * The following sort routine used quicksort as basic sorting strategy
 * and a final insertion sort pass for final unsorted subranges of
 * the array to be sorted. See R. Sedgewick, "Implementing quicksort
 * programs" CACM 21(1978) 10 847-857. for a complete discussion of
 * this algorithm.
 */
ARRAY sortar;
#define A(i)	sortar->ar_elements[i]
exchange(i, j){
	register SUMDP tmp;

	tmp = A(i);
	A(i) = A(j);
	A(j) = tmp;
}

ARRAY _sort(){
	register int i, j;
	register SUMDP v;
	int l, r, N, M = 10;
	int stack[40], *sp;		/* allows N <= 10**6 */
	int done;
	
	ARGCNT(1);
	ARGTYPE(0,DT_ARRAY);
	sortar = T_ARRAY(ARG0);
	N = sortar->ar_size;
	l = 0; r = N - 1; done = (N <= M);
	sp = stack;
#define QQEMPTY sp == stack
#define QQPUSH(l,r) {*sp++ = l; *sp++ = r;}
#define QQPOP(l,r)  {r = *--sp; l = *--sp;}
	
done=1;
	while (done == 0) {
		exchange((l + r) / 2, l + 1);
		if(compare(A(l + 1), A(r), 0) == GREATER)
			exchange(l + 1, r);
		if(compare(A(l), A(r), 0) == GREATER)
			exchange(l, r);
		if(compare(A(l + 1), A(l), 0) == GREATER)
			exchange(l + 1, l);
		i = l + 1; j = r; v = A(l);
		do {
			do
				i++;
			while ((i < N) && (compare(A(i), v, 0) == LESS));
			do
				j--;
			while (compare(A(j), v, 0) == GREATER);
			if(j < i)
				break;
			else
				exchange(i, j);
		} while(1);
		exchange(l, j);
		if(max(j - l, r - i + 1) <= M){
			if(QQEMPTY)
				done = 1;	/* stack empty */
			else {
				QQPOP(l,r);
			}
		} else {
			if(j - l >= r - i + 1){
				/* large subfile (l, j - 1) */
				r = j - 1;
			} else {
				QQPUSH(l,j-1);
				/* small subfile (i, r) */
				l = i;
			}
		}
	}
	/* final insertion sort pass */
	for(i = N - 2; i >= 0; i--){
		if(compare(A(i), A(i + 1), 0) == GREATER){
			v = A(i);
			j = i + 1;
			do {
				A(j - 1) = A(j);
				j++;
			} while ((j < N) && (compare(A(j), v, 0) == LESS));
			A(j - 1) = v;
		}
	}
	return(sortar);
}
#else
/*
 * here follows the temporary fix.
 */
int qcompare(x, y)
SUMDP *x; SUMDP *y;{
	return(compare(*x, *y, 0));
}

ARRAY _sort(){
	ARRAY ar;

	ARGCNT(1);
	ARGTYPE(0,DT_ARRAY);
	ar = T_ARRAY(ARG0);
	qsort(ar->ar_elements, ar->ar_size, SZ_SUMDP, qcompare);
	return(ar);
}
#endif

SUBR ARRAY _keys(){
	struct tabsym *ts;
	struct array *a;
	struct table *t;
	int i, n, pass;

	ARGCNT(1);
	ARGTYPE(0,DT_TABLE);
	t = T_TABLE(ARG0);
	pass = 0;
loop:
	n = 0;
	for(i = 0; i < t->tab_size; i++)
		for(ts = t->tab_elements[i]; ts != NIL; ts = ts->tsym_next)
			if(T_DATATYPE(ts->tsym_val) != T_DATATYPE(t->tab_default)){
				if(pass == 0)
					n++;
				else
					a->ar_elements[n++] = ts->tsym_key;
			}
	if(pass == 1){
		call(1, _sort, a);
		return(a);
	} else {
		a = newarray(n, &undefined);
		t = T_TABLE(ARG0);	/* may have been destroyed by gc */
		pass++;
		goto loop;
	}
}

SUBR _stop(){
	SUMDP p;
	SUMDP b;
	SUMDP e;
	ARGCNT(1);
	ARGTYPE(0,DT_INTEGER);
#ifdef EVSTATS
	ev_halt();
#endif
	vm_anormal();
	p = floor;
	while(T_DATATYPE(p) < T_DATATYPE(surf)){
		if(DT(p) == DT_FILE)
			flflush(T_FILE(p));
		limits(p, &b, &e);
		p = e;
	}
	if(INTVAL(ARG0) < 0){
		printstack();
		INTVAL(ARG0)  = - INTVAL(ARG0);
	}
	if(profiling)
		profprint();
	flflush(stand_out);
	flflush(stand_er);
	exit(INTVAL(ARG0));
}

SUBR INTEGER _system(){
	STRING s;
	int n, res;
	char terminator;

	ARGCNT(1);
	ARGTYPE(0,DT_STRING);
	s = T_STRING(ARG0);
	n = s->str_size;
	terminator = s->str_contents[n];
	s->str_contents[n] = '\0';
	res = system(s->str_contents);
	s->str_contents[n] = terminator;
	return(newinteger(res));
}


struct trans {
	SUMDP	old;
	SUMDP	new;
} *transtab;

SUBR DATATYPE _copy(){
	extern SUMDP pcopy();
	SUMDP p;

	ARGCNT(1);
/*prval(ARG0, -500); putstring("\n");*/
	transtab = Gevalsp.sp_trans;
	p = pcopy(ARG0);
	Gevalsp.sp_trans = transtab;
	return(T_DATATYPE(p));
}

DATATYPE seen_before(p)
SUMDP p;{
	register struct trans *t;

        for(t = transtab; t < Gevalsp.sp_trans; t++)
		if(T_DATATYPE(t->old) == T_DATATYPE(p))
			return(T_DATATYPE(t->new));
	return(CAST(DATATYPE) NIL);
}

int copy_all  = 0;

SUMDP pcopy(p)
SUMDP p;{
	SUMDP new;
	register struct trans *t;
	int i, n;
/*prval(p, -3); putstring("\n");*/
	SPCHECK(5);
	switch(DT(p)){

	case DT_INTEGER:
		if(copy_all){
			INTEGER r;
			r = CAST(INTEGER) alloc(SZ_INTEGER);
			r->dt.dt_val = DT_INTEGER;
			r->int_val = T_INTEGER(p)->int_val;
			T_INTEGER(p) = r;
		}
		goto ret;
	case DT_REAL:
		if(copy_all)
			T_REAL(p) = newreal(T_REAL(p)->real_val);
		goto ret;
	case DT_STRING:
		if(copy_all){
			STRING s = T_STRING(p);
			STRING ns;
			n = s->str_size;
			ns = newstring(n);
			copy(s->str_contents, &s->str_contents[n], ns->str_contents);
			T_STRING(p) = ns;
		}
		goto ret;
	case DT_UNDEFINED:
		goto ret;
	case DT_SUBR:
	case DT_PROC:
	case DT_FILE:		/*is this correct ? */
		if(copy_all)
			error("subr, proc or file in binary transput");
	ret:
		return(p);

	case DT_BITS:
		n = T_BITS(p)->bits_size;
		PUSHSUMDP(Gevalsp,p);
		T_BITS(new) = newbits(n, 0);
		p = POP(Gevalsp);
		n = (n + BPW) / BPW;	/* # bits -> # words */
		for(i = 0; i < n; i++)
			T_BITS(new)->bits_elements[i] = T_BITS(p)->bits_elements[i];
		return(new);
	case DT_ARRAY:
		if((T_DATATYPE(new) = seen_before(p)) != NIL)
			return(new);
		n = T_ARRAY(p)->ar_size;
		t = Gevalsp.sp_trans;
		Gevalsp.sp_trans++;
		t->old = p;
		t->new = undefined;
		T_ARRAY(t->new) = newarray(n, &undefined);
		T_ARRAY(t->new)->ar_fill = T_ARRAY(t->old)->ar_fill;
		n = (n == 0) ? 1 : n;
		for(i = 0; i < n; i++)
			T_ARRAY(t->new)->ar_elements[i] =
			pcopy(T_ARRAY(t->old)->ar_elements[i]);
		return(t->new);
	case DT_TABLE:
		if((T_DATATYPE(new) = seen_before(p)) != NIL)
			return(new);
		n = T_TABLE(p)->tab_size;
		t = Gevalsp.sp_trans;
		Gevalsp.sp_trans++;
		t->old = p;
		t->new = undefined;
		T_TABLE(t->new) = newtable(n, &undefined, 1);
		T_TABLE(t->new)->tab_default = T_TABLE(t->old)->tab_default;
		for(i = 0; i < n; i++)
			if(T_TABLE(t->old)->tab_elements[i] != NIL){
				register SUMDP q;
				q = pcopy(T_TABLE(t->old)->tab_elements[i]);
				T_TABLE(t->new)->tab_elements[i] = T_TABSYM(q);
			}
		return(t->new);
	case DT_TABSYM:
		if((T_DATATYPE(new) = seen_before(p)) != NIL)
			return(new);
		t = Gevalsp.sp_trans;
		Gevalsp.sp_trans++;
		t->old = p;
		t->new = undefined;
		T_TABSYM(t->new) = CAST(TABSYM) alloc(SZ_TABSYM);
		DT(t->new) = DT_TABSYM;
		T_TABSYM(t->new)->tsym_key = T_TABSYM(t->old)->tsym_key;
		T_TABSYM(t->new)->tsym_next = NIL;
		/*
		 * Following assignment ensures that all components of the
		 * tabsym object are defined before pcopy is called recursively.
		 */
		T_TABSYM(t->new)->tsym_val = undefined;
		if(copy_all)
			T_TABSYM(t->new)->tsym_key =
				pcopy(T_TABSYM(t->old)->tsym_key);
		T_TABSYM(t->new)->tsym_val = pcopy(T_TABSYM(t->old)->tsym_val);
		if(T_TABSYM(t->old)->tsym_next != NIL){
			register SUMDP q;
			q = pcopy(T_TABSYM(t->old)->tsym_next);
			T_TABSYM(t->new)->tsym_next = T_TABSYM(q);
		}
		return(t->new);
	default:
		if(DT(p) < nclasses){
			if((T_DATATYPE(new) = seen_before(p)) != NIL)
				return(new);
			n = class_sizes[DT(p)];
			t = Gevalsp.sp_trans;
			Gevalsp.sp_trans++;
			t->old = p;
			t->new = undefined;
			T_CLASS(t->new) = newclass(DT(p), 0);
			/*
			 * First initialize the new instance, before
			 * pcopy is called recursively. Necessary for
			 * the case that a garbage collection occurs
			 * during this recursion.
			 */
			for(i = 0; i < n; i++)
				T_CLASS(t->new)->class_elements[i] = undefined;
			for(i = 0; i < n; i++)
				T_CLASS(t->new)->class_elements[i] =
				pcopy(T_CLASS(t->old)->class_elements[i]);
			return(t->new);
		} else
			syserror("copy -- illegal datatype");
	}
}

SUBR STRING _type(){
	ARGCNT(1);
	return(class_names[DT(ARG0)]);
}
SUBR STRING F_fetcher(){
	/*
	 * Remove indication that last procedure call was to built-in
	 * procedure, to avoid that "fetcher" call appears in stack dump.
	 */
	cursubr = NIL;
	error("field %f of %t object may not be inspected", fld->fld_name, ARG0);
	return(nullstring);
}

SUBR STRING F_storeer(){
	cursubr = NIL;
	error("assignment to field %f of %t object not allowed", fld->fld_name, ARG0);
	return(nullstring);
}

ARRAY ret2(x, y)
SUMDP x;
SUMDP y;{

	ar2->ar_elements[0] = x;
	ar2->ar_elements[1] = y;
	return(ar2);
}
struct subr fetcher, storeer;

subr_init(){
	DCLSUBR(fetcher,F_fetcher,NIL,cvt_string);
	DCLSUBR(storeer,F_storeer,NIL,cvt_string);
}
