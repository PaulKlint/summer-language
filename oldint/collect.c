#
/*
 * Summer - garbage collector
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */
/*
 * The garbage collection strategy imposes the following restrictions on
 * data objects:
 * - the first word of an object contains a type code from which the
 *   size of the object and locations of pointers in the object, can
 *   can be determined.
 * - only pointers to the head (i.e. the type code word) of objects
 *   are allowed.
 * - if an object contains pointers, these must be located at the end of
 *   the object, thus in general an object consist of pointer free heading
 *   followed by a (perhaps variable) number of pointers.
 * - objects are at least two words long (this guarantees that space
 *   is always available for the usedtable, see below)
 *
 *
 * Garbage collection proceeds in three stages:
 * - marking: all accessible objects are located and the op fields are
 *   used to build for each accessible object, a list of pointers to that
 *   object. This list is used in the next step for pointer relocation.
 *   A marked object is distinguished from an unmarked by the contents
 *   of its op field:
 *   - if the op field contains a legal opcode (0 <= opcode <= DT_LAST)
 *     the object is unmarked.
 *   - if the op field does not contain a legal opcode, the op field
 *     contains a pointer to a chain of references to this node.
 *     This chain is terminated by the old op field value of the current,
 *     which can be hence be recovered.
 *   If an object A contains pointers and one of these pointers (say Q) points
 *   to an object B (which contains pointers), which should be marked,
 *   then the value of Q, the end of A and an increment value are saved
 *   on the evalstack.
 *   Next all pointers in B are followed. Upon completion the marking of A
 *   is resumed, by restoring the values which were saved when the marking
 *   of A was interrupted.
 * - adjusting: make a lineair search through the whole memory and change
 *   all pointers in accessible objects, to their new values.
 *   This scan uses the uses the reference chain as build up by the mark scan.
 *   The adjust scan in its turn builds a relocation table for the next scan.
 *   This table start in usedblock and lives as 2 word nodes in the
 *   garbage in the floating area. As a consequence, data objects must
 *   consist of at least two words.
 *   Each node resides immediately before one
 *   or more non garbage blocks and contains:
 *   - a link to the next node
 *   - the size of the marked blocks which follow.
 *   The above information is sufficient for a simple and fast compacting scan.
 * - compacting: move all accessible objects to the bottom of memory.
 *
 * Note: a provision has been made to allow the moving of the whole memory
 * to a new base address (floor / newfloor). this feature is not (yet) used.
 */

#include "summer.h"
int thres = 3;
struct usedblock {
	struct usedblock	*used_next;
	int			used_size;
} acclist;

/*
 * allocate storage for an object of size "nbytes". If no more storage is
 * available, initiate a garbage collection. If then garbage collection
 * does not find enough space, execution is terminated with an error message.
 *
 * Note: the percentage of freed memory, which allows a program to continue,
 * will become under user control shortly.
 */

