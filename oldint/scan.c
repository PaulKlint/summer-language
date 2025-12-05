#
/*
 * Summer -- definition of (built-in) scan_string type
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include	"summer.h"
#define SUBJ_CHAR(n)	((subj_type==DT_STRING) ? \
			T_STRING(subj_text)->str_contents[n] :\
			flsubj_char(n))
extern STRING subjsubstr();
#define SCANFAIL(n) return(NIL)
#define SUCC(n)	
#define ID(proc,arg)	

#define SWITCHSUBJECT	if(T_CLASS(ARG0) != subject) switchsubject(ARG0)
/*
 * flsubj_char : get character n from the current subject file.
 */

char flsubj_char(n)
int n;{
	register int off, bcontents, k;
	char c;

	bcontents = T_FILE(subj_text)->fl_index + T_FILE(subj_text)->fl_nleft;
	off = T_FILE(subj_text)->fl_offset;
	if((n < off) && (n >= off - bcontents)){
		/*
		 * character n lies in the buffer.
		 */
		k = T_FILE(subj_text)->fl_index = n - (off - bcontents) + 1;
		T_FILE(subj_text)->fl_nleft = bcontents - k;
		return(T_FILE(subj_text)->fl_buffer[k - 1]);
	} else {
		/*
		 * Character lies outside buffer, seek to position n.
		 */
	lseek_retry:
		if(lseek(T_FILE(subj_text)->fl_descr, CAST(long) n, 0) < 0){
			INTERRUPT(lseek_retry);
			error("seek failed on subject file");
		}
		T_FILE(subj_text)->fl_nleft = 0;
		T_FILE(subj_text)->fl_offset = n;
		c = fgetc(T_FILE(subj_text));
		return(c);
	}
}

/*
 * Return character n from string subj_text.
 *

char strsubj_char(n)
int n;{
	return(T_STRING(subj_text)->str_contents[n]);
}
 */

/*
 * Select the substring [from,to] from current subject string
 */
STRING subjsubstr(from, to)
int from, to;{
	register STRING p;
	register int i, size;

	/*
	 * Swap from and to if necessary. The situation from > to may
	 * arise from during pattern matching if move has moved the
	 * cursor to the left.
	 */
	if(from > to){
		i = from;
		from = to;
		to = i;
	}
	if(DT(subj_text) == DT_STRING)
		p = substr(&subj_text, from, to);
	else
	if(DT(subj_text) == DT_FILE){
		size = to - from;
		p = newstring(size);
		for(i = 0; i < size; i++)
			p->str_contents[i] = flsubj_char(from + i);
	} else
		syserror("subjsubstr");
	return(p);
}

showsubject(s)
struct class *s;{		/* scan_string */
	char c;
	int i, from, to, n, curs, delta;

	if(s->dt.dt_val != DT_SCAN_STRING)
		syserror("showsubject");
	switchsubject(s);
	n = subj_curs->int_val;
	if(n > 72){
		from = max(subj_curs->int_val - 32, 0);
		to   = min(subj_curs->int_val + 32, n);
	} else {
		from = 0;
		to = n;
	}
	delta = 0;
	fputc(stand_out, '\n');
        for(i = from; i < to; i++){
		c = SUBJ_CHAR(i);
		switch(c){
		case '\t':
			putstring("\\t");
			if(i < curs)
				delta++;
			break;
		case '\n':
			putstring("\\n");
			if(i < curs)
				delta++;
			break;
		default:
			fputc(stand_out, c);
		}
	}
	fputc(stand_out, '\n');
	for(i = 0; i < curs + delta; i++)
		fputc(stand_out, ' ');
	putstring("!\n");
	subject = NIL;
}

