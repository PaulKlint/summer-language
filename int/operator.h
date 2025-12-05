#
/*
 * Summer -- definition of intermediate code (IC) operators.
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#define IC_INT		0	/* number */
#define IC_XINT		1	/* large number ( > 256) */
#define IC_REAL		2	/* real constant */
#define IC_GLOB		3	/* global variable */
#define IC_XGLOB	4	/* global variable (index > 256) */
#define IC_ASGLOB	5	/* assign to global */
#define IC_XASGLOB	6	/* assign to global (index > 256) */
#define IC_LOC		7	/* local variable */
#define IC_XLOC		8	/* local variable (index > 256) */
#define IC_ASLOC	9	/* assign to local variable */
#define IC_XASLOC	10	/* assign to local (index > 256) */
#define IC_IND		11	/* table or array indexing */
#define IC_ASIND	12	/* assign to array or table element */

#define IC_NULLSTR	13	/* load nullstring */
#define IC_VOID		14	/* remove top of stack */

/*
 * The jump instruction is followed by a pointer in the current
 * code segment.
 */
#define IC_GO		15

/*
 * Note: the relational operators must be consequtive.
 * (from IC_EQ to IC_GE).
 */

#define	RELOPS		IC_EQ
#define IC_EQ		16	/* = */
#define IC_NE		17	/* ~= */
#define IC_LT		18	/* < */
#define IC_GT		19	/* > */
#define IC_LE		20	/* <= */
#define IC_GE		21	/* >= */


#define IC_ADD		22	/* + */
#define IC_SUB		23	/* - */
#define IC_MUL		24	/* * */
#define IC_DIV		25	/* / divide */
#define IC_IDIV		26	/* % integer divide */
#define IC_NEG		27	/* unary - */
#define IC_CONC		28	/* || */


/*
 * Procedure calls.
 * The CALL operator is an n-adic postfix operator. The format of
 * the stack is:
 *	arg0
 *	arg1
 *	...
 *	argn
 */

#define IC_CALL		29	/* call a (fixed) procedure */
#define IC_GCALL	30	/* call an (arbitrary) procedure */
#define IC_RETURN	31	/* return a value from a procedure */
#define IC_FRETURN	32	/* fail return from procedure */




#define IC_ARINIT	33	/* array initialization */
#define IC_TABINIT	34	/* table initialization */
#define IC_TABELEM	35	/* table element assignment */


#define IC_NOOP		36	/* no operation */
#define IC_LOAD		37	/* load arbitrary constant */
#define IC_HALT		38	/* halt instruction */

#define IC_NEWFL	39	/* define new fail label */
#define IC_OLDFL	40	/* restore previous fail label */
#define IC_GOFL		41	/* jump to current fail label */

#define IC_NEWRC	42	/* enter new recovery cache */
#define IC_OLDRC	43	/* leave current cache */
#define IC_RESRC	44	/* restore from current cache */

#define IC_XAR		45	/* extract array elements */
#define IC_NEWSUBJ	46	/* define new subject */
#define IC_OLDSUBJ	47	/* restore old subject */
#define IC_SUBJECT	48	/* current subject */
#define IC_LINE		49	/* line increment */
#define IC_ALINE	50	/* absolute line number */
#define IC_UNDEF	51	/* undefined value */

#define IC_NEWCLASS	52	/* create new class object */
#define IC_CLOC		53	/* fetch class local */
#define IC_ASCLOC	54	/* assign to class local */
#define IC_FLD		55	/* fetch field from class */
#define IC_XFLD		56	/* fetch (large) field from class */
#define IC_ASFLD	57	/* assign to field in class */
#define IC_XASFLD	58	/* assign to (large) field in class */

#define IC_XCALL	59	/* extended call operator */

#define IC_GOCASE	60	/* case table jump */
#define IC_ERROR	61	/* generate error message */
#define IC_IFLD		62	/* fetch field ignoring associations */
#define IC_XIFLD	63	/* fetch (large) field ignoring assocs */
#define IC_IASFLD	64	/* store in field ignoring associations */
#define IC_XIASFLD	65	/* store in (large) field ignoring assocs */
#define IC_SELF		66	/* current class object */
#define IC_DUP		67	/* duplicate stack top */
#define IC_LAST		68	/* last operator defined */
