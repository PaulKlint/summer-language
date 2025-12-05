#
/*
 * Summer -- print procedures.
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include 	"summer.h"



STRING findname(v)
SUMDP v;{
	extern SUMDP globals[];
	extern SUMDP eglobals;
	extern STRING globnames[];
	register SUMDP *g;
	struct fld *f;

	if((DT(v) == DT_PROC) && ((f = T_PROC(v)->proc_fld) != NIL))
		if(f == CAST(struct fld *) -1)
			goto isglob;
		else
			return(f->fld_name);
        if((DT(v) == DT_SUBR) && ((f = T_SUBR(v)->subr_fld) != NIL))
		if(f == CAST(struct fld *) -1)
			goto isglob;
		else
	                return(f->fld_name);
isglob:
	for(g = globals; g < &eglobals; g++)
		if(T_DATATYPE(*g) == T_DATATYPE(v))
			return(globnames[g - globals]);
	return(Squestion);
}

STRING findclassname(p)
struct proc *p;{
	register int i, j, k;
	register struct fldentry *f;

	for(i = 0; i < nfields; i++)
		for(j = 0; j < nclasses; j++){
			k = fields[i]->fld_switch[j];
			if(k < 0)
				continue;
			f = &fields[i]->fld_entries[k];
			if((f->fldent_type == p) ||
			   (f->fldent_fetch == p) || (f->fldent_store == p))
				return(class_names[j]);
		}
	return(Squestion);
}

printstack(){
	register struct stack  *s;
	struct stack *prevs;
	register struct proc *p;
	int from, to;

	lino(cursp->stk_proc, cursp->stk_pc, &from, &to);
	printlino(from, to);
	if(cursubr != NIL)
		printcall(cursubr, arg, argcnt, 0);
	else {
		putstring("in procedure ");
		prname(findname(cursp->stk_proc), 0);
		put1(Snl);
	}
	for(s = cursp; !inter_catched && s != NIL; s = s->stk_prev){
		prevs = s->stk_prev;
		if(prevs != NIL)
			lino(prevs->stk_proc, prevs->stk_pc, &from, &to);
		else
			from = to = s->stk_proc->proc_lino;
		printlino(from, to);
		p = s->stk_proc;
		printcall(p, &((CAST(SUMDP *) s)[-p->proc_ntot]), p->proc_nform, 0);
	}
}

prname(nm, quotes) STRING nm; int quotes;{
	int i;
	char c;

	if(quotes)
		put1(Squote);
	for(i=0; i< nm->str_size; i++){
		c = nm->str_contents[i];
		if(c == '.')
			/*
			 * prevent ".1" and ".2" suffices in
			 * operator names from being printed.
			 */
			break;
		else
			fputc(stand_out, c);
	}
	if(quotes)
		put1(Squote);
	flflush(stand_out);
}

printint(n)
int n;{
	struct integer numb;

	numb.dt.dt_val = DT_INTEGER;
	numb.int_val = n;
	put1(&numb);
}

printlino(from, to){
	printint(from);
	if(to - from > 1){
		put1(Sminus);
		printint(to);
	}
	putstring(":\t");
}

ignore(p, name)
struct proc *p;
STRING *name;{
	TABSYM ts;

	if((p->proc_fld != NIL) && (p->proc_fld != CAST(struct fld *) -1)){
		*name = p->proc_fld->fld_name;
		ts = tablelook(&calltab, name, FETCHARRAY);
		if(((ts == NIL) ||
		    (T_DATATYPE(ts->tsym_val) == T_DATATYPE(undefined)))
		   && (calltrace == 1))
			return(1);
		else
			return(0);
	} else {
		*name = findname(p);

		ts = tablelook(&calltab, name, FETCHARRAY);
		if(((ts == NIL) ||
		    (T_DATATYPE(ts->tsym_val) == T_DATATYPE(undefined)))
		   && (calltrace == 1))
			return(1);
		else
			return(0);
	}
}

prindent(delta){
	register int i;

	if(delta == 0)
		return;
	if(delta > 0)
		indent++;
	for(i = 0; i < indent; i++)
		fputc(stand_out, '-');
	if(delta < 0)
		indent--;
}

printcall(p, alist, nargs, dindent)
struct proc *p; SUMDP *alist; int nargs;{
	register int firstarg = 0, i;
	STRING name;
	int ign = ignore(p, &name);

