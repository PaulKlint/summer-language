#
/*
 * Summer -- common declarations and constant definitions.
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

/*
 * The following constants should be defined, or undefined to
 * remove parts of the system.
 */
/* EVDEBUG defined => include eval debug code */
/* EVSTATS defined => produce eval statistics */
/* CGDEBUG defined => check system consistency after each garbage collection */
/* CGSTATS defined => provide garbage collector statistics */



/*
 * Basic datatypes.
 */

#define	DT_UNDEFINED	0	/* undefined value */
#define DT_INTEGER 	1	/* integer */
#define DT_REAL		2	/* real number */
#define DT_STRING	3
#define DT_ARRAY	4	/* array */
#define	DT_TABLE	5	/* table variable */
#define DT_FILE		6	/* file */
#define DT_BITS		7	/* bit array */
#define	DT_PROC		8	/* user defined routine */
#define DT_SUBR		9	/* built-in subroutine */
/*
 * TABSYM and HEAPMARK are only used internally.
 */
#define	DT_TABSYM	10	/* table element */
#define	DT_HEAPMARK	11	/* heap mark used by cache mechanism */
#define DT_LAST		11	/* last built-in datatype defined */
/*
 * The following list of standard classes is ordered! and should
 * be numbered starting with DT_LAST+1.
 * Note that any change here should be also be reflected in the
 * table "stdclass" used by codgen.sm
 */
#define DT_SCAN_STRING	12	/* scan_string class */
#define DT_INTERVAL	13	/* interval class */

/*
 * The following constants can be used to declare summer objects.
 */


#define	INTEGER		struct integer *
#define REAL		struct real *
#define	ARRAY		struct array *
#define TABLE		struct table *
#define TABSYM		struct tabsym *
#define STRING		struct string *
#define FILE		struct file *
#define CACHE		struct cache *
#define BITS		struct bits *
#define HEAPMARK	struct heapmark *
#define BOOL		int
#define CLASS		struct class *
#define DATATYPE	struct datatype *

#define NIL 0		/* The nil pointer.
			 * This is a hard constant and may not be changed.
			 * Assumptions:
			 * - C initializes global variables to 0 (= NIL)
			 * - The codegenerator produces 0 where NIL is intended.
			 */

#define CAST(t)		(t)
			/* macro to give greater visibilty to casting */
/*
 * SUMDP: a SUMmer Data Pointer.
 * This is a huge union of all legal SUMMER types, and is used
 * when objects of arbitrary type are manipulated.
 */

union sumdp {
	DATATYPE	s_datatype;
	INTEGER		s_integer;
	STRING		s_string;
	REAL		s_real;
	ARRAY		s_array;
	TABLE		s_table;
	FILE		s_file;
	TABSYM		s_tabsym;
	BITS		s_bits;
	CLASS		s_class;
	struct proc	*s_proc;
	struct subr	*s_subr;
	int		s_dtval;
	char		*s_cast;
};

#define SUMDP	union sumdp

#define T_DATATYPE(x)	(x).s_datatype
#define T_INTEGER(x)	(x).s_integer
#define T_STRING(x)	(x).s_string
#define T_REAL(x)	(x).s_real
#define T_FILE(x)	(x).s_file
#define T_BITS(x)	(x).s_bits
#define T_CLASS(x)	(x).s_class
#define T_ARRAY(x)	(x).s_array
#define T_TABLE(x)	(x).s_table
#define T_TABSYM(x)	(x).s_tabsym
#define T_PROC(x)	(x).s_proc
#define T_SUBR(x)	(x).s_subr
#define T_DTVAL(x)	(x).s_dtval
#define T_CAST(x)	(x).s_cast

/*
 * Each object begins with a field "dt" that serves to purposes:
 * - Normally it indicates the datatype of the object.
 * - During garbage collection the field is used as pointer to a
 *   list of references to this object.
 */

union dtfield {
	SUMDP		*dt_psumdp;
	int		dt_val;
};