char *alloc(nbytes){
	register char *r;
	register int incr;
	int free, used, req, er;
	SUMDP nceil;
	SUMDP maxceil;
	static int maxused;

/*
printf("alloc(%d)\n", nbytes);
printf("surf = %x\n", surf);
*/
	if(nbytes <= 0)
		syserror("alloc -- negative object size");
	incr = (nbytes + SZ_SUMDP - 1)/SZ_SUMDP;
        if((T_DATATYPE(surf) + incr > T_DATATYPE(ceil)) || (T_DATATYPE(surf) + incr < T_DATATYPE(surf))){
		/* 2nd test check integer overflow */
		collect();
		used = T_DATATYPE(surf) - T_DATATYPE(floor);
		used += incr;
		free = T_DATATYPE(ceil) - T_DATATYPE(surf);
		free -= incr;
		if(((free <= 0) || (used/free > thres)) && !maxused){
			req = (used/thres + ALLOCINCR) - free + incr;
			T_DATATYPE(maxceil) = CAST(DATATYPE) MAXCEIL;
			T_DATATYPE(nceil) = T_DATATYPE(ceil) + req;
			if((T_DATATYPE(nceil) > T_DATATYPE(maxceil)) ||
			   (T_DATATYPE(nceil) < T_DATATYPE(ceil)))
				nceil = maxceil;
			req = T_DATATYPE(nceil) - T_DATATYPE(ceil);
		brk_r1:
			er = brk(nceil);
			if(er < 0)
				INTERRUPT(brk_r1);
			while((er != 0) && (req > 500)){
				maxused = 1;
				req -= 500;
				T_DATATYPE(nceil) = T_DATATYPE(ceil) + req;
			brk_r2:
				er = brk(nceil);
				if(er < 0)
					INTERRUPT(brk_r2);
			}
			if(er == 0){
				ceil = nceil;
			}
		}
		if(T_DATATYPE(surf) + incr > T_DATATYPE(ceil))
			error("Not enough memory");
	}
	r = CAST(char *) T_DATATYPE(surf);
	T_DATATYPE(surf) += incr;
/*
printf("returns: %x\n", r);
printf("surf: %x\n", surf);
*/
	return(r);
}

collect(){
	register struct stack *s;
	SUMDP *p;
	SUMDP *endp;
	struct cache *c;
	extern SUMDP globals[];
	extern SUMDP eglobals;
	long time;

#ifdef ATSTATS
	extern int _stop();
	putstring("\nGARBAGE COLLECTION -- program stopped\n");
	call(1, _stop, ONE);
#endif
	if(c_lock)
		syserror("nested collect call");
	c_lock++;
#ifdef CGDEBUG
checksystem();
putstring("START GARBAGE COLLECTION\n");
#endif
	if(profiling)
		time = cputime();

	vm_sequential();
#ifdef CGSTATS
	cgstats(0);
#endif
	scan_mark();
	tracer_mark();
	table_mark();
	mark(&ar2->ar_elements[0]);
	mark(&ar2->ar_elements[1]);

	/*
	 * mark all global variables
	 */
	for(p = globals; p < &eglobals; p++)
			mark(p);
	/*
	 * Mark all values in the cache memory.
	 */

	for(c = cachemem; c < cachetop; c++){
		mark(&c->val_base);
		mark(&c->val_old);
	}
	/*
	 * Mark the stack.
	 */

	endp = Gevalsp.sp_psumdp;
	for(s = cursp; s != NIL; s = s->stk_prev){
		for(p = (CAST(SUMDP *) &s->stk_flab); p < endp; p++)
			mark(p);
		endp = CAST(SUMDP *) s;
	}
	/*
	 * Mark the args of the main program.
	 */
	for(p = CAST(SUMDP *) evalstack; p < endp; p++)
		mark(p);
	adjust();

	ncollect++;
	c_lock--;
#ifdef CGDEBUG
putstring("\nEND GARBAGE COLLECTION\n");
/*
	printf("\n%d words of storage regenerated\n", T_DATATYPE(ceil) - T_DATATYPE(surf));
	printstack();
*/
	checksystem();
#endif
#ifdef CGSTATS
	cgstats(1);
#endif
	if(profiling){
		time = cputime() - time;
		col_time += time;
		entry_time -= time;
	}
	vm_normal();
}