	if(calltrace && (dindent != 0) && ign)
			return;
	prindent(dindent);
	if((p->proc_fld != NIL) && (p->proc_fld != CAST(struct fld *) -1)){
		/*
		 * a field procedure
		 */
		prval(alist[0], 0);
		firstarg = 1;
		putstring(".");
	} else {
		if(p->proc_fld != NIL)
			/*
			 * Skip first arg in class creation procedure.
			 */
			firstarg = 1;
	}
	prname(name, 0);
	putstring("(");
	for(i = firstarg; i < nargs; i++){
		SUMDP aval = alist[i];
		if(i > firstarg)
			put1(Scomma);
		prval(aval, 0);
	}
	putstring(")\n");
}

printret(p, val, rtype)
struct proc *p; SUMDP val; int rtype;{
	STRING name;

	if(!ignore(p, &name)){
		prindent(-1);
		if(p->dt.dt_val == DT_PROC){
			prname(name, 0);
			putstring(" ");
		}
		if(rtype == 0)
			putstring(" fails");
		else {
			putstring("returns ");
			if(rtype == 1)
				prval(val, 0);
			else
				putstring("void");
		}
		put1(Snl);
	}
}

#define PRINTLIM 3
prval(v, level)
SUMDP v;{
	STRING name;
	register int i, n;
	register SUMDP *r;
	char c;

	switch(DT(v)){

	case DT_INTEGER:
	case DT_REAL:
		put1(v); break;
	case DT_STRING:
		put1(Squote);
		n = T_STRING(v)->str_size;
		for(i = 0; i < n; i++){
			c = T_STRING(v)->str_contents[i];
			if(c == '\t')
				putstring("\\t");
			else
			if(c == '\n')
				putstring("\\n");
			else
			if(c == '\\')
				putstring("\\\\");
			else
			if(c == '\'')
				putstring("''");
			else
				fputc(stand_out, c);
		}
		put1(Squote);
		break;
	case DT_TABLE:
		prtable(T_TABLE(v), level+1);
		break;
	case DT_ARRAY:
		r = T_ARRAY(v)->ar_elements;
		n = T_ARRAY(v)->ar_size;
	casearray:
		put1(Slbrack);
		if(level < PRINTLIM){
			int previ = 0, nprinted = 0, equal;
			int iter;
			SUMDP val1, val2;

			for(i=0;(i < n) && (nprinted < PRINTLIM); i++){
				val1 = r[previ];
				val2 = r[i];
				if(compare(val1, val2, 1) == EQUAL)
					equal=1;
				else
					equal=0;
				if((i < n-1) && equal)
					continue;
				iter = i - previ;
				if((i == n-1) && equal)
					iter++;
				if(iter > 1){
					printint(iter);
					putstring("*");
				}
				val1 = r[previ];
				prval(val1, level + 1);
				nprinted++;
				if(i < n-1)
					putstring(",");
				else
				if(!equal){
					putstring(",");
					val1 = r[i];
					prval(val1, level + 1);
				}
				previ = i;
			}
			if(i < n)
				putstring("...");
		} else
			putstring("...");
		put1(Srbrack);
		break;
	case DT_BITS:
		putstring("bits[...]");
		break;
	default:
		n = DT(v);
		if((n > DT_LAST) && (n < nclasses)){
			prname(class_names[n], 0);
			n = class_sizes[n];
			r = T_CLASS(v)->class_elements;
			goto casearray;
		}
		name = findname(v);
		printdt(v);
		if((name != Squestion) && (DT(v) != DT_UNDEFINED)){
			putstring(" ");
			prname(name, 0);
		}
		break;
	}
}

printdt(v)
SUMDP v;{
	int n;

	put1(Squote);
	n = DT(v);
	if((n < 0) || (n >= nclasses))
		putstring("ILLEGAL DATATYPE");
	else
		prname(class_names[n], 0);
	put1(Squote);
}

prtable(v, level)
TABLE v;{
	register int i, first, nelem = 0;
	register TABSYM t;

	if(level >= PRINTLIM){
		putstring("table[...]");
		return;
	}
	first = 1;
	for(i = 0; i < v->tab_size; i++){
		t = v->tab_elements[i];
		while(t != NIL){
			if(first){
				put1(Slbrack);
				first = 0;
			} else
				put1(Scomma);
			prval(t->tsym_key, level + 1);
			putstring(":");
			prval(t->tsym_val, level + 1);
			t = t->tsym_next;
			nelem++;

			if(nelem >= PRINTLIM){
				putstring(",...");
				goto done;
			}
		}
	}
done:
	if(first)
		putstring("table[");
	put1(Srbrack);
}
