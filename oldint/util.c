#
/*
 * Summer -- utility procedures and main program.
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include 	"summer.h"
#include	"operator.h"
extern int _stop();


/*
min(a, b)
int a, b;{
	return((a > b) ? b : a);
}

max(a, b)
int a, b;{
	return((a > b) ? a : b);
}
*/
errorterm(systemerror){
	put1(Snl);
	if(intracer && !systemerror)
		return;
	printstack();
	if(isatty(0) && isatty(1)){
		/*
		 * Both standard input and standard output are
		 * directly connected to a terminal: switch to
		 * trace mode by simulating an interrupt.
		 */
		putstring("\nENTERING TRACER\n");
		inter_catched++;
		tracer(cursp->stk_pc);
	}
	flflush(stand_out);
	if(systemerror)
		abort();
	else
		call(1, _stop, ONE);
}

/* LINT: */ /* VARARGS1 */
error(s, a1, a2, a3)
char *s;
SUMDP a1;
SUMDP a2;
SUMDP a3;{
	int argindex = 0;
	SUMDP curarg = a1;
	char c;

	if(er_lock)
		exit(1);
	er_lock++;
	putstring("\nError: ");
	while((c = *s++) != '\0')
		if(c != '%')
			fputc(stand_out, c);
		else {
			c = *s++;
			switch(c){

			case 'v':
				prval(curarg, 0); goto nextarg;
			case 't':
				printdt(curarg); goto nextarg;
			case 'n':
				prname(findname(curarg), 1); goto nextarg;
			case 'f':
				prname(curarg, 1); goto nextarg;
			nextarg:
				argindex++;
				curarg = (argindex == 1) ? a2 : a3;
				break;
			default:
				fputc(stand_out, '%');
				fputc(stand_out, c);
			}
		}
	er_lock = 0;
	errorterm(0);
}

syserror(s)
char * s;{
	if(er_lock)
		exit(1);
	er_lock++;
	putstring("\nSYSTEM ERROR: ");
	putstring(s);
	errorterm(1);
}

stackofl(){
	evaltop.sp_psumdp += 10;	/* some space for error processing */
	error("stack overflow");
}

stackunfl(){
	error("stack underflow");
}

erargcnt(){
	error("wrong number of args in call to built-in function");
}

erargtype(i, t){
	error("%n expects argument of type %v instead of %t",
		cursubr, class_names[t], arg[i]);
}

subrerror(){
	syserror("increase NSUBRS");
}
/* LINT: *//* VARARGS2 */
DATATYPE  call(nargs, p, a1, a2, a3, a4, a5)
DATATYPE (*p)();
SUMDP a1; SUMDP a2; SUMDP a3; SUMDP a4; SUMDP a5;{
	register DATATYPE r;
	SUMDP * argsv = arg;
	int cntsv = argcnt, retsv = retcnt;

	if(nargs > 5)
		syserror("call -- too many args");
	argcnt = nargs;
	retcnt = 1;
	arg = Gevalsp.sp_psumdp;
	if(nargs-- > 0)
		PUSHSUMDP(Gevalsp,a1);
	if(nargs-- > 0)
		PUSHSUMDP(Gevalsp,a2);
	if(nargs-- > 0)
		PUSHSUMDP(Gevalsp,a3);
	if(nargs-- > 0)
		PUSHSUMDP(Gevalsp,a4);
	if(nargs-- > 0)
		PUSHSUMDP(Gevalsp,a5);
	r = (*p)();
	Gevalsp.sp_psumdp -= argcnt;
	argcnt = cntsv; retcnt = retsv; arg = argsv;
	return(r);
}

argrange(val, limit, name)
int val, limit;
char *name;{
	char *s;
	if((val <= 0) || (val > limit)){
		write(1, "Arg ", 4);
		s = name;
		while(*s){
			write(1, s, 1);
			s++;
		}
		write(1, " out of range\n", 14);
		exit(1);
	}
}