mark(ap)
SUMDP *ap;{
	register SUMDP *q;
	register SUMDP cand;
	SUMDP *finish;
	SUMDP *firstp;
	SUMDP *lastp;
	SUMDP *spstart;
	int opfield;
	SUMDP nodep;
	int iap;

	if(!INFLOAT(*ap))
		return;		/* nothing to do */
	/*
	 * Initialize:
	 * cand points to a block to be marked.
	 * q points to a particular pointer in that block.
	 * finish points to (last pointer + 1) in cand
	 */
	iap = CAST(int) ap;
	if(UNMARKED(iap))
		/*
		 * Address "ap" can not be distinguished from a
		 * legal opcode value. This is a basic assumption
		 * of this garbage collector.
		 */
		syserror("mark -- ambiguous pointer");
	cand = *ap;
	T_DTVAL(*ap) = DT(cand);
	if(!UNMARKED(DT(cand))){
		/*
		 * cand was already marked, ap has been prepended to the list
		 * of pointers to cand, nothing more to do.
		 */
		T_DATATYPE(cand)->dt.dt_psumdp = ap;
		return;
	}

	limits(cand, &firstp, &finish);
	q = firstp - 1;
	T_DATATYPE(cand)->dt.dt_psumdp = ap;
	spstart = Gevalsp.sp_psumdp;
	/*
	 * mark next pointer.
	 */
nextp:
	q++;
	if(q < finish){		/* q is still contained in current block */
		nodep = *q;
		if(INFLOAT(nodep)){
			/*
			 * q points to a floating address and should be marked
			 */
			cand = *q;
			opfield = DT(cand);
			T_DTVAL(*q) = opfield;
			if(UNMARKED(opfield)){	/* not yet marked */
				limits(cand, &firstp, &lastp);
				if(firstp != lastp){	/* cand contains pointers */
					if(q + 1 < finish){
						/*
						 * Not all pointers of the
						 * current block have been
						 * visited. Remember current
						 * block and current pointer.
						 *
						 */
						if(Gevalsp.sp_psumdp+2>=evaltop.sp_psumdp)
							error("stack overflow\
 during garbage collection");
						PUSHPSUMDP(Gevalsp,q);
						PUSHPSUMDP(Gevalsp,finish);
					}
				T_DATATYPE(cand)->dt.dt_psumdp = q;
				q = firstp - 1;
				finish = lastp;
				goto nextp;
				}
			}
			T_DATATYPE(cand)->dt.dt_psumdp = q;
		}
		goto nextp;
	} else {			/* end of p: recover previous block */
		if(Gevalsp.sp_psumdp == spstart)
			return;
		else {
			finish = CAST(SUMDP *) T_DATATYPE(POP(Gevalsp));
			q = CAST(SUMDP *) T_DATATYPE(POP(Gevalsp));
			goto nextp;
		}
	}
}

adjust(){
	register SUMDP new;
	register SUMDP *q;
	register int opfield;
	SUMDP old;
	struct usedblock *p;
	SUMDP *b;
	SUMDP *e;
	int incr, iq;

	p = &acclist;
	p->used_size = 0;
	p->used_next = CAST(struct usedblock *) T_DATATYPE(floor);
	new = floor;

	old = floor;
	while(T_DATATYPE(old) < T_DATATYPE(surf)){
		iq = DT(old);
#ifdef CGDEBUG
/*
printf(">old=%d, new=%d, dt=%d\n", old, new, iq);
printf(" p=%d, used_size=%d, used_next=%d\n", p, p->used_size, p->used_next);
*/
#endif
		if(UNMARKED(iq)){	/* garbage */
			limits(old, &b, &e);
			incr = e - CAST(SUMDP *) T_DATATYPE(old);
			T_DATATYPE(old) += incr;
		} else {			/* add to accessible list */
			q = T_DATATYPE(old)->dt.dt_psumdp;
			do {
				/*
				 * Traverse the list of all references to the
				 * block at location old, and change all these
				 * references to location new.
				 * This list starts in old->dt and is
				 * terminated with a legal opcode value.
				 * This opcode value must be restored in
				 * block old.
				 *
				 */
				opfield = T_DTVAL(*q);
				*q = new;
				q = CAST(SUMDP *) (CAST(char *) opfield);
			} while(!UNMARKED(opfield));
			DT(old) = opfield; /* restore original dt code */
			limits(old, &b, &e);
			incr = e - CAST(SUMDP *) T_DATATYPE(old);
			if(p->used_next == CAST(struct usedblock *) T_DATATYPE(old)){
				/*
				 * Add block at old to a contiguous area
				 * of marked blocks.
				 *
				 */
				p->used_next = CAST(struct usedblock *) (T_DATATYPE(old) + incr);
				p->used_size += incr;
			} else {
				/*
				 * Block at old is preceded by garbage.
				 * Start a new area of contiguous marked
				 * blocks.
				 */
				p->used_next = CAST(struct usedblock *) (T_DATATYPE(old) - 2);
				p = CAST(struct usedblock *) (T_DATATYPE(old) - 2);
				p->used_size = incr;
				p->used_next = CAST(struct usedblock *)
					       (T_DATATYPE(old) + incr);
			}
#ifdef CGDEBUG
			if((T_DATATYPE(new) + incr < T_DATATYPE(new)) || (T_DATATYPE(old) + incr < T_DATATYPE(old)))
				syserror("adjust");
#endif
			T_DATATYPE(new) += incr;
			T_DATATYPE(old) += incr;
		}
#ifdef CGDEBUG
/*
printf(" old=%d, new=%d, incr=%d\n", old, new, incr);
*/
#endif
	}
	surf = new;
	p->used_next = CAST(struct usedblock *) T_DATATYPE(ceil);
	compact();
}

