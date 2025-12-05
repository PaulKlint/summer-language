#
/*
 * Summer -- symbolic tracer.
 */

#include	"summer.h"

struct proc *curproc, *stopproc;
struct fld *stopfld = NIL;
struct class *prog_subject;	/* active subject of traced program */
struct class *t_s;		/* subject used by tracer */
				/* traced program. */
STRING curname;
int linefrom	= 0;	/* lino of first line to be traced */
int lineto	= 30000;	/* lino of last lino to be traced */
int linerep;		/* breakpoint counter in [linefrom, lineto] */
int lineabs	= 1;	/* 1 => absolute line numbers */
			/* 0 => line numbers relative to current procedure */

extern struct string * F_SCany(), *F_SCspan(), *F_SCbreak(), *_get(), *F_SCrtab();
extern SUMDP F_Aretrieve();
extern SUMDP F_Tretrieve();
extern SUMDP F_Bretrieve();
extern SUMDP F_Sretrieve();
extern struct subr Aretrieve, Bretrieve, Tretrieve, Sretrieve;
extern _stop();
extern INTEGER _integer();
INTEGER numb();
STRING	str();
SUMDP	expr();
SUMDP	var();
SUMDP	getfield();

STRING Cany(sub, s)
CLASS sub;
STRING s;{
	return(CAST(STRING) call(2, F_SCany, sub, s));
}

STRING Cbreak(sub, s)
CLASS sub;
STRING s;{
	return(CAST(STRING) call(2, F_SCbreak, sub, s));
}

STRING Cspan(sub, s)
CLASS sub;
STRING s;{
	return(CAST(STRING) call(2, F_SCspan, sub, s));
}

STRING Crtab(sub, n)
CLASS sub;
INTEGER n;{
	return(CAST(STRING) call(2, F_SCrtab, sub, n));
}

peek(sub, s)
CLASS sub;
STRING s;{
	Cspan(sub, Slayout);
	if(Cany(sub, s) == NIL)
		return(NIL);
	else {
		T_INTEGER(sub->class_elements[1]) = subj_curs = newinteger(subj_curs->int_val - 1);
		return(1);
	}

}

peek1(sub, s)
CLASS sub;
STRING s;{
	Cspan(sub, Slayout);
	return(Cany(sub, s) != NIL);
}

tracer(pc)
char *pc;{
	int lnfrom, lnto;

	if(cursp->stk_proc->dt.dt_val != DT_PROC)
		syserror("tracer -- no proc");
	if(pc < cursp->stk_proc->proc_body)
		syserror("tracer -- pc out of range");

	lino(cursp->stk_proc, pc, &lnfrom, &lnto);
	if(!inter_catched && (linerep > 0)){
		if((stopproc != NIL) && (stopproc != cursp->stk_proc))
			return;
		if((stopfld != NIL) && (stopfld != cursp->stk_proc->proc_fld))
			return;
		if((lnto < lineabs * cursp->stk_proc->proc_lino + linefrom) ||
		   (lnfrom > lineabs * cursp->stk_proc->proc_lino + lineto) ||
		   (--linerep > 0))
			return;
	}
	intracer = 1;
	inter_catched = 0;
	linerep = 0;
	prog_subject = scan_subject;
	if(curproc != cursp->stk_proc){
		curproc = cursp->stk_proc;
		curname = findname(curproc);
	}
	if(lnfrom >= curproc->proc_lino){
		if((curproc->proc_fld != 0) &&
		   (curproc->proc_fld != CAST(struct fld *) -1)){
			put1(findclassname(curproc));
			putstring(".");
		}
		put1(curname);
	}
	if(lnfrom - curproc->proc_lino > 0){
		put1(Splus);
		put1(newinteger(lnfrom - curproc->proc_lino));
	}
	putstring(" (");
	put1(newinteger(lnfrom)); putstring(")\n");
nextline:
	putstring("* ");
	curline = CAST(STRING) call(1, _get, stand_in);
	if(curline == NIL)
		call(1, _stop, ZERO);
	else
	if(curline->str_size > 0){
		cmds(curline);
		put1(Snl);
		if(linerep == 0)
			goto nextline;
	}
	intracer = 0;
}

cmds(s)
STRING s;{
	register int i;
	extern struct class *_scan_string();

	t_s = CAST(CLASS) call(2, _scan_string, undefined, s);
	switchsubject(t_s);
	putstring("  ");
	while(cmd() != NIL){
		if(peek1(t_s, Ssemi)){
			put1(Ssemi);
			continue;
		} else
		if(subj_curs->int_val == subj_size){
			return(1);
		} else
			break;
	}
	put1(Snl);
	for(i = 0; i < subj_curs->int_val; i++)
		putstring(" ");
	putstring("  ^");
	return(0);
}

