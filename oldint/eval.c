#
/*
 * Summer -- interpreter.
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include 	"summer.h"
#include 	"operator.h"

/* #define NEW 1*/
#ifdef EVDEBUG
	extern char *icname[];
#	define PN(n)	printf(" %d", n);
#	define ICPRINT	printf("\n%4.x: %s\t",curpc,icname[*curpc]);
#else
#	define ICPRINT		/* */
#	define PN(n)		/* */
#endif

#ifdef VAX
#	define BYTE	((*curpc++)&0377)
#       define WORD(n,cast)        n = cast *(CAST(char **) curpc);curpc+=4
#       define PTR(s)   WORD(s,CAST(char *))
#	define PTR2(s,t) WORD(s,CAST(t))
#endif
#ifdef PDP11
#	define BYTE	(*curpc++&0377)
#	define WORD(n,cast)	n = cast ((BYTE<<8) + BYTE)
#	define PTR(s)	s = CAST(char *) ((BYTE<<8) + BYTE); if(s!=NIL) s += 2
#	define PTR2(s,t)	{register char *cp = CAST(char *) ((BYTE<<8)+BYTE);\
				if(cp != NIL) cp += 2;\
				s = CAST(t) cp;}
#endif
#define BIGINT(n)	WORD(n,CAST(int))
#define SMALLINT(n)	{n=BYTE;PN(n)}
#define DEFPC		cursp->stk_pc = curpc
#define DEFSP		Gevalsp.sp_psumdp = evalsp
#ifndef EVSTATS
#	define ICSTATS	/* */
#else
#	define ICSTATS	{long time = cputime();\
			*icpt += time - entry_time;\
			entry_time = time;\
			icpt = &ic_time[*curpc];\
			ic_cnt[*curpc]++;}