SUBR STRING F_SClit(){
	register int imax, i, base;
	int bcontents, off, c;
	STRING s;	/* union(string,file) */

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_STRING);
	SWITCHSUBJECT;
	s = T_STRING(ARG1);
	imax = s->str_size;
	c = subj_curs->int_val;
	if(c + imax > subj_size){
		SCANFAIL(0);
	}
	if(DT(subj_text) == DT_STRING){
		for(i = 0; i < imax; i++)
			if(T_STRING(subj_text)->str_contents[c + i] !=
			   s->str_contents[i]){
				SCANFAIL(0);
			}
		newcursor(c + imax);
		return(T_STRING(ARG1));	/* ARG1 is the safe version of s */
	}
	if(DT(subj_text) != DT_FILE)
		syserror("lit");
	bcontents = T_FILE(subj_text)->fl_index + T_FILE(subj_text)->fl_nleft;
	off = T_FILE(subj_text)->fl_offset;
	if((c < off) && (c + imax < off) &&
	   (c >= off - bcontents)){
		/*
		 * Important special case: the whole literal
		 * string to be matched lies in the subject
		 * file buffer. Do a fast match.
		 */
		base = c - (off - bcontents);
		for(i = 0; i < imax; i++)
			if(T_FILE(subj_text)->fl_buffer[base + i] !=
			   s->str_contents[i]){
				SCANFAIL(0);
			}
		newcursor(c + imax);
		T_FILE(subj_text)->fl_index = base + imax;
		T_FILE(subj_text)->fl_nleft = bcontents - T_FILE(subj_text)->fl_index;
                return(T_STRING(ARG1));   /* ARG1 is the safe version of s */
	} else {
		/*
		 * Do it the normal way, by means of flsubj_char calls.
		 */
		for(i = 0; i < imax; i++)
			if(flsubj_char(c + i) != s->str_contents[i]){
				SCANFAIL(0);
			}
		newcursor(c + imax);
                return(T_STRING(ARG1));   /* ARG1 is the safe version of s */
	}
}

newcursor(n)
int n;{
	if(curcache != NIL){
		SUMDP s;

		T_CLASS(s) = subject;	/* conversion from CLASS to SUMDP */
		save_in_cache(s, 2);
	}
	T_INTEGER(subject->class_elements[1]) = subj_curs = newinteger(n);
}

scan_restore(){
	if(scan_subject != NIL)
		switchsubject(scan_subject);
	subject = NIL;	/* force switchsubject next time */
}


STRING scanval(from, to)
int from, to;{
	newcursor(to);
	if(retcnt == 0)
		return(nullstring);
	else
		return(subjsubstr(from, to));
};


/*
 * Class creation procedure for scan_string.
 * This procedure is equivalent with the procedure created for:
 *	class scan_string(text)
 *	begin var cursor;
 *	end
 * Note that ARG0 is unused, but is required for the general case.
 */
SUBR CLASS _scan_string(){
	struct class *s;

	ARGCNT(2);
	if((DT(ARG1) != DT_STRING) && (DT(ARG1) != DT_FILE))
		error("scan_string called with argument of wrong type");
	s = newclass(DT_SCAN_STRING, 0);
	s->class_elements[0] = ARG1;
	T_INTEGER(s->class_elements[1]) = ZERO;
	return(s);
}

newsubject(s)
SUMDP s;{
	Gevalsp.sp_subjdescr->prev = cursubjp;
	T_CLASS(Gevalsp.sp_subjdescr->subject) = scan_subject;
	cursubjp = Gevalsp.sp_subjdescr;
	Gevalsp.sp_subjdescr++;
	if(DT(s) == DT_SCAN_STRING){
		scan_subject = T_CLASS(s);
		switchsubject(s);
		return;
	}
	if(DT(s) == DT_FILE){
		T_FILE(s) = tofile(s, READACCESS);
	} else
	if(DT(s) == DT_STRING){
	} else {
		scan_subject = T_CLASS(s);
		return;
	}
	PUSHSUMDP(Gevalsp,s);		/* save for garbage collector */
	scan_subject = newclass(DT_SCAN_STRING, 0);
	scan_subject->class_elements[0] = POP(Gevalsp);
	T_INTEGER(scan_subject->class_elements[1]) = ZERO;
	switchsubject(scan_subject);
	return;
}

oldsubject(){
	if(T_CLASS(cursubjp->subject) != NIL)
		switchsubject(cursubjp->subject);
	else
		subject = NIL;
	scan_subject = T_CLASS(cursubjp->subject);
	cursubjp = cursubjp->prev;
}

switchsubject(s)
SUMDP s;{
	if(DT(s) == DT_SCAN_STRING){
		subject = T_CLASS(s);
		subj_text = subject->class_elements[0];
		subj_curs = T_INTEGER(subject->class_elements[1]);
		if(DT(subj_text) == DT_STRING){
			subj_type = DT_STRING;
			subj_size = T_STRING(subj_text)->str_size;
		} else
		if(DT(subj_text) == DT_FILE){
			subj_type = DT_FILE;
			subj_size = filesize(subj_text);
		} else
			syserror("switchsubject");
	}
}

