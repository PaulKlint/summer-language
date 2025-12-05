#
/*
 * SUMMER -- array
 */

#include "summer.h"

/*
 * Class creation is handled by the IC_ARINIT instruction.
 * See eval.c
 * The array datatype supports the following operations:
 *	a.update(i,v)	replace value at index i by v.
 *	a.retrieve(i)	get value at index i.
 *	a.index		index set of array.
 *	a.next		delivers next element.
 *	a.size		# of elements
 *	a.sort		returns new array with sorted values.
 * Additional operations for "flexible" arrays are as follows:
 *	a.append(v)	append value v to right end of array
 *	a.delete	delete right hand value
 *	a.last		returns right hand value
 * The latter are implemented as linked lists of arrays.
 * Arrays may grow arbitrarily by push operations. As soon as the original
 * size N of the array is reached, a new array is created and assigned to
 * element N-1 of the original array. References that exceed the original
 * size are forwarded to this newly created array.
 * The following conditions hold:
 * fill is used to indicate the filling of the current chunk.
 */

#define HAS_OVERFLOW(a)	a->ar_fill > a->ar_size

#define ARLOCATE \
	if((n < 0) || (n >= a->ar_fill)) {\
	er:\
		error("array bounds exceeded");\
	}\
	if(!HAS_OVERFLOW(a))\
		goto ok;\
	last = max(0, a->ar_size - 1);\
	last = min(last, a->ar_fill - 1);\
	if(n >= last) {\
		if(HAS_OVERFLOW(a)){\
			register int base;\
			base = a->ar_fill - 1;\
			a = T_ARRAY(a->ar_elements[last]);\
			if(a->ar_fill >= a->ar_size)\
				base -= a->ar_size - 1;\
			else\
				base -= a->ar_fill;\
			while(n < base){\
				a = T_ARRAY(a->ar_elements[a->ar_size - 1]);\
				base -= a->ar_size - 1;\
			}\
			n -= base;\
		} else\
		if(n != last)\
			goto er;\
	}\
ok:

SUBR DATATYPE F_Aupdate(){
	register int n, sz, last;
	register ARRAY a;

	ARGCNT(3);
	ARGTYPE(0,DT_ARRAY);
	ARGTYPE(1,DT_INTEGER);
	n = INTVAL(ARG1);
	a = T_ARRAY(ARG0);
	ARLOCATE;
	T_ARRAY(ARG0) = a;
	if((curcache != NIL) && INRECFLOAT(ARG0)){
		register SUMDP *p1;
		register SUMDP *p2;

		p1 = CAST(SUMDP *) T_DATATYPE(ARG0);
		p2 = &a->ar_elements[n];
		save_in_cache(ARG0, p2 - p1);
	}
	a->ar_elements[n] = ARG2;
	return(T_DATATYPE(ARG2));
}

SUBR DATATYPE F_Aretrieve(){
	register int n, sz, last;
	register ARRAY a;

	ARGCNT(2);
	ARGTYPE(0,DT_ARRAY);
	ARGTYPE(1,DT_INTEGER);
	n = INTVAL(ARG1);
	a = T_ARRAY(ARG0);
	ARLOCATE;
	return(T_DATATYPE(a->ar_elements[n]));
}

SUBR ARRAY F_Aindex(){
	register int n;
	ARRAY a;
	extern CLASS _interval();

	ARGCNT(1);
	ARGTYPE(0,DT_ARRAY);
	a = T_ARRAY(ARG0);
	n = ar_size(a) - 1;
	T_INTEGER(ARG0) = newinteger(n);	/* use ARG0 as safe loc */
	return(CAST(ARRAY) call(4, _interval, undefined, ZERO, ARG0, ONE));
}

ar_size(a) ARRAY a;{

	if(a->ar_fill > a->ar_size)
		return(a->ar_fill - 1);
	else
		return(a->ar_fill);
}

SUBR ARRAY F_Anext(){
	register int n, sz;
	ARRAY a;

	ARGTYPE(0,DT_ARRAY);
	if(DT(ARG1) == DT_UNDEFINED){
		n = 0;
		T_INTEGER(ARG1) = ZERO;
	} else {
		ARGTYPE(1,DT_INTEGER);
		n = INTVAL(ARG1);
	}
	a = T_ARRAY(ARG0);
	sz = ar_size(a);
	if((n < 0) || (n >= sz))
		FAIL;
	else {
		if(!HAS_OVERFLOW(a))
			ar2->ar_elements[0] = a->ar_elements[n];
		else
			T_DATATYPE(ar2->ar_elements[0]) = F_Aretrieve();
		T_INTEGER(ARG0) = newinteger(n + 1);	/* use ARG0 as safe loc */
		ar2->ar_elements[1] = ARG0;
		return(ar2);
	}
}

