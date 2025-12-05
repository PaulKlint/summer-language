#
/*
 * SUMMER -- table
 */

#include "summer.h"

/*
 * Class creation is handled by the IC_TABINIT instruction.
 * See eval.c
 */

SUBR DATATYPE F_Tupdate() {
	register TABSYM ts;
	register SUMDP s;

	ARGCNT(3);
	ARGTYPE(0,DT_TABLE);
#ifdef ATSTATS
        putstring("U:T:");put1(findname(ARG0));
        putstring(":"); printint(ARG0); putstring(":"); prval(ARG1, 1); putstring("\n");
#endif
	ts = tablelook(&ARG0, &ARG1, STOREARRAY);
	T_TABSYM(s) = ts;
	if((curcache != NIL) && INRECFLOAT(s)){
		register SUMDP *p1;
		register SUMDP *p2;

		p1 = CAST(SUMDP *) ts;
		p2 = &ts->tsym_val;
		save_in_cache(p1, p2 - p1);
	}
	ts->tsym_val = ARG2;
	return(T_DATATYPE(ARG2));
}

SUBR DATATYPE F_Tretrieve(){
	register TABSYM ts;

	ARGCNT(2);
	ARGTYPE(0,DT_TABLE);
#ifdef ATSTATS
        putstring("R:T:");put1(findname(ARG0));
        putstring(":"); printint(ARG0); putstring(":"); prval(ARG1, 1); putstring("\n");
#endif
	ts = tablelook(&ARG0, &ARG1, FETCHARRAY);
	if(ts == NIL)
		return(T_DATATYPE(T_TABLE(ARG0)->tab_default));
	else
		return(T_DATATYPE(ts->tsym_val));
}
SUBR ARRAY F_Tnext(){
	struct tabsym *t;
	int n;
	extern ARRAY _keys();

	ARGTYPE(0,DT_TABLE);

	if(DT(ARG1) == DT_UNDEFINED){
		T_DATATYPE(ARG1) = call(1, _keys, ARG0);
		n = 0;
	} else {
		ARGTYPE(1,DT_ARRAY);
		n = INTVAL(T_ARRAY(ARG1)->ar_elements[0]);
	}
nextelem:
	if(n < T_ARRAY(ARG1)->ar_size){
		t = tablelook(&ARG0, &T_ARRAY(ARG1)->ar_elements[n], 0);
		if(t == NIL){	/* element has been removed meanwhile */
			n++;
			goto nextelem;
		}
		ar2->ar_elements[0] = t->tsym_val;
		ar2->ar_elements[1] = ARG1;
		T_INTEGER(T_ARRAY(ARG1)->ar_elements[0]) = newinteger(n + 1);
		return(ar2);
	} else
		FAIL;
}
SUBR ARRAY F_Tindex(){
	extern CLASS _interval();
	ARRAY a;
	int i;

	ARGCNT(1);
	ARGTYPE(0,DT_TABLE);
	return(CAST(ARRAY) call(1, _keys, ARG0));
}

SUBR INTEGER F_Tsize(){
	register int i, n;
	register struct tabsym *t;
	register TABLE tab;

	ARGCNT(1);
	ARGTYPE(0,DT_TABLE);
	tab = T_TABLE(ARG0);
	n = 0;
	for(i = 0; i < tab->tab_size; i++)
		for(t = tab->tab_elements[i]; t != NIL; t=t->tsym_next)
			if(T_DATATYPE(t->tsym_val) != T_DATATYPE(tab->tab_default))
				n++;
	return(newinteger(n));
}
int hash(key)
SUMDP key;{

	switch(DT(key)){

	case DT_STRING: {
		register int i, n, ihash;

		register STRING s = T_STRING(key);

		ihash = n = min(s->str_size, MAXINT/NCHAR);
		for(i = 0; i < n; i++)
			ihash += s->str_contents[i] & 0177;
		return(ihash);
	}

	case DT_INTEGER:
		return(abs(INTVAL(key)));

	case DT_REAL:
		return(abs(T_REAL(key)->real_val));
	case DT_ARRAY:
		return(abs(DT_ARRAY << 4 + T_ARRAY(key)->ar_size));
	case DT_TABLE:
		return((DT_TABLE << 4 + T_TABLE(key)->tab_size));
	default:
		return(DT(key));
	}
}