main(argc, argv)
int argc;
char ** argv;{
	int i, argno;
	char *mem;
	extern char *sbrk();
	extern struct proc program;
	SUMDP *p;
	extern SUMDP globals[];
	extern SUMDP eglobals;
	ARRAY *arglist;

	estacksize = ESTACKSIZE;
	memmax = MEMMAX;
	profiling = 0;
	for(argno = 1; (argno < argc) && (argv[argno][0] == '-'); argno++){

		switch(argv[argno][1]){

		case 'p':
			profiling++; break;
		case 's':
			estacksize = atoi(&argv[argno][2]);
			argrange(estacksize, MAXINT, argv[argno]);
			break;

		case 'm':
			memmax = atoi(&argv[argno][2]);
			argrange(memmax, MAXINT, argv[argno]);
			break;
		case 't':
			bpttrace++;
			break;
		case 'c':
			calltrace = 2; break;
		default:
			goto endarg;
		}
	}
endarg:

	if(memmax < MEMMIN){
		write(1, "Not enough memory\n", 18);
		exit(1);
	}
	estacksize = max(estacksize, 30);
	some_trace = profiling | bpttrace | calltrace;
	mem = sbrk(SZ_SUMDP * (20+estacksize + memmax) + NINTEGERS * sizeof intbase[0]);
	if((int) mem == -1){
		write(1, "Can't allocate storage\n", 23);
		exit(1);
	}
	intbase = CAST(INTEGER) mem;
	for(i = 0 ; i < NINTEGERS; i++){
		intbase[i].dt.dt_val = DT_INTEGER;
		intbase[i].int_val = -NINTEGERS/2 + i;
	}
	T_INTEGER(Gevalsp.sp_sumdp) = &intbase[NINTEGERS];
	evalstack = Gevalsp.sp_stack;
	evaltop.sp_psumdp = Gevalsp.sp_psumdp + estacksize - 10;
	floor = surf = evaltop.sp_sumdp;
	T_DATATYPE(ceil) = T_DATATYPE(floor) + memmax;
	T_DATATYPE(undefined) = CAST(DATATYPE) alloc(SZ_SUMDP);
	T_DATATYPE(undefined)->dt.dt_val = DT_UNDEFINED;
	for(p = globals; p < &eglobals; p++)
		if(T_DATATYPE(*p) == CAST(DATATYPE) NIL)
			*p = undefined;
	/*
	 * Treat special case of null-sized classes:
	 * the garbage collector assumes a minimum instance size 2.
	 * Each instance consists of at least one header word.
	 * Instances of size zero are now forced to be followed by one
	 * (dummy word) to reach a total of 2 words.
	 */
	for(i = 0; i < nclasses; i++)
   		if(class_sizes[i] == 0)
			class_sizes[i]++;
	nullstring = CAST(STRING) alloc(SZ_STR);
	nullstring->dt.dt_val = DT_STRING;
	nullstring->str_size = 0;
	Sstand_in = newstr3("stand_in");
	Sstand_out = newstr3("stand_out");
	Sstand_er = newstr3("stand_er");
	Sr = newstr3("r");
	Sw = newstr3("w");
	Srw = newstr3("r/w");
	Squote = newstr3("'");
	Sdollar= newstr3("$");
	Sequal = newstr3("=");
	Scolon = newstr3(":");
	Splusminus = newstr3("+-");
	Splus = newstr3("+");
	Sminus = newstr3("-");
	Speriod = newstr3(".");
	Snl    = newstr3("\n");
	Slayout = newstr3(" \t");
	Squestion = newstr3("?");
	Sexclam = newstr3("!");
	Ssubject = newstr3("subject");
	Sself = newstr3("self");
	Swhere = newstr3("where");
	Soff = newstr3("off");
	Scalls = newstr3("calls");
	Sall = newstr3("all");
	Ssemi    = newstr3(";");
	Sdigit   = newstr3("0123456789");
	Slbrack  = newstr3("[");
	Srbrack  = newstr3("]");
	Sslash   = newstr3("/");
	Sletgit  =
	newstr3("_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
	Sletter =
	newstr3("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
	Scomma   = newstr3(",");
	Snumtostr = newstring(30);
	ar2 = newarray(2, &undefined);
	stand_in = newfile(0, READACCESS, 256);
	stand_out= newfile(1, WRITEACCESS, 256);
	stand_er = newfile(2, WRITEACCESS, 1);
	scan_init();
	string_init();
	subr_init();
	eval_init();
	array_init();
	table_init();
	file_init();
	iv_init();
	bits_init();
	tracer_init();
	arglist = CAST(ARRAY *) Gevalsp.sp_cast;
	PUSHSTRING(Gevalsp,NIL);
	*arglist = newarray(argc - argno, &undefined);
	for(i = argno; i < argc; i++)
		 T_STRING((*arglist)->ar_elements[i - argno]) =
		newstr3(argv[i]);
	arglist = &T_ARRAY(POP(Gevalsp));
	floor = surf;	/* make the above objects permanent */
	program.proc_freq = 1;
	enable_interrupt();
        if(program.proc_nform > 0)
		eval(&program, *arglist);
	else
		eval(&program, undefined);
	call(1, _stop, ZERO);
}