#endif
#define NEXTIC		goto nextic
#define FIRSTIC		nextic:\
			ICPRINT;\
			ICSTATS;\
			switch(*curpc++){
#define LASTIC		}
/*
#define IC(i)		case i:
*/
#define IC(i)		case i: asm(".globl i;i:")
#ifdef EVSTATS
	long ic_cnt[IC_LAST];
	long ic_time[IC_LAST+1];
	long *icpt = ic_time;
#	define subr_time ic_time[IC_LAST]


ev_halt(){
	double totcnt, tottime;
	int n;
	extern char *icname[];

	totcnt = 0.0;
	tottime = col_time + subr_time;
	for(n = 0; n < IC_LAST; n++){
		totcnt += ic_cnt[n];
		tottime += ic_time[n];
	}
	printf("\nINTERPRETER STATISTICS:\n\n");
	if(tottime == 0.0 || totcnt == 0.0){
		printf("No time accumulated\n");
		goto retu;
	}
	printf("garbage collector: %6.2f%% of time\n", (col_time/tottime)*100.0);
	printf("built-in procs   : %6.2f%%\n\n", (subr_time/tottime)*100.0);
	printf("instr.     count  occurs(%%)    time(%%) time/instr.\n\n");
	for(n = 0; n < IC_LAST; n++){
		printf("%s\t%8.D", icname[n], ic_cnt[n]);
		if(ic_cnt[n] != 0){
			printf(" %7.2f", (ic_cnt[n]/totcnt) * 100.0);
			printf("    %7.2f", (ic_time[n]/tottime) * 100.0);
			printf("     %7.2f\n", (ic_time[n]*20.0*1)/ic_cnt[n]);
		} else
			printf("\n");
	}
retu:	for(n=0; n < 128; n++) printf("       \n");
}
#endif

/*
 * Execute program "cs" with arguments "progars".
 * The global organization of this procedure is as follows:
 *
 *	setup runtime stack and initialize.
 *	FIRSTIC		(start of interpreter loop)
 *
 *	IC(opcode1)
 *		NEXTIC	(back to main loop)
 *	...
 *	IC(opcoden)
 *		NEXTIC
 *	LASTIC
 * The macro's FIRSTIC, IC, NEXTIC and LASTIC are expanded to a
 * big case statement. (Macro's are used here to allow experimentation
 * with alternative methods, i.e. use of computed goto's and an opcode
 * table).
 * "curpc" points to the current instruction.
 * Each instruction may be followed by an argument, which is fetched by
 * SMALLINT, BIGINT or PTR according to the instruction.
 * "curpc" is incremented accordingly.
 */

#define EVSPCHECK(n)	if(evalsp + 100 + n >= evaltop.sp_psumdp) stackofl()
#define EVPUSHSUMDP(v)	*evalsp++ = v
#define EVPUSHSTRING(v) T_STRING(*evalsp++) = v
#define EVPUSHTABLE(v)	T_TABLE(*evalsp++) = v
#define EVPUSHARRAY(v)	T_ARRAY(*evalsp++) = v
#define EVPUSHREAL(v)	T_REAL(*evalsp++) = v
#define EVPUSHINTEGER(v)	T_INTEGER(*evalsp++) = v
#define EVPUSHCLASS(v)	T_CLASS(*evalsp++) = v

#define EVPOP			*--evalsp
#define EVTOP(i)		evalsp[-1-(i)]
#define EVSWAP(v)		evalsp[-1] = v

eval(cs, progargs)
struct proc *cs; ARRAY progargs;{
	extern char reltab[6][3];
	extern SUMDP globals[];
	extern struct fld f_add, f_sub, f_mul, f_div, f_idiv, f_conc, f_neg;
	extern struct fld f_eq, f_ne, f_lt, f_le, f_gt, f_ge;
	extern struct fld f_retrieve, f_update;
	extern struct subr Aretrieve,  Bretrieve,  Sretrieve,  Tretrieve;
	extern struct subr Aupdate, Bupdate, Tupdate;
	int ignore_assoc = 0;
	register char *curpc;
	register SUMDP *evalsp;
	union stackp sp;
	register SUMDP s;
	register int n;
	SUMDP and1;
	SUMDP and2;
	struct proc * aproc;

	if(cs->dt.dt_val != DT_PROC)
		syserror("eval -- illegal argument");
	cachetop = cachemem;
	curcache = NIL;
	cursubjp = NIL;
	curpc = &cs->proc_body[0];
	argcnt = cs->proc_ntot;
	Gevalsp.sp_stack = evalstack;
	argbase = Gevalsp.sp_psumdp;
	PUSHARRAY(Gevalsp,progargs);		/* stk_arg[0] */
	for(n = argcnt - 1; n > 0; n--)
		PUSHSUMDP(Gevalsp,undefined);
	cursp = Gevalsp.sp_stack;		/* current frame pointer */
	PUSHSTRING(Gevalsp,NIL);	/* stk_prev */
	cursp->stk_pc = curpc;
	cursp->stk_proc = cs;
	cursp->stk_flab = CAST(struct faildescr *) NIL;
	Gevalsp.sp_stack = cursp + 1;
	curflab = Gevalsp.sp_fail;
	curflab->fd_prev = CAST(struct faildescr *) NIL;
	curflab->fd_pc = 0;
	Gevalsp.sp_fail++;
	cursp->stk_flab = curflab;
	entry_time = cputime();
	evalsp = Gevalsp.sp_psumdp;
	/*
	 * START OF INTERPETER LOOP
	 */
asm(".globl	evloop; evloop:");
asm(".set	evalsp,r10");
asm(".set	curpc,r11");
#define IC_EX	IC_LAST
FIRSTIC		/* fetch first instruction */

IC(IC_EX)
	/*
	 * Experimental new instruction to switch from interpreted mode
	 * to hard machine code mode;
	 * It is assumed that the assembly language output of the SUMMER
	 * compiler has been postprocessed to change certain
	 * instruction sequences into machine code. Each such sequence
	 * ends with a jump to the label "evloop" defined above.
	 */
#ifdef MDVAX
		asm("movl	r11,r9");
		asm("movl	(r9)+,r11");
		asm("jmp	(r9)");
#else
		syserror("EX not implemented");
#endif
IC(IC_NULLSTR);
	EVPUSHSTRING(nullstring);
	NEXTIC;

IC(IC_UNDEF);
#ifndef MDVAX
	EVPUSHSUMDP(undefined);
#else
	asm("movl	_undefined,(r10)+");
#endif
	NEXTIC;

IC(IC_NOOP);
		NEXTIC;

IC(IC_VOID);
		EVPOP;
		NEXTIC;
IC(IC_HALT);
#ifdef EVSTATS
		ev_halt();
#endif
		return;
IC(IC_LINE);
		SMALLINT(n);
		if(bpttrace){
			DEFPC; DEFSP;
			tracer(curpc);
		}
		NEXTIC;

IC(IC_ALINE);
		BIGINT(n);
		DEFPC;
		NEXTIC;
IC(IC_LOAD);
#ifndef MDVAX
		PTR2(T_DATATYPE(s),DATATYPE);
		EVPUSHSUMDP(s);
#else
		asm("movl	(r11)+,(r10)+");
#endif
		NEXTIC;
IC(IC_INT);
		SMALLINT(n);
		goto newint;
IC(IC_XINT);
		BIGINT(n);
		goto newint;
IC(IC_REAL);
		/*
		 * note real constants are implemented by
		 * converting their string representation to real.
		 * (this avoids the problem of machine dependent
		 * real constants in the IC code)
		 */
		syserror("real constants not implemented");
IC(IC_GLOB);
		SMALLINT(n);
	caseglob:
		EVPUSHSUMDP(globals[n]);
#ifdef	EVDEBUG
		DEFSP; prval(globals[n], 0);
#endif
		NEXTIC;
IC(IC_XGLOB);
		BIGINT(n);
		goto caseglob;
IC(IC_ASGLOB);
		SMALLINT(n);
	caseasglob:
		if(curcache != NIL){
			DEFSP; save_in_cache(globals, n);
		}
#ifdef NEW
		globals[n] = EVPOP;
#else
		globals[n] = EVTOP(0);
#endif
		NEXTIC;
IC(IC_XASGLOB);
		BIGINT(n);
		goto caseasglob;
#ifdef NEW
IC(IC_DUP);
		EVPUSHSUMDP(EVTOP(0));
		NEXTIC;
#endif
IC(IC_LOC);
#ifndef MDVAX
		SMALLINT(n);
	caseloc:
		EVPUSHSUMDP(argbase[n]);
#else
		asm("movzbl	(r11)+,r9");
	caseloc:
		asm("movl	*_argbase[r9],(r10)+");
#endif
		NEXTIC;
IC(IC_XLOC);
		BIGINT(n);
		goto caseloc;
IC(IC_ASLOC);
		SMALLINT(n);
	caseasloc:
#ifdef NEW
		argbase[n] = EVPOP;
#else
		argbase[n] = EVTOP(0);
#endif
		NEXTIC;
IC(IC_XASLOC);
		BIGINT(n);
		goto caseasloc;
IC(IC_IND);
	/*
	 * Simulate X.retrieve(index)
	 * The stack contains from bottom to top:
	 *	X
	 *	index
	 * First fast check for special cases.
	 */
	fld = &f_retrieve;
	argcnt = 2;		/* arg count */
	switch(DT(EVTOP(1))){
	case DT_ARRAY:	cursubr = &Aretrieve; goto casesubr;
	case DT_BITS:	cursubr = &Bretrieve; goto casesubr;
	case DT_TABLE:	cursubr = &Tretrieve; goto casesubr;
	case DT_STRING:	cursubr = &Sretrieve; goto casesubr;
	default:	/*
			 * Goto general field selection.
			 */
			goto casefld;
	}

IC(IC_ASIND);
	/*
	 * Simulate X.update(index, value)
	 * The stack contains from bottom to top:
	 *	value
	 *	X
	 *	index
	 * This is first transformed into
	 *	X
	 *	index
	 *	value
	 */
	fld = &f_update;
	argcnt = 3;
	{ SUMDP x; SUMDP index; SUMDP value;

	  index = EVPOP; x = EVPOP; value = EVPOP;
	  EVPUSHSUMDP(x); EVPUSHSUMDP(index); EVPUSHSUMDP(value);
	}
        switch(DT(EVTOP(2))){
        case DT_ARRAY:  cursubr = &Aupdate; goto casesubr;
        case DT_BITS:   cursubr = &Bupdate; goto casesubr;
        case DT_TABLE:  cursubr = &Tupdate; goto casesubr;
        default:        /*
                         * Goto general field selection.
                         */
                        goto casefld;
        }
IC(IC_ARINIT);{
	int arsize;
	ARRAY a;

	BIGINT(n);		/* n = # of initialized elements */
	and1 = EVPOP;
	DEFPC; DEFSP;
	if(DT(and1) != DT_INTEGER)
		error("illegal array size %v", and1);
	arsize = INTVAL(and1);
	if(n > arsize)
		syserror("too many values in array initialization");
	a = newarray(arsize, &EVTOP(0));
	EVPOP;			/* default value */
	for( ; n > 0; n--)
		a->ar_elements[n-1] = EVPOP;
	EVPUSHARRAY(a);
	NEXTIC;
}

IC(IC_TABINIT);{
	register TABLE t;

	and1 = EVPOP;
	DEFPC; DEFSP;
	if(DT(and1) != DT_INTEGER)
		error("illegal table size %v", and1);
	t = newtable(INTVAL(and1), &EVTOP(0), 0);
	EVPOP;
	EVPUSHTABLE(t);
	NEXTIC;
}

IC(IC_TABELEM);{
	SUMDP *t;
	struct tabsym *tsym;

	BIGINT(n);			/* # of keys */
	t = evalsp - n - 2;		/* table */
	DEFPC; DEFSP;
	if(DT(*t) != DT_TABLE)
		syserror("illegal table initialization");
	for( ; n > 0; n--){
		DEFSP;
		tsym = tablelook((evalsp - n - 2), &EVTOP(0), 1);
		tsym->tsym_val = *(evalsp - n - 1);
		EVPOP;			/* key */
	}
	EVPOP;	/* value */
		/* leave table on stack */
	NEXTIC;
}

IC(IC_XAR);
	SMALLINT(n);
	s = EVPOP;
	DEFPC; DEFSP;
	if(DT(s) != DT_ARRAY)
		error("%v not allowed as right hand side of multiple assignment", s);
	if(n > T_ARRAY(s)->ar_size)
		error("%v contains too few values for multiple assignment", s);
	for(n-- ; n >= 0; n--)
		EVPUSHSUMDP(T_ARRAY(s)->ar_elements[n]);
	NEXTIC;
/****************************************************************
 *								*
 *	A R I T H M E T I C    O P E R A T I O N S		*
 *	dyadic:		+-/*%					*
 *	monadic:	-					*
 *								*
 ***************************************************************/

IC(IC_ADD);
		and2 = EVPOP;
		and1 = EVPOP;
		if((DT(and1) == DT_INTEGER) && (DT(and2) == DT_INTEGER)){
			n = INTVAL(and1) + INTVAL(and2);
			goto newint;
	newint:		 /* inline expansion of newinteger */
			if((n >= -NINTEGERS/2) && (n < NINTEGERS/2))
				T_INTEGER(and1) = &intbase[n + NINTEGERS/2];
			else {
				DEFPC; DEFSP;
				T_INTEGER(and1) = CAST(INTEGER) alloc(SZ_INTEGER);
				and1.s_datatype->dt.dt_val = DT_INTEGER;
				INTVAL(and1) = n;
			}
			EVPUSHSUMDP(and1);
			NEXTIC;
		} else {
			double r1, r2;

			fld = &f_add;
	arith:
			n = DT(and1);
			if(n == DT_INTEGER)
				r1 = INTVAL(and1);
			else
			if(n == DT_REAL)
				r1 = T_REAL(and1)->real_val;
			else {
	arith_fld:
				argcnt = 2;
				EVPUSHSUMDP(and1);
				EVPUSHSUMDP(and2);
				goto casefld;
			}
			n = DT(and2);
			DEFPC; DEFSP;
			if(n == DT_INTEGER)
				r2 = INTVAL(and2);
			else
			if(n == DT_REAL)
				r2 = T_REAL(and2)->real_val;
			else
				error("illegal right operand %v of %f", and2, fld->fld_name);
			switch(curpc[-1]){
			case IC_ADD:	r1 += r2; break;
			case IC_SUB:	r1 -= r2; break;
			case IC_MUL:	r1 *= r2; break;
			case IC_DIV:	if(r2 == 0)
						error("divide by zero");
					r1 /= r2; break;
			default:
					syserror("arith");
			}
			EVPUSHREAL(newreal(r1));
			NEXTIC;
		}

IC(IC_SUB);
                and2 = EVPOP;
                and1 = EVPOP;
                if((DT(and1) == DT_INTEGER) && (DT(and2) == DT_INTEGER)){
			n = INTVAL(and1) - INTVAL(and2);
			goto newint;
		} else {
			fld = &f_sub;
			goto arith;
		}
IC(IC_MUL);
                and2 = EVPOP;
		and1 = EVPOP;
                if((DT(and1) == DT_INTEGER) && (DT(and2) == DT_INTEGER)){
                	n = INTVAL(and1)*INTVAL(and2);
			goto newint;
		} else {
			fld = &f_mul;
			goto arith;
		}
IC(IC_DIV);
                and2 = EVPOP;
                and1 = EVPOP;
		fld = &f_div;
		goto arith;
IC(IC_IDIV);
		and2 = EVPOP;
		and1 = EVPOP;
		DEFPC; DEFSP;
		if(DT(and1) != DT_INTEGER){
			fld = &f_idiv;
			goto arith_fld;
		} else
		if(DT(and2) != DT_INTEGER)
			error("% requires 'integer' right operand instead of %v",
				and2);
		else {
			if(INTVAL(and2) == 0)
				error("integer divide (%) by zero");
			n = INTVAL(and1) / INTVAL(and2);
			goto newint;
		}
IC(IC_NEG);
		and1 = EVPOP;
		if(DT(and1) == DT_INTEGER){
			n = -INTVAL(and1);
			goto newint;
		} else
		if(DT(and1) == DT_REAL){
			DEFPC; DEFSP;
			EVPUSHREAL(newreal(-T_REAL(and1)->real_val));
			NEXTIC;
		} else {
			argcnt = 1;
			fld = &f_neg;
			EVPUSHSUMDP(and1);
			goto casefld;
		}
/****************************************************************
 *								*
 *	C O N C A T E N A T I O N				*
 *	dyadic:		||					*
 *								*
 ***************************************************************/
IC(IC_CONC);
	DEFPC; DEFSP;
	if((DT(EVTOP(1)) == DT_STRING) && (DT(EVTOP(0)) == DT_STRING)){
		STRING strarg;
		STRING strres;
		int size1, size2;
		if((size1 = T_STRING(EVTOP(0))->str_size) == 0){
			strres = T_STRING(EVTOP(1));
			goto concdone;
		}
		if((size2 = T_STRING(EVTOP(1))->str_size) == 0){
			strres = T_STRING(EVTOP(0));
			goto concdone;
		}
		strres = newstring(size1 + size2);
		strarg = T_STRING(EVTOP(1));
		copy(strarg->str_contents, &strarg->str_contents[size2],
			strres->str_contents);
		strarg = T_STRING(EVTOP(0));
		copy(strarg->str_contents, &strarg->str_contents[size1],
			&strres->str_contents[size2]);
	concdone:
		EVPOP;
		EVPOP;
		EVPUSHSTRING(strres);
		NEXTIC;
	} else
	if(DT(EVTOP(1)) > DT_LAST){
		argcnt = 2;
		fld = &f_conc;
		goto casefld;
	}
	if(DT(EVTOP(1)) == DT_STRING)
		error("right operand of type %t illegal in \"%v || %v\"",
			EVTOP(0), EVTOP(1), EVTOP(0));
	else
		error("|| not defined for type %t in \"%v || %v\"",
			EVTOP(1), EVTOP(1), EVTOP(0));
/***************************************************************
 *								*
 *	R E L A T I O N A L    O P E R A T O R S		*
 *	dyadic:		= ~= < <= > >=				*
 *	(monadic ~ is handled by flow-of-control instructions)	*
 *								*
 ***************************************************************/
IC(IC_EQ);
	/*
	 * Fast test for equal objects.
	 */
	if(T_DATATYPE(EVTOP(0)) == T_DATATYPE(EVTOP(1))){
		s = EVPOP;
		EVSWAP(s);
		NEXTIC;
	}
	/*
	 * Nope. Merge with regular case.
	 */
	fld = &f_eq; goto caserel;
IC(IC_NE);
	fld = &f_ne; goto caserel;
IC(IC_GT);
	fld = &f_gt; goto caserel;
IC(IC_GE);
	fld = &f_ge; goto caserel;
IC(IC_LT);
	fld = &f_lt; goto caserel;
IC(IC_LE);
	fld = &f_le; goto caserel;
caserel:
	{ int op, d1, d2, i1, i2;
	  double r1, r2;
		op = curpc[-1];
		and2 = EVPOP;
		and1 = EVPOP;
		d1 = DT(and1);
		d2 = DT(and2);
		DEFPC; DEFSP;
		switch(d1){

		case DT_INTEGER:
			switch(d2){
			case DT_INTEGER:
				i1 = INTVAL(and1);
				i2 = INTVAL(and2);
				n = reltab[op-RELOPS]
				[(i1 == i2) ? 1 : ((i1 > i2) ? 2 : 0)];
				break;
			case DT_REAL:
				r1 = INTVAL(and1);
				r2 = T_REAL(and2)->real_val;
				goto realcmp;
			case DT_UNDEFINED:
			arg2undefined:
				if(op == IC_EQ || op == IC_NE)
					n = (op == IC_EQ) ? 0 : 1;
				else
					goto arg2error;
				break;
			default:
			arg2error:
				error("illegal right operand in %v %f %v",
					and1, fld->fld_name, and2);
			}
			break;
		case DT_REAL:
			r1 = T_REAL(and1)->real_val;
			switch(d2){
			case DT_INTEGER:
				r2 = INTVAL(and2);
				goto realcmp;
			case DT_REAL:
				r2 = T_REAL(and2)->real_val;
			realcmp:
				n = reltab[op-RELOPS]
				[(r1 == r2) ? 1 : ((r1 > r2) ? 2 : 0)];
				break;
			case DT_UNDEFINED:
				goto arg2undefined;
			default:
				goto arg2error;
			}
			break;
		case DT_STRING:
			if(d2 == DT_STRING){
				n = ((op == IC_EQ)||(op == IC_NE)) ?
				     reltab[op-RELOPS]
				    [streq(T_STRING(and1), T_STRING(and2))] :
				    reltab[op-RELOPS]
					[strcmp(T_STRING(and1), T_STRING(and2))];
			} else
			if(d2 == DT_UNDEFINED)
				goto arg2undefined;
			else
				goto arg2error;
			break;
		default:
			argcnt = 2;
			EVPUSHSUMDP(and1);
			EVPUSHSUMDP(and2);
			goto casefld;
		}
		if(n == 0){
			if(curflab->fd_pc == NIL)
				error("undetected failure of relational operator %f", fld->fld_name);
			goto casegofl;
		}
		EVPUSHSUMDP(and2);
		NEXTIC;
	}

/***************************************************************
 *								*
 *	F L O W  OF  C O N T R O L  A N D			*
 *	F A I L U R E  H A N D L I N G				*
 *								*
 ***************************************************************/
IC(IC_GOCASE);
		{ TABSYM t;
		BIGINT(n);
		DEFPC; DEFSP;
		t = tablelook(&globals[n], &EVTOP(0), 0);
		/*
		 * save case entry, to produce error message, see IC_ERROR.
		 */
		s = EVPOP;
		curpc = CAST(char *) 
			((t == NIL) ?
			T_DATATYPE(T_TABLE(globals[n])->tab_default) :
			T_DATATYPE(t->tsym_val));
		NEXTIC;
		}
IC(IC_GO);
		PTR(cursp->stk_pc);
		curpc = cursp->stk_pc;
		NEXTIC;
IC(IC_GOFL);
		if(curflab->fd_pc == NIL){
			DEFPC; DEFSP;
			error("failure occurs in illegal context");
		}
casegofl:

		if(CAST(SUMDP *) curflab < CAST(SUMDP *) cursp){
			goto casefreturn;
		}
		while(CAST(SUMDP *) cursubjp > CAST(SUMDP *) curflab){
			DEFPC; DEFSP;
			oldsubject();
		}
		while(CAST(SUMDP *) curcache > CAST(SUMDP *) curflab)
			curcache = curcache->cd_prev;
		cursp->stk_pc = curpc = curflab->fd_pc;		/* failure pc */
		evalsp = CAST(SUMDP *) curflab;	/* restore stack pointer */
		curflab = curflab->fd_prev;	/* previous fail label */
		NEXTIC;
IC(IC_NEWFL);
#ifndef MDVAX
		(CAST(struct faildescr *) evalsp)->fd_prev = curflab;
		PTR((CAST(struct faildescr *) evalsp)->fd_pc);
		curflab = (CAST(struct faildescr *) evalsp);	/* new current fail label */
		evalsp = CAST(SUMDP *) (curflab + 1);
#else
		asm("movl	r10,r0");
		asm("movl	_curflab,(r10)+");
		asm("movl	(r11)+,(r10)+");
		asm("movl	r0,_curflab");
#endif
		NEXTIC;
IC(IC_OLDFL);
		if((CAST(SUMDP *) curcache > CAST(SUMDP *) curflab) ||
		 (CAST(SUMDP *) cursubjp > CAST(SUMDP *) curflab))
			syserror("OLDFL with active cache or subject");
		n = evalsp - ((CAST(SUMDP *) curflab) + 2);
		evalsp = CAST(SUMDP *) curflab;
		curflab = curflab->fd_prev;
asm(".globl OLDFL1; OLDFL1:");
		while(n--)
			*evalsp++ = evalsp[2];
		NEXTIC;
/***************************************************************
 *								*
 *	R E C O V E R Y  C A C H E S				*
 *								*
 *	NEWRC	create new cache				*
 *	RESRC	restore environment from cache			*
 *	OLDRC	merge current cache with old cache and		*
 *		reinstall the old cache				*
 *								*
 ***************************************************************/
IC(IC_NEWRC);
		(CAST(struct cachedescr *) evalsp)->cd_prev = curcache;
		curcache = CAST(struct cachedescr *) evalsp;
		curcache->cd_base = cachetop;
		evalsp = CAST(SUMDP *) (curcache + 1);
		DEFPC; DEFSP;
		curcache->cd_heapmark = newheapmark();
/*
printf("NEWRC, curcache: %d, cachetop: %d\n", curcache, cachetop);
*/
		NEXTIC;
IC(IC_RESRC);
		DEFPC; DEFSP;
		rest_from_cache();
/*
printf("RESRC\n");
*/
		NEXTIC;
IC(IC_OLDRC);
		if(CAST(struct cachedescr *) evalsp == curcache + 1)
			evalsp = CAST(SUMDP *) (curcache);
		curcache = curcache->cd_prev;
		/*
		 * Duplicate values in the current and previous cache
		 * could be merged here.
		 */
		if(curcache == NIL)
			/*
			 * Discard cache contents when returning to
			 * top-level without recovery.
			 */
			cachetop = cachemem;
/*
printf("OLDRC: curcache=%d, cachetop=%d, cachemem=%d\n", curcache, cachetop, cachemem);
*/
		NEXTIC;
/***************************************************************
 *								*
 *	S U B J E C T						*
 *								*
 *	NEWSUBJ	define a new subject				*
 *	OLDSUBJ reinstall old subject				*
 *	SUBJECT value of current subject			*
 *								*
 ***************************************************************/
IC(IC_NEWSUBJ);
		s = EVPOP;
		DEFPC; DEFSP;
		newsubject(s);
		evalsp = Gevalsp.sp_psumdp;
		NEXTIC;
IC(IC_OLDSUBJ);
		{SUMDP *from;
		 SUMDP *to;
		int nvalues;
		DEFPC; DEFSP;
		if((CAST(SUMDP *) curcache > CAST(SUMDP *) cursubjp) ||
			(CAST(SUMDP *) curflab > CAST(SUMDP *) cursubjp))
			syserror("oldsubj with active cache or fail lab");
		to = CAST(SUMDP *) cursubjp;
		from = CAST(SUMDP *) (cursubjp + 1);
		oldsubject();
		nvalues = evalsp - from;
		for(n = 0; n < nvalues; n++)
			to[n] = from[n];
		evalsp = &to[nvalues];
		NEXTIC;
		}
IC(IC_SUBJECT);
		if(scan_subject == NIL){
			int opcode = curpc[0];
			curpc++;
			DEFPC; DEFSP;
			switch(opcode){
			case IC_FLD:
			case IC_IFLD:
			case IC_ASFLD:
			case IC_IASFLD:
				SMALLINT(n);	/* field */
				fld = fields[n];
				error("attempt to access field %f of undefined subject",
				fld->fld_name);
			}
			error("attempt to use undefined subject");
		}
		else
			EVPUSHCLASS(scan_subject);
		NEXTIC;

/****************************************************************
 *								*
 *	C L A S S E S						*
 *								*
 *	NEWCLASS	create a new class instance		*
 *	SELF		value of current class instance		*
 *	FLD		get value of field			*
 *	IFLD		get value of field and ignore		*
 *			fetch associations			*
 *	ASFLD		assign to field				*
 *	IASFLD		assign to field and ignore		*
 *			store associations			*
 *								*
 ***************************************************************/

IC(IC_NEWCLASS);
	SMALLINT(n);
	DEFPC; DEFSP;
	EVPUSHCLASS(newclass(n, 1));
	NEXTIC;

IC(IC_SELF);
	EVPUSHSUMDP(argbase[0]);
	NEXTIC;
IC(IC_CLOC);
	SMALLINT(n);
	EVPUSHSUMDP(T_CLASS(argbase[0])->class_elements[n]);
	NEXTIC;
IC(IC_ASCLOC);
	SMALLINT(n);
	if(curcache != NIL)
		/* Note: n + 1 takes dt field into account. */
		save_in_cache(argbase[0], n + 1);
	T_CLASS(argbase[0])->class_elements[n] = EVTOP(0);
	NEXTIC;

IC(IC_IFLD);
	SMALLINT(n);		/* field */
	fld = fields[n];
	SMALLINT(argcnt);

	s = EVTOP(argcnt-1);
	if((n = fld->fld_switch[DT(s)]) >= 0){
		register int offset;

		if((offset = fld->fld_entries[n].fldent_offset) >= 0){
			if(argcnt != 1)
				syserror("FLD -- argcnt");
			EVTOP(0) = T_CLASS(s)->class_elements[offset];
			NEXTIC;
		} else {
			if(offset < 0)
				aproc = fld->fld_entries[n].fldent_type;
			else
				aproc = fld->fld_entries[n].fldent_fetch;
			goto casecall;
		}
	} else
	if(fld->fld_alias != NIL){
		aproc = fld->fld_alias;
		goto casecall;
	} else
		goto casefldeq;

IC(IC_FLD);
	/*
	 * FLD	field,argcnt.
	 */
	SMALLINT(n);	/* field */
	fld = fields[n];
	SMALLINT(argcnt);
casefld:
	{ register struct fldentry *f;
	s = EVTOP(argcnt-1);
	if((n = fld->fld_switch[DT(s)]) >= 0){
		f = &fld->fld_entries[n];
		if((aproc = f->fldent_fetch) == CAST(struct proc *) FLD_FETCH){
			if(argcnt != 1)
				syserror("FLD -- argcnt");
			EVTOP(0) = T_CLASS(s)->class_elements[f->fldent_offset];
			NEXTIC;
		} else
			goto casecall;
	} else
	if(fld->fld_alias != NIL){
		aproc = fld->fld_alias;
		goto casecall;
	}
casefldeq:
	if(fld == &f_eq || fld == &f_ne){
		/*
	 	* Inline definition of global operators = and ~=
	 	*/
		and2 = EVPOP;
		and1 = EVPOP;
		if(DT(and1) == DT_UNDEFINED || DT(and2) == DT_UNDEFINED ||
		   DT(and1) == DT(and2)){
			n = (T_DATATYPE(and1) == T_DATATYPE(and2));
			if(fld == &f_ne)
				n = (n == 1) ? 0 : 1;
			if(n == 0){
				if(curflab->fd_pc == NIL)
					error("undetected failure of = or ~=");
				goto casegofl;
			} else {
				EVPUSHSUMDP(and2);
				NEXTIC;
			}
		} else {
			DEFPC; DEFSP;
			error("operation = or ~= not allowed between types %t and %t", and1, and2);
		}
	} else {
		s = EVTOP(argcnt-1);
		DEFPC; DEFSP;
		error("field %f not defined on %t value %v", fld->fld_name, s, s);
	}
	}
IC(IC_IASFLD);
	/*
	 * Same as ASFLD but ignore store association
	 * of variable field.
	 */
	ignore_assoc = 1;
IC(IC_ASFLD);
	/*
	 * ASFLD field,argcnt
         * stack:       EVTOP(0)  class object.
         *              EVTOP(1)  rhs value.
	 */
	{ register struct fldentry *f;

	SMALLINT(n);
	fld = fields[n];
	SMALLINT(argcnt);
	n = fld->fld_switch[DT(EVTOP(0))];
	if(n >= 0){
		int offset;
		f = &fld->fld_entries[n];
		aproc = f->fldent_store;
		offset = f->fldent_offset;
		if((aproc == FLD_STORE) || (ignore_assoc && (offset >= 0))){
			if(curcache != NIL)
				/*
				 * change! +1 takes dt field into account
				 */
				save_in_cache(EVTOP(0), offset+1);
			T_CLASS(EVTOP(0))->class_elements[offset] = EVTOP(1);
			EVPOP;	/* class object */
			ignore_assoc = 0;
			NEXTIC;
		} else {
			ignore_assoc = 0;
			argcnt = 2;
			/*
			 * Reverse class object and rhs to
			 * adhere to the convention that
			 * class object = argument 0 in
			 * class procedures.
			 */
			and1 = EVPOP;	/* class object */
			and2 = EVPOP;	/* rhs */
			EVPUSHSUMDP(and1);
			EVPUSHSUMDP(and2);
			goto casecall;
		}
	} else {
		DEFPC; DEFSP;
		error("field %f not defined on %t value %v",
		fld->fld_name, EVTOP(0), EVTOP(0));
	}
	}

/****************************************************************
 *								*
 *	P R O C E D U R E  C A L L / R E T U R N		*
 *								*
 *	CALL	call procedure					*
 *	XCALL	call procedure (long format)			*
 *	RETURN	return from procedure				*
 *	FRETURN failure return from procedure			*
 *								*
 ***************************************************************/
IC(IC_XCALL);
		BIGINT(n);
		SMALLINT(argcnt);
		aproc = T_PROC(globals[n]);
		goto casecall;
IC(IC_CALL);
		SMALLINT(n);
		SMALLINT(argcnt);
		aproc = T_PROC(globals[n]);
	casecall:
		if(aproc->dt.dt_val == DT_PROC){	/* user defined procedure */
			register struct proc *rproc = aproc;
			if(argcnt != rproc->proc_nform){
				DEFPC; DEFSP;
				error("%n called with wrong number of actuals",
					rproc);
			}
			n = rproc->proc_nloc;
			EVSPCHECK(n);
			argbase = evalsp - argcnt;
#ifndef MDVAX
			while(n--)
				*evalsp++ = undefined;
			cursp->stk_pc = curpc;
			(CAST(struct stack *) evalsp)->stk_prev = cursp;
			curpc = (CAST(struct stack *) evalsp)->stk_pc = &rproc->proc_body[0];
			(CAST(struct stack *) evalsp)->stk_proc = rproc;
			cursp->stk_flab = (CAST(struct stack *) evalsp)->stk_flab = curflab;
			cursp = (CAST(struct stack *) evalsp);
			evalsp = CAST(SUMDP *) (cursp + 1);
#else
			asm("movl	_undefined,r0");
			asm("jbr	CL2");
			asm("CL1:	movl	r0,(r10)+");
			asm("CL2:	sobgeq	r9,CL1");
			asm("movl	_cursp,r0	# cursp = r0");
			asm("movl	r10,_cursp");
			asm("movl	r11,4(r0)");
			asm("movl	r0,(r10)+");
			asm("addl3	$40,r8,r11");
			asm("movl	r11,(r10)+");
			asm("movl	r8,(r10)+");
			asm("movl	_curflab,(r10)");
			asm("movl	(r10)+,12(r0)");
#endif
			if(some_trace){
				DEFPC; DEFSP;
				if(profiling){
					long time = cputime();
					cursp->stk_prev->stk_proc->proc_prof +=
						time - entry_time;
					entry_time = time;
					rproc->proc_freq++;
				}
				if(calltrace)
					printcall(rproc, argbase, argcnt, 1);
				if(bpttrace)
					tracer(curpc);
			}
			NEXTIC;
		} else
		if(aproc->dt.dt_val == DT_SUBR){	/* built in procedure */
			cursubr = CAST(struct subr *) aproc;
	casesubr:
			retcnt = (*curpc != IC_VOID);
			DEFPC; DEFSP;
			arg = &evalsp[-argcnt];
			if(some_trace){
				long time, deltat;
				if(profiling){
					time = cputime();
					cursubr->subr_freq++;
				}
				if(calltrace)
					printcall(cursubr, arg, argcnt, 1);
				T_DATATYPE(s) = (*cursubr->function)();
				if(profiling){
					deltat = cputime() - time;
					cursubr->subr_prof += deltat;
					entry_time += deltat;
				}
				if(T_DATATYPE(s) == NIL){
					if(calltrace)
						printret(cursubr,NIL, 0);
					goto subrfails;
				} else {
					evalsp -= argcnt;
					if(retcnt == 1)
						EVPUSHSUMDP(s);
					else
						curpc++;	/* IC_VOID */
					if(calltrace)
						printret(cursubr, s, 2-retcnt);
					cursubr = NIL;
				}
			} else {
				/*
				 * Fast code for procedure call.
				 */
#ifdef EVSTATS
				icpt = &subr_time;
#endif
				if((T_DATATYPE(s) = (*cursubr->function)()) == NIL){
			subrfails:
					if(curflab->fd_pc == NIL){
						DEFPC;
						error("undetected failure of procedure %n", cursubr);
					}
					cursubr = NIL;
					goto casegofl;
				}
#ifdef EVSTATS
				icpt = &ic_time[IC_CALL];
#endif
				cursubr = NIL;
				evalsp -= argcnt;
				if(retcnt == 1)
					EVPUSHSUMDP(s);
				else
					curpc++;	/* IC_VOID */
			}
			NEXTIC;
		} else
			syserror("attempt to call a non-procedure type object");
IC(IC_FRETURN);
casefreturn:
		aproc = cursp->stk_proc;
		{ struct stack *stk;
		while(CAST(SUMDP *) cursubjp > CAST(SUMDP *) cursp){
			DEFPC; DEFSP;
			oldsubject();
		}
		while(CAST(SUMDP *) curcache > CAST(SUMDP *) cursp)
			curcache = curcache->cd_prev;
		stk = cursp;
		cursp = cursp->stk_prev;
		argbase = (CAST(SUMDP *) cursp) - cursp->stk_proc->proc_ntot;
		curflab = cursp->stk_flab;
		if(some_trace){
			DEFPC; DEFSP;
			if(profiling){
				long time = cputime();
				cursp->stk_proc->proc_prof +=
					time - entry_time;
				entry_time = time;
			}
			if(calltrace)
				printret(aproc, NIL, 0);
		}
		if(curflab->fd_pc == NIL){
			DEFPC; DEFSP;
			error("undetected failure of procedure %n", stk->stk_proc);
		}
		goto casegofl;
		}
IC(IC_RETURN);
		aproc = cursp->stk_proc;
		{ struct stack *stk;
		if(some_trace){
			DEFPC; DEFSP;
			if(profiling){
				long time = cputime();
				cursp->stk_proc->proc_prof +=
					time - entry_time;
				entry_time = time;
			}
			if(bpttrace)
				tracer(curpc);
		}
		SMALLINT(n);	/* # of return values */
		while(CAST(SUMDP *) cursubjp > CAST(SUMDP *) cursp){
			DEFPC; DEFSP;
			oldsubject();
		}
		while(CAST(SUMDP *) curcache > CAST(SUMDP *) cursp)
			curcache = curcache->cd_prev;
		s = EVTOP(0);	/* potential return value */
				/* --- may be not there --*/
		stk = cursp;
		cursp = cursp->stk_prev;
		curpc = cursp->stk_pc;
		evalsp = argbase;
		argbase = (CAST(SUMDP *) cursp) - cursp->stk_proc->proc_ntot;
		curflab = cursp->stk_flab;
		if(*curpc == IC_VOID){
			curpc++;
		} else
		if(n == 1){
			EVPUSHSUMDP(s);
		} else {
			DEFPC; DEFSP;
			error("procedure %n returns no value", stk->stk_proc);
		}
		if(calltrace){
			DEFPC; DEFSP;
			printret(aproc, s, (n == 1) ? 1 : 2);
		}
		NEXTIC;
		}
IC(IC_ERROR);
	SMALLINT(n);
	DEFPC; DEFSP;
	if(n == ER_case)
		error("value %v outside case list", s);
	else
	if(n == ER_ret)
		error("procedure should return a value");
	else
	if(n == ER_assert)
		error("assertion fails");
	else
		syserror("undefined error code in error");
LASTIC
};

int lino(proc, pc, from, to)
struct proc *proc; char *pc;
int *from, *to;{
	int n, fromseen;
	char * curpc, *cp;

	fromseen = 0;
	*from = proc->proc_lino;
	*to = proc->proc_elino;
	curpc = proc->proc_body;
	if(curpc == pc){
		*to = *from;
		return;
	}
	while(1){
		switch(*curpc++){
		case IC_NULLSTR:
		case IC_SUBJECT:
		case IC_SELF:
		case IC_UNDEF:
		case IC_NOOP:
		case IC_IND:
		case IC_ASIND:
		case IC_TABINIT:
		case IC_VOID:
		case IC_ADD:
		case IC_SUB:
		case IC_MUL:
		case IC_DIV:
		case IC_IDIV:
		case IC_NEG:
		case IC_CONC:
		case IC_EQ:
		case IC_NE:
		case IC_GT:
		case IC_GE:
		case IC_LT:
		case IC_LE:
		case IC_GOFL:
		case IC_OLDFL:
		case IC_NEWRC:
		case IC_RESRC:
		case IC_OLDRC:
		case IC_NEWSUBJ:
		case IC_OLDSUBJ:
		case IC_FRETURN:
			break;
		case IC_LINE:
			SMALLINT(n);
			n = *from + n;
			goto casealine;
		case IC_ALINE:
			BIGINT(n);
		casealine:
			if(fromseen){
				*to = n;
				return;
			} else {
				*from = n;
				if(curpc >= pc){
					fromseen = 1;
				}
				break;
			}
		case IC_HALT:
			return;
		case IC_LOAD:
		case IC_NEWFL:
		case IC_GO:
			PTR(cp); break;
		case IC_NEWCLASS:
		case IC_INT:
		case IC_GLOB:
		case IC_LOC:
		case IC_ASLOC:
		case IC_ASGLOB:
		case IC_CLOC:
		case IC_ASCLOC:
		case IC_XAR:
		case IC_RETURN:
		case IC_ERROR:
			SMALLINT(n); break;
		case IC_XINT:
		case IC_XGLOB:
		case IC_XLOC:
		case IC_XASGLOB:
		case IC_XASLOC:
		case IC_ARINIT:
		case IC_TABELEM:
		case IC_GOCASE:
			BIGINT(n); break;
		case IC_CALL:
		case IC_FLD:
		case IC_IFLD:
		case IC_IASFLD:
		case IC_ASFLD:
			SMALLINT(n);
			SMALLINT(n);
			break;
		case IC_GCALL:
			SMALLINT(n);
			break;
		case IC_XCALL:
			BIGINT(n);
			SMALLINT(n);
			break;
		default:
/*
			syserror("lino -- illegal opcode");
*/
			return;
		}
	}
}


char reltab[6][3] = {

/*	<	==	>	*/
	0,	1,	0,	/* == */
	1,	0,	1,	/* != */
	1,	0,	0,	/* < */
	0,	0,	1,	/* > */
	1,	1,	0,	/* <= */
	0,	1,	1	/* >= */
};


/*
 * Compare two string objects and return:
 *	0	if less
 *	1	if equal
 *	2	if greater
 */

strcmp(s1, s2)
STRING s1; STRING s2;{
	register char *rs1, *rs2;
	register int n;
	int size1, size2, imax;

	if(s1 == s2)
		return(1);	/* equal objects */
	size1 = s1->str_size;
	size2 = s2->str_size;
	rs1 = s1->str_contents;
	rs2 = s2->str_contents;

	imax = min(size1 ,size2);
	for(n = 0; n < imax; n++)
		if(*rs1 != *rs2)
			return((*rs1 < *rs2) ? 0 : 2);
		else {
			rs1++; rs2++;
		}
	return((size1 <= size2) ? (size1 == size2) : 2);
}

/*
 * Test two string objects for equality and return:
 *	0	if not equal
 *	1	if equal
 */

streq(s1, s2)
STRING s1; STRING s2;{
	register char *a, *b, *c;

	if(s1 == s2)
		return(1);	/* equal objects */
	if(s1->str_size != s2->str_size)
		return(0);
	a = s1->str_contents; b = s2->str_contents;
	c = &s1->str_contents[s1->str_size];
	while(a < c)
		if(*a++ != *b++)
			return(0);
	return(1);
}
eval_init(){
}