int compare(v1, v2, eq)
register SUMDP v1; register SUMDP v2; int eq;{
	if(DT(v1) != DT(v2))
		return(DT(v1) < DT(v2) ? LESS : GREATER);
	switch(DT(v1)){

	case DT_STRING: {

		register int n = (eq) ? streq(T_STRING(v1), T_STRING(v2)) :
			                strcmp(T_STRING(v1), T_STRING(v2));
		return((n == 0) ? LESS : (n == 1) ? EQUAL : GREATER);
	}

	case DT_INTEGER: {
		register int a = INTVAL(v1), b = INTVAL(v2);

		return((a < b) ? LESS : (a == b) ? EQUAL : GREATER);
	}
	case DT_REAL: {
		double a = T_REAL(v1)->real_val, b = T_REAL(v2)->real_val;
		return((a < b) ? LESS : (a == b) ? EQUAL : GREATER);
	}
	default: {
		register DATATYPE t1 = T_DATATYPE(v1);
		register DATATYPE t2 = T_DATATYPE(v2);
		return(t1 < t2 ? LESS : (t1 == t2) ? EQUAL : GREATER);
	}
	}
}

TABLE prevtab;		/* previously accessed table */
SUMDP prevkey;		/* previous key */
TABSYM prevtabsym;	/* previous tablesym found */
int previndex;		/* index of previous bucket in table */

/*
 * Search "name" in table "tab".
 * If found return pointer to relevant tabsym.
 * If not and "enter" is zero return NIL.
 * Otherwise enter "name" in "tab".
 */

TABSYM tablelook(atab, akey, enter)
TABLE *atab;			/* *atab must be save */
SUMDP *akey;			/* *akey must be save */
int enter;{
	int  index;
	register TABSYM rp;
	TABLE tab;
	register SUMDP key;
	SUMDP *p1;
	SUMDP *p2;
	SUMDP s;

	tab = *atab;
	key = *akey;
#ifdef TABLEOPTIMIZER
	/*
	 * The following code attempts to prevent consequtive lookups
	 * of the same element in the same table, as occurs in
	 *	t[key] := t [key] + 1;
	 * Under certain circumstances is does however return the
	 * wrong element. A quick fix was to remove the optimizer
	 * completely. The code should be redesigned.
	 */
	if((prevtab == tab) && (T_DATATYPE(prevkey) == T_DATATYPE(key)))
		if((enter && (prevtabsym == NIL))){
			index = previndex;
			goto enter_tabsym;
		} else
			return(prevtabsym);
	else {
		prevtab = tab;
		prevkey = key;
	}
	
#endif
	previndex = index = hash(key) % tab->tab_size;
	for(rp = tab->tab_elements[index]; rp != NIL; rp = rp->tsym_next)
		if(compare(rp->tsym_key, key, 1) == EQUAL){
			prevtabsym = rp;
			return(rp);
		}
	if(enter == 0){
		prevtabsym = NIL;
		return(NIL);
	}
enter_tabsym:
	rp = CAST(TABSYM) alloc(SZ_TABSYM);
	rp->dt.dt_val = DT_TABSYM;
	rp->tsym_key = *akey;
	T_DATATYPE(rp->tsym_val) = NIL;
	tab = *atab;
	T_TABLE(s) = tab;
	if((curcache != NIL) && INRECFLOAT(s)){
		p1 = CAST(SUMDP *) tab;
		p2 = CAST(SUMDP *) &tab->tab_elements[index];
		save_in_cache(p1, p2 - p1);
		prevtabsym = NIL;
	} else
		prevtabsym = rp;
	rp->tsym_next = tab->tab_elements[index];
	tab->tab_elements[index] = rp;
	return(rp);
}

struct subr Tindex, Tnext, Tretrieve, Tsize, Tupdate;
table_init(){
	extern struct fld f_index, f_next, f_retrieve, f_size, f_update;

	DCLSUBR(Tindex,F_Tindex,&f_index,cvt_array);
	DCLSUBR(Tnext,F_Tnext,&f_next,cvt_array);
	DCLSUBR(Tretrieve,F_Tretrieve,&f_retrieve,cvt_datatype);
	DCLSUBR(Tsize,F_Tsize,&f_size,cvt_integer);
	DCLSUBR(Tupdate,F_Tupdate,&f_update,cvt_datatype);
}

table_mark(){
	prevtab = NIL;
	T_DATATYPE(prevkey) = NIL;
	prevtabsym = NIL;
}