#define DTFIELD union dtfield
#define DT(x)		T_DATATYPE(x)->dt.dt_val

struct datatype {
	DTFIELD		dt;
};

/*
 * Declarations for all standard types.
 *
 * Note that several types end in a variable length tail
 * (string, array, proc, etc.). In all those cases the
 * declarations below show a tail of size 1. This is
 * necessary since C does not like zero length fields in structures.
 */

struct integer {
	DTFIELD		dt;		/* DT_INTEGER */
	int		int_val;
};

#define INTVAL(x)		(x).s_integer->int_val

/*
 * The objects for the integers
 *	-NINTEGERS/2, ...,  0, ..., NINTEGERS/2 are preallocated.
 * See "util.c".
 */

struct integer *intbase;	/* begin of preallocated integers */
#define NINTEGERS	51	/* number of preallocated integers */
				/* must be odd */
#define ZERO	&intbase[NINTEGERS/2]	/* integer 0 object */
#define ONE	&intbase[NINTEGERS/2+1]	/* integer 1 object */
#define NDIG	7		/* precision in real conversion */

struct real {
	DTFIELD		dt;	/* DT_REAL */
	double		real_val;
};

struct string {
	DTFIELD		dt;		/* case: DT_STRING */
	int		str_size;
	char		str_contents[1];
};

struct string *nullstring;		/* the empty string */
SUMDP undefined;			/* the undefined value */

struct tabsym {
	DTFIELD		dt;		/* DT_TABSYM */
	SUMDP		tsym_key;	/* key */
	SUMDP		tsym_val;
	TABSYM		tsym_next;	/* pointer to next entry */
};

struct table {
	DTFIELD		dt;		/* DT_TABLE */
	int		tab_size;
	SUMDP		tab_default;
	struct tabsym	*tab_elements[1];
};

struct array {
	DTFIELD		dt;		/* DT_ARRAY */
	int		ar_size;
	int		ar_fill;	/* # of valid elements */
	SUMDP		ar_elements[1];
};

struct bits {				/* DT_BITS */
	DTFIELD		dt;
	int		bits_size;
	int		bits_elements[1];
};
/*
 * Declarations for the built-in (SUBR) mechanism.
 */

struct subr {
	DTFIELD		dt;		/* DT_SUBR */
	struct fld	*subr_fld;
	DATATYPE	(*function)();
	int		subr_freq;
	int		subr_prof;
};

int argcnt;		/* # of args passed to subroutine */
SUMDP *arg;		/* pointer to argument list */
int retcnt;		/* # of expected return values */
struct subr *cursubr;	/* currently active subroutine */

#define SUBR		/* dummy lexical marker */
#define ARG0		arg[0]
#define ARG1		arg[1]
#define ARG2		arg[2]
#define ARG3		arg[3]

union {
	INTEGER		(*cvt_integer)();
	STRING		(*cvt_string)();
	ARRAY		(*cvt_array)();
	BITS		(*cvt_bits)();
	DATATYPE	(*cvt_datatype)();
} cvt;
#define NSUBRS	75
struct subr *subrs[NSUBRS];
int nsubrs;
#define DCLSUBR(sub,fun,fld,fromtype) \
			if(nsubrs == NSUBRS) subrerror();\
			subrs[nsubrs++]= &sub;\
			sub.dt.dt_val=DT_SUBR; \
			cvt.fromtype = fun;\
			sub.function = cvt.cvt_datatype;\
			sub.subr_freq = sub.subr_prof = 0;\
			sub.subr_fld = fld;
#define	ARGCNT(n)	if(argcnt!=n){erargcnt();return(NIL);}
#define	ARGTYPE(i,t)	if(DT(arg[i])!=t){erargtype(i,t);return(NIL);}

ARRAY ar2;		/* used by built-in next routines */