SUBR STRING F_SCmove(){
	register int from, to;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_INTEGER);
	SWITCHSUBJECT;
	from = subj_curs->int_val;
	to   = from + INTVAL(ARG1);
	if((to >= 0) && (to <= subj_size))
		return(scanval(from, to));
	else {
		SCANFAIL(0);
	}
}

SUBR STRING F_SCpos(){
	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_INTEGER);
	SWITCHSUBJECT;
	if(subj_curs->int_val != T_INTEGER(ARG1)->int_val){
		SCANFAIL(0);
	}
	return(nullstring);
}

SUBR STRING F_SCrpos(){
	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_INTEGER);
	SWITCHSUBJECT;
	if(subj_curs->int_val != subj_size - T_INTEGER(ARG1)->int_val){
		SCANFAIL(0);
	}
	return(nullstring);
}

SUBR STRING F_SCtab(){
	register int from, to;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_INTEGER);
	SWITCHSUBJECT;
	from = subj_curs->int_val;
	to   = INTVAL(ARG1);
	if((to >= 0) && (to <= subj_size))
		return(scanval(from, to));
	else {
		SCANFAIL(0);
	}
}

SUBR STRING F_SCrtab(){
	register int from, to;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_INTEGER);
	SWITCHSUBJECT;
	from = subj_curs->int_val;
	to = subj_size - INTVAL(ARG1);
	if((to >= 0) && (to <= subj_size))
		return(scanval(from, to));
	else {
		SCANFAIL(0);
	}
}


int chsets[NCHAR];
struct {
	STRING	str;
	int	mask;
} prev_chsets[BPW];
int nextset;

#define inset(set,char)	(chsets[char]&set)

defset(astr)
STRING astr;{
	register int i, k, mask;

	for(i = nextset - 1; i >= 0; i--)
		if(prev_chsets[i].str == astr){
			return(prev_chsets[i].mask);
		}
	if(nextset == BPW){
		/*
		 * All character sets are occupied.
		 * Remove first 5 entries.
		 */
		k = 0;
		for(i = 5; i < nextset; i++){
			prev_chsets[k].str = prev_chsets[i].str;
			prev_chsets[k].mask= prev_chsets[i].mask;
			k++;
		}
		nextset = k;
	}
	if(nextset == 0)
		mask = 1;
	else {
		k = prev_chsets[nextset - 1].mask;
		k <<= 1;
		if(k == 0)
			k = 1;
		mask = k;
	}
	prev_chsets[nextset].str = astr;
	prev_chsets[nextset].mask = mask;
	nextset++;
	for(i = 0; i < NCHAR; i++)
		chsets[i] &= ~mask;

	for(i = astr->str_size - 1; i >= 0; i--)
		chsets[astr->str_contents[i]] |= mask;
	return(mask);
}

SUBR STRING F_SCany(){
	register int from;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_STRING);
	SWITCHSUBJECT;
	from = subj_curs->int_val;
	if(from == subj_size){
		SCANFAIL(0);
	} else {
		if(inset(defset(T_STRING(ARG1)),SUBJ_CHAR(from)))
			return(scanval(from, from + 1));
		SCANFAIL(0);
	}
}
/*
#define ID(proc,arg) {printf("%s(%d)", proc, arg->str_size);}
#define  SCANFAIL(nch) {printf(" F(%d)\n", nch); return(NIL);}
#define SUCC(nch) {printf(" S(%d)\n", nch);}
*/
SUBR STRING F_SCspan(){
	int set;
	register int from, to;
	register char c;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_STRING);
	SWITCHSUBJECT;
	ID(\"span\",ARG1);
	from = to = subj_curs->int_val;
	if(from == subj_size){
		SCANFAIL(0);
	}
	if(T_STRING(ARG1)->str_size == 1){
		c = T_STRING(ARG1)->str_contents[0];
		if(SUBJ_CHAR(to) != c){
			SCANFAIL(to-from);
		}
		do
			to++;
		while((to < subj_size) && SUBJ_CHAR(to) == c);
	} else {
		set = defset(T_STRING(ARG1));
		if(!inset(set,SUBJ_CHAR(to))){
			SCANFAIL(to-from);
		}
		do
			to++;
		while((to < subj_size) && inset(set,SUBJ_CHAR(to)));
	}
	SUCC(to-from);
	return(scanval(from, to));
}