SUBR INTEGER F_Asize(){
	ARGCNT(1);
	ARGTYPE(0,DT_ARRAY);
	return(newinteger(ar_size(T_ARRAY(ARG0))));
}

ARRAY F_Asort(){
	extern ARRAY _sort();

	return(_sort());
}

SUBR DATATYPE F_Aappend(){
	ARRAY cur;
	ARRAY new;
	ARRAY head;
	register int n, sz, hlast;

	ARGCNT(2);
	ARGTYPE(0,DT_ARRAY);
	head = cur = T_ARRAY(ARG0);

	hlast = max(0, head->ar_size - 1);
	if(HAS_OVERFLOW(head)){
		cur = T_ARRAY(head->ar_elements[hlast]);
		if(cur->ar_fill == cur->ar_size - 1){
			/* overflow of an overflow array */
			new = newarray(max(20, head->ar_fill/2), &undefined);
			head = T_ARRAY(ARG0);
			cur = T_ARRAY(head->ar_elements[hlast]);
			T_ARRAY(new->ar_elements[new->ar_size-1]) = cur;
			new->ar_fill = 1;
			n = 0;
			head->ar_fill++;
			T_ARRAY(head->ar_elements[hlast]) = new;
			cur = new;
		} else {
			n = (cur->ar_fill)++;
			head->ar_fill++;
		}
	} else {
		if(head->ar_fill == head->ar_size){
			/* have to create new chunk */
			new = newarray(max(20, head->ar_fill/2), &undefined);
			/* overflow of original array */
			/* first restore values after garbage collection */
			head = cur = T_ARRAY(ARG0);
			new->ar_elements[0] = head->ar_elements[hlast];
			new->ar_fill = 2;
			n = 1;
			head->ar_fill += 2;
			T_ARRAY(head->ar_elements[hlast]) = new;
			cur = new;
		} else
			n = (cur->ar_fill)++;
	}

	/* insert cache check here */
	cur->ar_elements[n] = ARG1;
	return(T_DATATYPE(ARG1));
}

DATATYPE lastdel(delta){
	ARRAY cur;
	ARRAY head;
	register int sz, last;
	SUMDP v;

	ARGCNT(1);
	ARGTYPE(0,DT_ARRAY);
	head = cur = T_ARRAY(ARG0);
	if(ar_size(head) <= 0)
		error("last or delete operation on empty array");
	sz = head->ar_size;
	if(HAS_OVERFLOW(head)){
		last = max(0, sz - 1);
		cur = T_ARRAY(head->ar_elements[last]);
		sz = cur->ar_size;
	}
	last = max(0, sz - 1);
	v = cur->ar_elements[cur->ar_fill - 1];
	cur->ar_fill -= delta;
	if(cur != head)
		head->ar_fill -= delta;
	if(cur->ar_fill == 0) {
		/* this chunks becomes empty */
		if(head != cur){
			/* this is an overflow record */
			if(head->ar_fill == head->ar_size)
				/* the last overflow record in the chain */
				head->ar_fill = head->ar_size - 1;
			else {
				/* unlink this record from nonempty chain */
				cur = T_ARRAY(cur->ar_elements[last]);
				T_ARRAY(head->ar_elements[
					max(0, head->ar_size - 1)]) = cur;
				cur->ar_fill = cur->ar_size - 1;
			}
		}
	}
	return(T_DATATYPE(v));
}

SUBR DATATYPE F_Adelete(){
	return(lastdel(1));
}

SUBR DATATYPE F_Alast(){
	return(lastdel(0));
}

struct subr Aindex, Anext, Aretrieve, Asize, Asort, Aupdate;
struct subr Adelete, Aappend, Alast;

array_init(){
	extern struct fld f_index, f_next, f_retrieve, f_size, f_sort, f_update;
	extern struct fld f_append, f_delete, f_last;

	DCLSUBR(Aindex,F_Aindex,&f_index,cvt_array);
	DCLSUBR(Anext,F_Anext,&f_next,cvt_array);
	DCLSUBR(Aretrieve,F_Aretrieve,&f_retrieve,cvt_datatype);
	DCLSUBR(Asize,F_Asize,&f_size,cvt_integer);
	DCLSUBR(Asort,F_Asort,&f_sort,cvt_array);
	DCLSUBR(Aupdate,F_Aupdate,&f_update,cvt_datatype);
	DCLSUBR(Aappend,F_Aappend,&f_append,cvt_datatype);
	DCLSUBR(Adelete,F_Adelete,&f_delete,cvt_datatype);
	DCLSUBR(Alast,F_Alast,&f_last,cvt_datatype);
}