cmd(){
	if(peek(t_s, Sslash) || peek(t_s, Sdigit)){	/* line range command */
		return(linecmd());
	} else
	if(peek1(t_s, Sdollar))				/* special command */
		return(speccmd());
	else
	if(peek(t_s, Sexclam)){				/* call system */
		STRING syscmd = Crtab(t_s, newinteger(0));
		int i;

		for(i = 0; i < syscmd->str_size - 1; i++)
			syscmd->str_contents[i] = syscmd->str_contents[i + 1];
		syscmd->str_contents[i] = '\0';
		system(syscmd->str_contents);
		putstring("!");
		return(1);
	} else
	if(peek(t_s, Ssemi) || (subj_curs->int_val == subj_size))
		return(1);
	else {
		SUMDP v = expr();
		if(T_DATATYPE(v) == NIL)
			return(NIL);
		else {
			prval(v, 0);
			return(1);
		}
	}
}

linecmd(){
	INTEGER f;

	linerep = 0;
	if(peek1(t_s, Sslash)){
		if(!peek(t_s, Sslash)){
			SUMDP p = var(1);
			if(T_DATATYPE(p) == NIL)
				return(NIL);
		}
		if(peek1(t_s, Scomma)){
			if(peek(t_s, Scomma))
				linefrom = 0;
			else
			if((f = numb()) == NIL)
				return(NIL);
			else
				linefrom = f->int_val;
			if(peek1(t_s, Scomma))
				if((f = numb()) == NIL)
					return(NIL);
				else
					lineto = f->int_val;
			else
				lineto = 30000;
		}
		if(!peek1(t_s, Sslash))
			return(NIL);
		lineabs = 0;
	} else
	if((f = numb()) == NIL)
		return(NIL);
	else {
		linefrom = f->int_val;
		if(peek1(t_s, Scomma))
			if((f = numb()) == NIL)
				return(NIL);
			else
				lineto = f->int_val;
		else
			lineto = linefrom;
		lineabs = 1;
	}
	if(peek1(t_s, Scolon)){
		if((f = numb()) == NIL)
			return(NIL);
		linerep = f->int_val;
	} else
		linerep = 1;
	return(1);
}

speccmd(){

	if(peek1(t_s, Sequal)){
		Cspan(t_s, Slayout);
		if(subj_curs->int_val == subj_size)
			prval(storedcmd, 0);
		else
			storedcmd = Crtab(t_s, newinteger(0));
		return(1);
	} else
	if(peek(t_s, Sletgit)){
		STRING s;
		STRING name;
		TABSYM ts;
		int n;

		s = Cspan(t_s, Sletgit);
		if(streq(s, Scalls)){
			n = 0;
			calltrace = 1;
			while(peek(t_s, Sletter)){
				n++;
				name = Cspan(t_s, Sletgit);
				if(n == 1){
					if(streq(name, Soff)){
						calltrace = 0;
						return(1);
					} else
					if(streq(name, Sall)){
						calltrace = 2;
						return(1);
					} else {
						purgetable();
						calltrace = 1;
					}
				}
				ts = tablelook(&calltab, &name, STOREARRAY);
				T_INTEGER(ts->tsym_val) = ONE;
			}
			return(1);
		} else
		if(streq(s, Swhere)){
			put1(Snl); printstack(); return(1);
		} else
			return(NIL);
	} else {
		if(T_STRING(subj_text) == storedcmd){
			putstring("NESTED $");
			return(NIL);
		} else
			return(cmds(storedcmd));
	}
}

SUMDP expr(){
	register SUMDP v;
	register SUMDP e;
	register SUMDP r;
	int n;
	TABSYM ts;

	if(peek(t_s, Sdigit) || peek(t_s, Splusminus)){
		T_INTEGER(r) = numb();
		return(r);
	} else
	if(peek1(t_s, Squote)){
		T_STRING(r) = str();
		return(r);
	} else {
		v = var(0);
		if(T_DATATYPE(v) == CAST(DATATYPE) NIL)
			goto er;
	}
	if(peek1(t_s, Slbrack)){
		PUSHSUMDP(Gevalsp,v);
		e = expr();
		if(T_DATATYPE(e) == CAST(DATATYPE) NIL){
			POP(Gevalsp);	/* array v */
			goto er;
		}

		if(!peek1(t_s, Srbrack)){
			POP(Gevalsp);		/* array v */
			goto er;
		}
		v = POP(Gevalsp);
		switch(DT(v)){
		case DT_ARRAY:
			cursubr = &Aretrieve;
			T_DATATYPE(r) = call(2, F_Aretrieve, v, e);
			return(r);
		case DT_TABLE:
			cursubr = &Tretrieve;
			T_DATATYPE(r) = call(2, F_Tretrieve, v, e);
			return(r);
		case DT_BITS:
			cursubr = &Bretrieve;
			T_DATATYPE(r) = call(2, F_Bretrieve, v, e);
			return(r);
		case DT_STRING:
			cursubr = &Sretrieve;
			T_DATATYPE(r) = call(2, F_Sretrieve, v, e);
			return(r);
		default:
			putstring("INDEXING NOT ALLOWED");
			goto er;
		}
	} else
	if(peek1(t_s, Speriod)){
		STRING fname;
		int i;

		fname = Cspan(t_s, Sletgit);
		for(i = 0; i < nfields; i++)
			if(streq(fname, fields[i]->fld_name))
				return(getfield(v, fields[i]));
		goto er;
	} else
		return(v);
er:
	T_DATATYPE(r) = CAST(DATATYPE) NIL;
	return(r);
}