#define SCANFAIL(n) return(NIL)
#define SUCC(n)	
#define ID(proc,arg)	
/*
#define ID(proc,arg) {printf("%s(%d)", proc, arg->str_size);}
#define  SCANFAIL(nch) {printf(" F(%d)\n", nch); return(NIL);}
#define SUCC(nch) {printf(" S(%d)\n", nch);}
*/
SUBR STRING F_SCbreak(){
	int set;
	int from;
	register int to;
	register char c;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_STRING);
	SWITCHSUBJECT;
	ID(\"break\",ARG1);
	from = to = subj_curs->int_val;
	if(T_STRING(ARG1)->str_size == 1){
		c = T_STRING(ARG1)->str_contents[0];
		while(1) {
			if(to >= subj_size){
				SCANFAIL(to-from);
			}
			if(SUBJ_CHAR(to) == c){
				SUCC(to-from);
				return(scanval(from, to));
			}
			to++;
		}
	} else {
		set = defset(T_STRING(ARG1));
		while(1) {
			if(to >= subj_size){
				SCANFAIL(to-from);
			}
			if(inset(set,SUBJ_CHAR(to))){
				SUCC(to-from);
				return(scanval(from, to));
			}
			to++;
		}
	}
}
#define SCANFAIL(n) return(NIL)
#define SUCC(n)	
#define ID(proc,arg)	

SUBR STRING F_SCbal(){
	int set1, set2, set3;
	register int n, count;
	register char c;

	ARGCNT(4);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_STRING);
	ARGTYPE(2,DT_STRING);
	ARGTYPE(3,DT_STRING);
	SWITCHSUBJECT;
	set1 = defset(T_STRING(ARG1));
	set2 = defset(T_STRING(ARG2));
	set3 = defset(T_STRING(ARG3));

	count = 0;
	for(n = subj_curs->int_val; n < subj_size; n++){
		c = SUBJ_CHAR(n);
		if(inset(set2,c))
			count++;
		if(inset(set3,c))
			count--;
		if(count < 0)
			break;
		else
		if(count == 0)
			if((n < subj_size) && inset(set1,SUBJ_CHAR(n+1)))
				return(scanval(subj_curs->int_val, n + 1));
	}
	SCANFAIL(0);
}

SUBR STRING F_SCfind(){
	register int n, i, imax;

	ARGCNT(2);
	ARGTYPE(0,DT_SCAN_STRING);
	ARGTYPE(1,DT_STRING);
	SWITCHSUBJECT;
	imax = T_STRING(ARG1)->str_size;
/* this algorithm should be improved ! */
	for(n = subj_curs->int_val; n + imax <= subj_size; n++){
		for(i = imax - 1; i >= 0; i--)
			if(SUBJ_CHAR(n+i) != T_STRING(ARG1)->str_contents[i])
				break;
		if(i < 0)
			return(scanval(subj_curs->int_val, n));
	}
	SCANFAIL(0);
}

struct subr SCany, SCbal, SCbreak, SCfind, SClit, SCmove, SCpos,
	    SCrpos, SCrtab, SCspan, SCtab;

scan_init(){
	extern struct fld f_any, f_bal, f_break, f_find, f_lit, f_move,
			  f_pos, f_rpos, f_rtab, f_span, f_tab;

	DCLSUBR(SCany,F_SCany,&f_any,cvt_string);
	DCLSUBR(SCbal,F_SCbal,&f_bal,cvt_string);
	DCLSUBR(SCbreak,F_SCbreak,&f_break,cvt_string);
	DCLSUBR(SCfind,F_SCfind,&f_find,cvt_string);
	DCLSUBR(SClit,F_SClit,&f_lit,cvt_string);
	DCLSUBR(SCmove,F_SCmove,&f_move,cvt_string);
	DCLSUBR(SCpos,F_SCpos,&f_pos,cvt_string);
	DCLSUBR(SCrpos,F_SCrpos,&f_rpos,cvt_string);
	DCLSUBR(SCrtab,F_SCrtab,&f_rtab,cvt_string);
	DCLSUBR(SCspan,F_SCspan,&f_break,cvt_string);
	DCLSUBR(SCtab,F_SCtab,&f_tab,cvt_string);
}
scan_mark(){
	register int i;

	mark(&subject);
	mark(&scan_subject);
	mark(&subj_text);
	mark(&subj_curs);
	for(i = nextset - 1; i >= 0; i--)
		mark(&prev_chsets[i].str);
}