struct proc {
	DTFIELD		dt;		/* DT_PROC */
	struct fld	*proc_fld;	/* 0:     global procedure 
					 * -1:    class creation procedure
					 * other: proc declared inside class
					 */
	int		proc_nform;	/* number of formal parameters */
	int		proc_nloc;	/* number of local variables */
	int		proc_ntot;	/* nform + nloc */
	int		proc_lino;	/* linenumber in source text */
					/* proc declaration begins */
	int		proc_elino;	/* id. for end of declaration */
	struct string	*proc_names;	/* comma separated list with local */
					/* variable names (used by tracer) */
	int		proc_freq;	/* number of calls */
	int		proc_prof;	/* total execution time */
	char		proc_body[1];	/* begin instructions */
};

struct file {
	DTFIELD		dt;
	int		fl_access;	/* access type */
	int		fl_lastaccess;
	int		fl_descr;	/* file descriptor */
	int		fl_nleft;	/* # of chars left in buffer */
	int		fl_index;	/* buffer index */
	int		fl_bufsize;	/* buffer size */
	int		fl_length;	/* length of file */
	int		fl_offset;	/* read/write pointer */
	SUMDP		fl_undef;
	SUMDP		fl_nullstring;
	char		fl_buffer[512];	/* the data buffer */
	ARRAY		fl_ctrans;	/* class id translation table */
					/* for binary files */
};

#define READ		0
#define WRITE		1
#define READBINARY	2
#define WRITEBINARY	3
#ifdef PDP11
#	define	MAXLINE	512
#else
#	define MAXLINE	3*512
#endif

/*
 * The standard input, output and error file
 */

struct file *stand_in, *stand_out, *stand_er;

/*
 * Instances of user defined classes consist of a "dt" field followed by
 * a number of SUMDPs.
 * The information on user defined classes is distributed as follows:
 * (both arrays are indexed with the value of the "dt" field each instance)
 *
 *	class_names	(compiler generated external label)
 *		array of pointers to STRINGs.
 *	class_sizes	(idem)
 *		array of integers that indicate the number of SUMDPs
 *		for each class.
 *	nclasses	(compiler generated integer variable)
 *		number of user defined classes.
 */

struct class {
	DTFIELD		dt;	/* DT_LAST < dt < nclasses */
	SUMDP		class_elements[1];
};

/*
 * Fields.
 * The structure "fld" describes one field and consists of:
 *
 * fld_switch	Byte array with index in fld_entries.
 *		Indexed with the "dt" of the instance from which the
 *		field is to be selected.
 *		-1:	field selection not allowed for this
 *			class/field combination.
 *		>= 0:	index in fld_entries.
 * fld_name	The name of this field.
 * fld_alias	!= NIL if this field has a global alias
 * fld_entries	array of "fldent"s.
 *
 * The structure "fldent" is a descriptor for one field/class pair.
 * The meaning of the fields is as follows:
 *
 * fld_offset	offset in class object.
 * fld_fetch	fetch association for this field; this is either
 *		a procedure defined in the class or one of the
 *		standard values:
 *		FLD_FETCH	for simple value fetch.
 *		fetcher		if fetching is not allowed.
 *				(fetcher is standard procedure)
 * fld_store	as above for storing in the field.
 *		special values:
 *		FLD_STORE	for simple value store.
 *		storeer		if storing is not allowed.
 *				(storeer is a standard procedure)
 *
 */

struct fldentry {
	struct proc *	fldent_type;
	int		fldent_offset;
	struct proc *	fldent_fetch;
	struct proc *	fldent_store;
};

struct fld {
	STRING		fld_name;
	char *		fld_switch;
	struct proc *	fld_alias;
	struct fldentry	fld_entries[1];
};

#define FLD_FETCH	0
#define FLD_STORE	0

/*
 * Information related to classes generated by the SUMMER compiler
 * in the form of external labels in the generated code.
 */

extern struct fld *fields[];
extern int    nfields;
extern int class_sizes[];
extern STRING class_names[];
extern int nclasses;

struct fld *fld;	/* last fld encountered by eval */

/*
 * List of string constants. (see util.c)
 */


