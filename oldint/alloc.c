#
/*
 * Summer -- storage allocation routines
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include	"summer.h"


/*
 * Create a string object that can contain "n" characters.
 * The caller will define the character contents of the string.
 */

STRING newstring(n)
register int n;{
	register STRING r;

	if(n <= 0)
		if(n == 0)
			return(nullstring);
		else
			syserror("newstring -- negative size");
	r = CAST(STRING) alloc(SZ_STR + n * SZ_CHAR);
	r->dt.dt_val = DT_STRING;
	r->str_size = n;
	return(r);
}


STRING newstr3(s)
register char *s;{			/* pointer outside floating area */
	register int n;
	register STRING p;

	n = 0;
	while(s[n] != '\0')
		n++;
	p = newstring(n);
	copy(s, &s[n], p->str_contents);
	return(p);
}

INTEGER newinteger(n)
register int n;{
	register INTEGER r;

	if((n >= -NINTEGERS/2) && (n <= NINTEGERS/2))
		return(&intbase[n + NINTEGERS/2]);
	r = CAST(INTEGER) alloc(SZ_INTEGER);
	r->dt.dt_val = DT_INTEGER;
	r->int_val = n;
	return(r);
}

REAL newreal(v)
double v;{
	register REAL r;

	r = CAST(REAL) alloc(SZ_REAL);
	r->dt.dt_val = DT_REAL;
	r->real_val = v;
	return(r);
}


ARRAY newarray(size, prefill)
register int size;
SUMDP *prefill;	{		/* *prefill must be save */
	register ARRAY s;
	register int i, size1;

	size1 = (size == 0) ? 1 : size;
	s = CAST(ARRAY) alloc(SZ_ARRAY + size1 * SZ_SUMDP);
	s->dt.dt_val = DT_ARRAY;
	s->ar_size = size;
	s->ar_fill = size;
	for(i = 0; i < size1; i++)
		s->ar_elements[i] = *prefill;
	return(s);
}

struct bits *newbits(nelem, def)
int nelem, def;{
	register struct bits *b;
	register int i, n;

	if(nelem < 0)
		error("negative or zero bits size");
	if(def != 0)
		if(def == 1)
			def = ~0;
		else
			error("illegal default value for bits");
	b = CAST(BITS) alloc(SZ_BITS(nelem));
	b->dt.dt_val = DT_BITS;
	b->bits_size = nelem;
	n = (nelem + BPW) / BPW;	/* # of words occupied */
	for(i = 0; i < n; i++)
		b->bits_elements[i] = def;
	return(b);
}


/*
 * Table of primes used to compute "optimal" tables sizes.
 * The algorithm used is:
 *	- divide required size by 5 (i.e. average load per bucket = 5)
 *	- search in primes for value closest to size/5 and
 *	  use this as tables size.
 */

int primes[] = {
	97, 89, 83, 79, 73, 67, 59, 49, 43, 37,
	29, 23, 17, 11,  3, -1,
};

TABLE newtable(nelem, def, realsize)
int nelem;
SUMDP *def; {			/* *def must be save */
	register TABLE p;
	register int i, nentries;

	if(nelem < 0)
		error("negative table size");
	if(realsize)
		nentries = nelem;
	else {
		nelem = (nelem + 5) / 5;
#ifdef CGDEBUG
		if(!legaldt(*def, 1) && INFLOAT(*def)){
			/* take case label case into account */
			syserror("newtable def");
		}
#endif
		for(i = 1; primes[i] > nelem; i++)
			;
		nentries = primes[i - 1];
	}
	p = CAST(TABLE) alloc(SZ_TABLE  + nentries * SZ_PTR);
	p->dt.dt_val = DT_TABLE ;
	p->tab_size = nentries;
	p->tab_default = *def;
	for(i = 0; i < nentries; i++)
		p->tab_elements[i] = NIL;
	return(p);
}



FILE newfile(fd, type, bufsize)
int fd, type, bufsize;{
	register FILE fp;

	fp = CAST(FILE) alloc(SZ_FILE + bufsize * SZ_CHAR);
	fp->dt.dt_val = DT_FILE;
	fp->fl_access = type;
	fp->fl_lastaccess = (type == READWRITEACCESS) ? READACCESS : type;
	fp->fl_descr = fd;
	fp->fl_bufsize = bufsize;
	fp->fl_offset = fp->fl_nleft = fp->fl_index = 0;
	fp->fl_length = (type == WRITEACCESS) ? 0 : filesize(fp);
	return(fp);
}

struct heapmark *newheapmark(){
	register struct heapmark *p;

	p = CAST(HEAPMARK) alloc(SZ_HEAPMARK);
	p->dt.dt_val = DT_HEAPMARK;
	p->hm_dummy = 0;
	return(p);
}


struct class * newclass(ctype, init)
int ctype, init;{
	register int i, size;
	register struct class * c;
	int nformals;

	if((ctype <= DT_LAST) || (ctype >= nclasses))
		syserror("newclass");
	size = class_sizes[ctype];
	if(init && (DT(argbase[0]) != DT_UNDEFINED))
		/*
		 * Creation procedure invoked during subclass creation.
		 * Return the (already allocated) subclass object.
		 * NOTE: the init flag is in fact misused here; we
		 * know that (init==1) only holds when newclass is
		 * called from eval. tricky!
		 */
		return(T_CLASS(argbase[0]));
	c = CAST(CLASS) alloc(SZ_CLASS + size * SZ_SUMDP);
	c->dt.dt_val = ctype;
	if(init){
		nformals = cursp->stk_proc->proc_nform;
		for(i = 0; i < size; i++)
			if(i + 1 < nformals)
				c->class_elements[i] = argbase[i + 1];
			else
				c->class_elements[i] = undefined;
	}
	return(c);
}