compact(){
	register SUMDP new;
	register SUMDP p;
	register SUMDP pnext;
	int incr;
	struct usedblock *usp;

#ifdef CGDEBUG
/*
	for(usp = &acclist; usp->used_next < T_DATATYPE(ceil);
				usp = usp->used_next){
		printf("usp: %d, used_next: %d, used_size=%d\n", usp, usp->used_next,
					usp->used_size);
	}
*/
#endif

	T_DATATYPE(p) = CAST(DATATYPE) acclist.used_next;
		/* first element of accessible list */
	T_DATATYPE(new) = T_DATATYPE(floor) + acclist.used_size;
		/* points to new location of block */
	while(T_DATATYPE(p) != T_DATATYPE(ceil)){
		incr = (CAST(struct usedblock *) T_DATATYPE(p))->used_size;
		T_DATATYPE(pnext) = CAST(DATATYPE)
			(CAST(struct usedblock *) T_DATATYPE(p))->used_next;
			/* move size(p) words from p to new */
#ifdef CGDEBUG
/*
printf("p=%d, incr=%d, new=%d\n", p, incr, new);
*/
#endif
		move(T_DATATYPE(p) + 2, T_DATATYPE(p) + 2 + incr, new);
		T_DATATYPE(new) += incr;
		p = pnext;
	}
}

move(begin, end, to)
SUMDP begin;
SUMDP end;
SUMDP to;{
	register SUMDP b;
	register SUMDP e;
	register SUMDP t;

#ifdef CGDEBUG
/*
printf("move(%d, %d, %d)\n", begin, end, to);
*/
#endif
	b = begin;
	e = end;
	t = to;
	while(T_DATATYPE(b) < T_DATATYPE(e))
		*T_DATATYPE(t)++ = *T_DATATYPE(b)++;
}

copy(begin, end, to)
char *begin, *end, *to;{
#ifdef VAX
        asm(".set       .begin,4");
        asm(".set       .end,8");
        asm(".set       .to,12");
        asm("subl2      .begin(ap),.end(ap)");
        asm("movc3      .end(ap),*.begin(ap),*.to(ap)");
#else
	register char *b = begin, *e = end, *t = to;
	while(b < e)
		*t++ = *b++;
#endif
}

/*
 * Determine the locations of pointer value (if any) in the object
 * pointed at by "p".
 * On return the variables pointed at by "begin" and "end" have as
 * value:
 *	- A pointer to the first pointer value in the object.
 *	- A pointer to the first pfield not contained in the object.
 * If an object does not contain pointers, both variables point to
 * the first pfield not contained in the object.
 */