#define Sstand_in	Sstring[0]
#define	Sstand_out	Sstring[1]
#define	Sstand_er	Sstring[2]
#define	Squote		Sstring[3]
#define	Snl		Sstring[4]
#define	Serror		Sstring[5]
#define	Squestion	Sstring[6]
#define	Slayout		Sstring[7]
#define	Ssemi		Sstring[8]
#define	Sdigit		Sstring[9]
#define Slbrack		Sstring[10]
#define Srbrack		Sstring[11]
#define Sslash		Sstring[12]
#define Sletgit		Sstring[13]
#define Scomma		Sstring[14]
#define Sdollar		Sstring[15]
#define Sequal		Sstring[16]
#define Splusminus	Sstring[17]
#define Scolon		Sstring[18]
#define Splus		Sstring[19]
#define Sminus		Sstring[20]
#define Speriod		Sstring[21]
#define Sexclam		Sstring[22]
#define Ssubject	Sstring[23]
#define Sself		Sstring[24]
#define Swhere		Sstring[25]
#define Soff		Sstring[26]
#define Sstack		Sstring[27]
#define Sletter		Sstring[28]
#define Scalls		Sstring[29]
#define Sall		Sstring[30]
struct string *Sstring[31];

/*
 * Fixed string object used in number conversions.
 * See integer.c and util.c
 */

struct string *Snumtostr;

/*
 * Error messages for the error instruction.
 */

#define ER_case	0	/* expression not in case */
#define ER_ret 1	/* proc returns no value */
#define ER_assert 2	/* assert failure */

/****************************************************************
 *								*
 *	Declarations for scan_strings.				*
 *								*
 ***************************************************************/
SUMDP subj_text;   		/* union(string, file). current subject text */
int subj_size;			/* size of subject */
struct integer *subj_curs;	/* cursor in subject */
struct class *scan_subject;	/* subject of current scan for construct */
struct class *subject;		/* internal current subject */
int  subj_type;			/* datatype of current subject */
				/* strsubjchar: for string subjects	*/
				/* flsubjchar : for file subjects	*/
/*
 * Each "scan .. for .. rof" construct introduces a new subject.
 * These (possibly nested) subjects are maintained as a linked list
 * on the normal evaluation stack (see below)
 */

struct subjdescr {
	struct subjdescr *prev;		/* descriptor of previous subject */
	SUMDP		 subject;	/* union(string, file) */
} *cursubjp;				/* current subject descriptor */

/*
 * Declarations related to the garbage collector.
 */

int ncollect;			/* # of garbage collections */
int c_lock;			/* collect lock */
int memmax;
#define MEMMAX	10000		/* initial memory size */
#define MEMMIN	300		/* minimal memory size required for */
				/* initialization */
SUMDP floor;
SUMDP nfloor;
SUMDP ceil;
SUMDP surf;
#define INFLOAT(p)	((T_CAST((p))>=T_CAST(floor))&&(T_CAST((p))<T_CAST(surf)))

#define UNMARKED(p) ((p>=0) &&(p<nclasses))
/*
 * Definition of object sizes.
 *
 */

#ifdef PDP11
#define	BPW		16	/* bits per word */
#define NCHAR		128	/* # of chars in alphabet */
#define MAXINT		((1<<15)-1)
#define MAXCEIL		0177700	/* largest address in dynamic memory */
#define ALLOCINCR	2000	/* allocation increment */
#endif
#ifdef VAX
#define BPW             32      /* bits per word */
#define NCHAR           128     /* # of chars in alphabet */
#define MAXINT		((1<<31)-1)
#define	MAXCEIL		2000000	/* largest address in dynamic memory */
#define ALLOCINCR	5000	/* allocation increment */
/* #define MDVAX		1 */
#endif
#define SZ_INTVAL	sizeof(int)	/* integer value */
#define SZ_REALVAL	sizeof(double)	/* real value */
#define SZ_CHAR		sizeof(char)	/* character */
#define SZ_PTR		sizeof(char *)	/* pointer */
#define SZ_SUMDP	sizeof(SUMDP)	/* sumdp */
#define SZ_INTEGER	(SZ_SUMDP+SZ_INTVAL)
#define SZ_REAL		(SZ_SUMDP+SZ_REALVAL)
#define SZ_STR		(SZ_SUMDP+SZ_INTVAL)
#define SZ_TABSYM	(2*SZ_SUMDP+2*SZ_PTR)
#define SZ_TABLE	(SZ_SUMDP+SZ_PTR+SZ_INTVAL)
#define SZ_ARRAY	(SZ_SUMDP+2*SZ_INTVAL)
#define SZ_FILE		(2*SZ_SUMDP+10*SZ_INTVAL+512*SZ_CHAR)
#define	SZ_HEAPMARK	(SZ_SUMDP+SZ_INTVAL)
#define SZ_BITS(n)	(SZ_SUMDP+SZ_INTVAL+((n+BPW)/BPW)*SZ_SUMDP)
#define SZ_CLASS	(SZ_SUMDP)