SUMDP var(lineflag){
	STRING v;
	STRING *safev;
	STRING s;
	extern SUMDP globals[];
	extern SUMDP eglobals;
	extern STRING globnames[];
	int i, nglobals = &eglobals - globals;
	extern struct class *_scan_string();
	struct class **news;
	SUMDP r;
	SUMDP *abase = CAST(SUMDP *) cursp;


	if(!peek(t_s, Sletgit)){
	erret:
		T_DATATYPE(r) = CAST(DATATYPE) NIL;
		return(r);
	}
	safev = CAST(STRING *) Gevalsp.sp_cast;
	PUSHSTRING(Gevalsp,NIL);
	*safev = Cspan(t_s, Sletgit);
	if(lineflag){
		v = *safev;
		for(i = 0; i < nfields; i++)
			if(streq(v, fields[i]->fld_name)){
				stopfld = fields[i];
			okret:
				T_DATATYPE(r) = CAST(DATATYPE) 1;
				return(r);
			}
		for(i = 0; i < nglobals; i++)
			if(streq(v, globnames[i])){
				stopfld = NIL;
				stopproc = T_PROC(globals[i]);
				goto okret;
			}
		goto erret;
	}
	v = *safev;
	if(streq(v, Ssubject)){
		if(prog_subject == NIL){
			putstring("NO CURRENT SUBJECT");
			goto erret;
		}
		T_CLASS(r) = prog_subject;
		return(r);
	}
	if(streq(v, Sself)){
		if((curproc->proc_fld == NIL) ||
		   (curproc->proc_fld == CAST(struct fld *) -1)){
			putstring("SELF OUTSIDE CLASS");
			goto erret;
		}
		return(abase[-curproc->proc_ntot]);
	}
	if(curproc->proc_names != CAST(STRING) NIL){
		news = CAST(CLASS *) Gevalsp.sp_cast;
		PUSHSTRING(Gevalsp,NIL);
		*news = CAST(CLASS) call(2, _scan_string, undefined, curproc->proc_names);
		switchsubject(*news);
		for(i = 0; (i<curproc->proc_ntot) &&
			   (subj_curs->int_val<subj_size); i++){
			s = Cbreak(*news, Scomma);
			if(streq(s, *safev)){
				POP(Gevalsp);	/* news */
				POP(Gevalsp);	/* safev */
				return(abase[-curproc->proc_ntot + i]);
			}
			peek1(*news, Scomma);
		}
	POP(Gevalsp);	/* news */
	switchsubject(t_s);
	}
	v = *safev;
	POP(Gevalsp);	/* safev */
	if(curproc->proc_fld != NIL){
		/*
		 * Currently executing a class procedure.
		 */
		for(i = 0; i < nfields; i++)
			if(streq(v, fields[i]->fld_name)){
				r = abase[-curproc->proc_ntot];
				return(getfield(r, fields[i]));
			}
	}
	for(i = 0; i < nglobals; i++){
		if(streq(v, globnames[i]))
			return(globals[i]);
	}
	goto erret;
}

INTEGER numb(){
	register STRING s;
	int sign;
	INTEGER f;

	sign = 1;
	if(peek1(t_s, Sminus))
		sign = -1;
	else
		peek1(t_s, Splus);
	if(!peek(t_s, Sdigit))
		return(NIL);
	if((s = Cspan(t_s, Sdigit)) == NIL)
		return(NIL);
	else {
		f = CAST(INTEGER) call(2, _integer, undefined, s);
		return(newinteger(sign * f->int_val));
	}
}

STRING str(){
	register STRING s;

	s = Cbreak(t_s, Squote);
	if(s == NIL)
		return(NIL);
	PUSHSTRING(Gevalsp,s);
	peek1(t_s, Squote);
	return(T_STRING(POP(Gevalsp)));
}

SUMDP getfield(class, fld)
SUMDP class; struct fld *fld;{
	struct fldentry *f;
	int n;
	SUMDP r;

	n = fld->fld_switch[DT(class)];

	if(n >= 0){
		f = &fld->fld_entries[n];
		if(f->fldent_offset < 0){
			putstring("ACCESS TO THIS FIELD NOT ALLOWED WHILE TRACING");
			goto er;
		}
		return(T_CLASS(class)->class_elements[f->fldent_offset]);
	} else 
		putstring("FIELD NOT DEFINED FOR THIS DATATYPE");
er:
	T_DATATYPE(r) = CAST(DATATYPE) NIL;
	return(r);
}

purgetable(){
	int i;

	for(i = 0; i < calltab->tab_size; i++)
		calltab->tab_elements[i] = NIL;
}
tracer_init(){
	calltab = newtable(10, &undefined, 0);
}

tracer_mark(){
	mark(&curline);
	mark(&storedcmd);
	mark(&calltab);
}