limits(p, begin, end)
register SUMDP p;
register SUMDP **begin;
register SUMDP **end;{
	register int n;

	*begin = CAST(SUMDP *) p.s_cast;
	switch(DT(p)){

	case DT_STRING:
		n = T_STRING(p)->str_size + SZ_SUMDP - 1;
		*begin += (SZ_STR + n * SZ_CHAR)/SZ_SUMDP;
		*end = *begin;
		break;
	case DT_ARRAY:
		*begin += SZ_ARRAY/SZ_SUMDP;
		*end = *begin + T_ARRAY(p)->ar_size;
		if(T_ARRAY(p)->ar_size == 0)
			*end += 1;
		break;
	case DT_TABLE:
		*begin += SZ_TABLE/SZ_SUMDP;
		*end = *begin + T_TABLE(p)->tab_size;
		*begin -= 1;		/* take default field into account */
		break;
	case DT_BITS:
		*begin += SZ_BITS(T_BITS(p)->bits_size)/SZ_SUMDP;
		*end = *begin;
		break;
	case DT_INTEGER:
		*begin += SZ_INTEGER/SZ_SUMDP;
		*end = *begin;
		break;
	case DT_REAL:
		*begin += SZ_REAL/SZ_SUMDP;
		*end = *begin;
		break;
	case DT_TABSYM:
		*end = *begin + SZ_TABSYM/SZ_SUMDP;
		*begin = *end - 3;
		break;
	case DT_FILE:
		*begin += (SZ_FILE+T_FILE(p)->fl_bufsize*SZ_CHAR+SZ_SUMDP-1) / SZ_SUMDP;
		*end = *begin;
		break;
	case DT_HEAPMARK:
		*begin += SZ_HEAPMARK/SZ_SUMDP;
		*end = *begin;
		break;
	default:
		n = DT(p);
		if((n > DT_LAST) && (n < nclasses)){
			*begin += SZ_CLASS/SZ_SUMDP;
			*end   = *begin + class_sizes[n];
			break;
		} else
			syserror("limits -- illegal cell");
	}
#ifdef CGDEBUG
/*
	printf("limits -- p=%d, b=%d, e=%d, dt=%d\n", p, *begin, *end, DT(p));
*/
#endif
}
#ifdef CGSTATS
struct cgstat {
	int	cnt;
	float	nbytes;
} prestats[DT_LAST+1], poststats[DT_LAST+1];

int substrcnt;
float substrnbytes;
float presize, postsize;
cgstats(n){
	float totbytes;

	pfield *p, *b, *e;
	int i, dt, k;
	struct cgstat *tab;


	for(p = floor; p < surf; p = e){
		limits(p, &b, &e);
		dt = DT(p) <= DT_LAST ? DT(p) : DT_LAST + 1;
		tab = (n == 0) ? &prestats[dt] : &poststats[dt];
		tab->cnt++;
		tab->nbytes += (e - p) * SZ_SUMDP;
	}
	if(n == 0){
		n = surf;
		presize = n;
		n = floor;
		presize -= n;
		return;
	} else {
		n = surf;
		postsize = n;
		n = floor;
		postsize -= n;
	}
	n = ceil;
	totbytes = n;
	n = floor;
	totbytes -= n;
	printf("---------------collection %d ------------ %6.0f bytes mem\n",
		ncollect, totbytes);
	printf("    substr\t%d\t%6.0f (%2.1f%%)\n\n",
		substrcnt, substrnbytes, (substrnbytes/presize)*100);
	for(i = 0; i < DT_LAST + 1; i++){
		printf("%10.s\t", &class_names[i]->str_contents);
		printf("%d\t%6.0f (%2.1f)%%\t",
			prestats[i].cnt, prestats[i].nbytes,
			(prestats[i].nbytes/presize) * 100.0);
		printf("%d\t%6.0f (%2.1f)%%\n",
			poststats[i].cnt, poststats[i].nbytes,
			(poststats[i].nbytes/postsize) * 100.0);
		prestats[i].cnt = poststats[i].cnt = 0;
		prestats[i].nbytes = poststats[i].nbytes = 0;
	}
	substrcnt = 0;
	substrnbytes = 0;
}
#endif
#ifdef CGDEBUG
legaldt(p, restricted)
SUMDP p;{
	if(DT(p) == DT_TABSYM || DT(p) == DT_HEAPMARK)
		return((restricted == 0) ? 1 : 0);
	else
	if((DT(p) >= 0) && (DT(p) < nclasses))
		return(1);
	else
		return(0);
}