#include <errno.h>
extern int errno;
#define INTERRUPT(retry)	if(errno == EINTR) goto retry
int inter_catched;
/*
 * Declarations for tracing.
 */

int indent;			/* indent of trace output */
int intracer;			/* 1 => tracer is active */
struct string *curline;		/* current tracer input line */
struct string *storedcmd;	/* currently stored tracer command */
TABLE calltab;			/* table with proc names to be traced */
int calltrace;			/* 1 => print procedure calls */
int bpttrace;			/* 1 => breakpoint tracing */
int profiling;			/* excution profiling enabled */
int some_trace;			/* 1 => some form of tracing going on */
long entry_time;		/* start of time accumulation for current proc */
long col_time;			/* time spend in garbage collector */
int er_lock;			/* lock to prevent recursive error messages */

/****************************************************************
 *								*
 *		Recovery caches					*
 *								*
 ***************************************************************/


struct heapmark {
	DTFIELD		dt;		/* DT_HEAPMARK */
	int		hm_dummy;	/* dummy to get minimum object size */
};

struct cache {
	SUMDP	val_base;
	int	val_off;
	SUMDP	val_old;
};

/*
 * A list of nested recovery caches is maintained is maintained on the
 * normal evaluation stack (see below).
 */

struct cachedescr {
	struct cachedescr	*cd_prev;	/* previous cache */
	struct cache		*cd_base;	/* base adr for this cache */
	struct heapmark		*cd_heapmark;	/* heaptop on cache entry */
};
struct cachedescr *curcache;
struct cache *cachetop;

#define	NCACHE	800			/* default of cache size */
int ncache;				/* actual cache size */
struct cache *cachemem;
#define	INRECFLOAT(p)	!((T_CAST(p) > CAST(char *) curcache->cd_heapmark)&&\
			(T_CAST(p) < T_CAST(surf)))

/****************************************************************
 *								*
 *		Failure mechanism				*
 *								*
 * A list of nested failure points is maintained on the normal	*
 * evaluation stack. Each entry the list contains		*
 *	- previous entry in list				*
 *	- program pointer to be used in case of failure.	*
 * In addition to this the evaluation stack is, in case of	*
 * failure, truncated to point where the last faildescr resides	*
 * on the stack.						*
 *								*
 ***************************************************************/

struct faildescr {
	struct faildescr	*fd_prev;
	char			*fd_pc;		/* pc in failure case */
};

struct faildescr *curflab;
#define FAIL		return(NIL)

/****************************************************************
 *								*
 *		Evaluation stack				*
 *								*
 ***************************************************************/

struct stack {
	struct stack	*stk_prev;	/* previous stack frame */
	char		*stk_pc;	/* saved program counter */
	struct proc *	stk_proc;	/* proc being evaluated */
/* collect uses the fact that stk_flab is the last entry of each frame */
	struct faildescr *stk_flab;	/* saved flab */
};

#define ESTACKSIZE	1000	/* default stack size */
int estacksize;			/* actual stack size (defined in util.c) */
struct stack *evalstack;	/* begin of stack */
struct stack  *cursp;		/* stack frame pointer */