checksystem(){
	int i,n;
	struct subjdescr *subjsp;
	struct stack *sp;
	SUMDP v;
	SUMDP *p;
	extern SUMDP globals[];
	extern SUMDP eglobals;
	SUMDP b;
	SUMDP e;
	struct cache *ch;
	if((subject != NIL) && !legaldt(subject, 1))
		syserror("wrong subject");
	if(T_DATATYPE(subj_text) != NIL)
		if((DT(subj_text) != DT_STRING) && (DT(subj_text) != DT_FILE))
			syserror("wrong subj_text");
	if((subj_curs != NIL) && (subj_curs->dt.dt_val != DT_INTEGER))
		syserror("wrong subj_curs");
	if((curline != NIL) && (curline->dt.dt_val != DT_STRING))
		syserror("wrong curline");
	if((storedcmd != NIL) && (storedcmd->dt.dt_val != DT_STRING))
		syserror("wrong storedcmd");
	for(subjsp = cursubjp; subjsp != NIL; subjsp = subjsp->prev){
		if(!legaldt(subjsp->subject, 1) &&
		    (T_CLASS(subjsp->subject) != NIL))
			syserror("wrong subject in stack");
	}
	if(curcache != NIL){
		for(ch = cachetop -1 ; ch >= curcache->cd_base; ch--)
			if(INFLOAT(ch->val_base) && !legaldt(ch->val_base))
				syserror("wrong base in cache");
			else
			if(!legaldt(ch->val_old))
				syserror("wrong old in cache");
	}

	if(ar2->dt.dt_val != DT_ARRAY)
		syserror("ar2");
	if(!legaldt(ar2->ar_elements[0], 1) ||
	   !legaldt(ar2->ar_elements[1], 1))
		syserror("ar2 -- elements");
	for(sp = cursp; sp != NIL; sp = sp->stk_prev){
		if(DT(sp->stk_proc) != DT_PROC)
			syserror("wrong stk_proc");
		n = sp->stk_proc->proc_ntot;
		for(i = 0; i < n; i++)
			v = (CAST(SUMDP *) sp)[-1 - i];
			if(!legaldt(v, 1))
				syserror("wrong local in stack");
	}
	for(p = globals; p < &eglobals; p++){
		v = *p;		/* necessary to avoid indirection problems */
				/* with *p. a C pecularity.		   */
		if(!legaldt(v, 1))
			syserror("wrong global");
	}
	for(v = floor; T_DATATYPE(v) < T_DATATYPE(surf); v = e){
		if(!legaldt(v, 0))
			syserror("illegal object in floating area");
		limits(v, &b, &e);
		if(DT(v) == DT_ARRAY){
			for(i = 0; i < T_ARRAY(v)->ar_size; i++)
				if(!legaldt(T_ARRAY(v)->ar_elements[i], 1))
					syserror("illegal array element");
		} else
		if(DT(v) == DT_TABLE){
			if(!legaldt(T_TABLE(v)->tab_default, 1) &&
			   INFLOAT(T_TABLE(v)->tab_default))
				syserror("table default");
			for(i = 0; i < T_TABLE(v)->tab_size; i++){
				struct tabsym *t;
				for(t = T_TABLE(v)->tab_elements[i]; t != NIL;
				    t = t->tsym_next){
					if(t->dt.dt_val != DT_TABSYM){
printf("table at %x\n", v);
printf("tabsym at %x\n", t);
						syserror("Wrong tabsym");
					}
				}
			}
		} else
		if(DT(v) > DT_LAST){
			for(i = 0; i < class_sizes[DT(v)]; i++)
				if(!legaldt(T_CLASS(v)->class_elements[i], 1))
					syserror("illegal class component");
		}
	}
}
#endif