/*
 * We use the evalstack to get all kinds of temporary storage.
 * As result the stackpointer must be able to point to an unwieldly
 * number of various types.
 */

union  stackp {
	SUMDP		sp_sumdp;	/* SUMMER object */
	SUMDP		*sp_psumdp;	/* ptr to SUMMER object */
	SUMDP		**sp_ppsumdp;
	struct stack	*sp_stack;	/* stack frame pointer */
	struct cachedescr *sp_cache;
	struct subjdescr *sp_subjdescr;
	struct 	faildescr *sp_fail;
	struct trans	*sp_trans;
	char		*sp_cast;
} Gevalsp,		/* stack pointer (next available cell) */
  evaltop;		/* stack top */

SUMDP *argbase;		/* points to locals of current call */

/*
 * PUSH and POP operations for the various types
 */

#define SPCHECK(n) if(Gevalsp.sp_psumdp + n >= evaltop.sp_psumdp) stackofl()

#define PUSH(sp,val,type) if(sp.sp_psumdp < evaltop.sp_psumdp)\
		(*sp.sp_psumdp++).type = (val);\
		else stackofl()
#define PUSHSUMDP(sp,val) if(sp.sp_psumdp < evaltop.sp_psumdp)\
			(*sp.sp_psumdp++) = (val);\
			else stackofl()
/*
 * Fast, but unsafe versions of the above
#define PUSH(sp,val,type) (*sp.sp_psumdp++).type = (val)
#define PUSHSUMDP(sp,val) (*sp.sp_psumdp++) = (val)
*/
#define PUSHPSUMDP(sp,val)	if(sp.sp_psumdp < evaltop.sp_psumdp)\
			(*sp.sp_ppsumdp++) = (val);\
			else stackofl()
#define PUSHINTEGER(sp,x)	PUSH(sp,x,s_integer)
#define PUSHSTRING(sp,x)	PUSH(sp,x,s_string)
#define PUSHREAL(sp,x)		PUSH(sp,x,s_real)
#define PUSHARRAY(sp,x)		PUSH(sp,x,s_array)
#define PUSHTABLE(sp,x)		PUSH(sp,x,s_table)
#define PUSHFILE(sp,x)		PUSH(sp,x,s_file)
#define PUSHTABSYM(sp,x)	PUSH(sp,x,s_tabsym)
#define PUSHBITS(sp,x)		PUSH(sp,x,s_bits)
#define PUSHCLASS(sp,x)		PUSH(sp,x,s_class)

#define POP(sp)			(*--sp.sp_psumdp)
#define TOP(sp,n)		(sp.sp_psumdp[-1-(n)])
#define	SWAP(sp,x)		sp.sp_psumdp[-1] = x

#define FETCHARRAY 	0
#define STOREARRAY	1
#define LESS		0
#define EQUAL		1
#define GREATER		2

/*
 * Min and max macro's
 */

#define min(a, b)	((a) <= (b)) ? (a) : (b)
#define max(a, b)	((a) >= (b)) ? (a) : (b)

/*
 * Declaration of function types.
 */

STRING		newstring();
STRING		newstr3();
INTEGER		newinteger();
REAL		newreal();
ARRAY		newarray();
BITS		newbits();
TABLE		newtable();
FILE		newfile();
HEAPMARK	newheapmark();
CLASS		newclass();
STRING		inttostr();
STRING		_string();
STRING		substr();
BOOL		isdigit();
INTEGER		_number();
INTEGER		_integer();
REAL		strtoreal();
REAL		_real();
STRING		realtostr();
char		*alloc();
int		collect();
int		mark();
int		adjust();
int		compact();
int		move();
int		copy();
int		limits();
int		eval();
TABSYM		tablelook();
CACHE		save_in_cache();
STRING		findname();
FILE		tofile();
DATATYPE		call();
STRING		findfieldname();
STRING		findclassname();
long		filesize();
long		cputime();
ARRAY		ret2();
