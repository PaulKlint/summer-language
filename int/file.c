#
/*
 * SUMMER -- file datatype
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include        "summer.h"

/*
 * Implementation restriction:
 * The current implementation has a rather simple-minded attitude towards
 * opening/closing of files when an recovery cache is active.
 * Currently these operations are simply forbidden.
 *
 * A more sophisticated scheme requires that to open a file for writing
 * with active cache, a temporary file is created instead.
 * When the top level cache is left, this temp file
 * should be moved to a file with the intended name.
 * This method is needed since it is otherwise not possible to
 * recover from the overwriting of an existing file.
 */

extern DATATYPE read_instance();
extern DATATYPE write_instance();

SUBR FILE _file(){
	char *name, stopchar, direction, mode, probe;
	int i, n, type, fd = -1, ermode = 1;
	FILE *f;
	STRING access;

	ARGCNT(3);
	ARGTYPE(1,DT_STRING);
	ARGTYPE(2,DT_STRING);
	access = T_STRING(ARG2);
	n = access->str_size;
	direction = (n > 0) ? access->str_contents[0] : '\0';
	mode = (n > 1) ? access->str_contents[1] : '\0';
	probe = (n > 2) ? access->str_contents[2] : '\0';
	if(curcache != NIL)
		/* This case requires a less crude approach */
		error("file creation not allowed with active cache");
	if(direction == 'r')
		switch(mode){
		case '\0':	type = READ; break;
		case 'b':	type = READBINARY; break;
		default:
		badtype:	error("Illegal access type");
		}
	else if(direction == 'w')
		switch(mode){
		case '\0':	type = WRITE; break;
		case 'b':	type = WRITEBINARY; break;
		default:	goto badtype;
		}
	if(probe == 'p' && type == READBINARY)
		ermode = 0;
	else if(probe != '\0')
		goto badtype;
	if(streq(T_STRING(ARG1), Sstand_in)){
		if(type == READ)
			return(stand_in);
		else
			goto badtype;
	} else if(streq(T_STRING(ARG1), Sstand_out)) {
		if(type == WRITE)
			return(stand_out);
		else
			goto badtype;	
	} else if(streq(T_STRING(ARG1), Sstand_er)) {
		if(type == WRITE)
			return(stand_er);
		else
			goto badtype;
	}
	n = T_STRING(ARG1)->str_size;
	name = T_STRING(ARG1)->str_contents;
	stopchar = name[n];
	name[n] = '\0';
	if(type == READ || type == READBINARY){
	open_r1:
		if((fd = open(name, 0)) < 0)
			INTERRUPT(open_r1);
	} else {
	creat_retry:
		if((fd = creat(name, 0666)) < 0)
			INTERRUPT(creat_retry);
	}
	name[n] = stopchar;
	if(fd < 0)
		FAIL;
	f = CAST(FILE *) Gevalsp.sp_psumdp;
	PUSHFILE(Gevalsp,newfile(fd,type));
	if(type == WRITEBINARY){
		put_bin_int(*f, undefined);
		put_bin_int(*f, nullstring);
		put_bin_int(*f, nclasses);
		for(i=0; i < nclasses; i++){
			write_instance(*f, class_names[i]);
			put_bin_int(*f, class_sizes[i]);
		}
	} else
	if(type == READBINARY){
		int nc, i, k, csize;
		STRING cname;

		T_DATATYPE((*f)->fl_undef) = CAST(DATATYPE) get_bin_int(*f);
		T_DATATYPE((*f)->fl_nullstring) = CAST(DATATYPE) get_bin_int(*f);
		nc = get_bin_int(*f);
		(*f)->fl_ctrans = newarray(nc, &undefined);
		for(i = 0; i < nc; i++){
			cname = CAST(STRING) read_instance(*f);
			csize = get_bin_int(*f);
			for(k = 0; k < nclasses; k++){
			  if(streq(cname, class_names[k]))
			    if(class_sizes[k] == csize){
			       T_INTEGER((*f)->fl_ctrans->ar_elements[i]) =
				  newinteger(k);
			       goto found;
			    } else
			    if(ermode)
			      error("read binary: incompatible definitions of class %v", cname);
			    else { POP(Gevalsp); FAIL; }
			}
			if(ermode)
			  error("read binary: class %v not defined", cname);
			else { POP(Gevalsp); FAIL; }
		found:	continue;
		}
	}
	POP(Gevalsp);
	return(*f);
}

SUBR STRING F_Fclose(){
	FILE fp;

	ARGCNT(1);
	ARGTYPE(0,DT_FILE);
	if(DT(ARG0) != DT_FILE)
		error("close called with non-file argument");
	if(curcache != NIL)
		/* this case must be treated more gentle ! */
		error("close forbidden with active cache");
	fp = T_FILE(ARG0);
	flflush(fp);
	if(fp->fl_descr > 2) {
	close_retry:
		if(close(fp->fl_descr) < 0){
			INTERRUPT(close_retry);
			error("can't close file");
		}
	}
	return(nullstring);
}


SUBR DATATYPE _get(){
	register int c, k;
	register FILE f;
	STRING r;
	char buf[MAXLINE];
	extern DATATYPE read_instance();

	f = stand_in;
	if(argcnt == 1){
		f = tofile(ARG0, READ);
		if((curcache != NIL) && (f != stand_in))
			save_file(f);
	}
	if(f->fl_access == READBINARY)
		return(read_instance(f));
	else {
		k = 0;
		while(1) {
			c = fgetc(f);
			if((c == '\n') || (c == -1)){
				if((c == -1) && (k == 0))
					FAIL;
				r = newstring(k);
				copy(buf, &buf[k], r->str_contents);
				return(T_DATATYPE(r));
			} else {
				buf[k++] = c;
	                        if(k == MAXLINE)
					error("too long input line");
                	}
		}
	}
}


SUBR DATATYPE F_Fget(){
	return(_get());
}

SUBR STRING _put(){
	register int i, imax;
	int argindex;
	register FILE f;
	extern FILE tofile();
	extern STRING intostr();
	extern STRING realtostr();
	SUMDP a;
	extern DATATYPE write_instance();

	f = stand_out;
	argindex = 0;
	if((argcnt > 0) && (DT(ARG0) == DT_FILE)){
		f = tofile(ARG0, WRITE);
		if((curcache != NIL) && (f != stand_out))
			save_file(f);
		argindex = 1;
	}
	if(f->fl_access == WRITEBINARY){
		for( ; argindex < argcnt; argindex++){
			write_instance(f, arg[argindex]);
		}
	} else {
		for( ; argindex < argcnt; argindex++){
			a = arg[argindex];
			if(DT(a) == DT_STRING){
			casestr:
				imax = T_STRING(a)->str_size;
				i = f->fl_index;
				if(i + imax < f->fl_bufsize){
					/*
					 * Special treatment of the case that
					 * the string fits in th file buffer.
					 */
					copy(&T_STRING(a)->str_contents[0], &T_STRING(a)->str_contents[imax],
						&f->fl_buffer[i]);
					f->fl_index += imax;
				} else
				        for(i = 0; i < imax; i++)
						fputc(f, T_STRING(a)->str_contents[i]);
			} else
			if(DT(a) == DT_INTEGER){
				T_STRING(a) = inttostr(a);
				goto casestr;
			} else
			if(DT(a) == DT_REAL){
				T_STRING(a) = realtostr(T_REAL(a)->real_val, NDIG);
				goto casestr;
			} else
			error("unimplemented conversion in put");
		}
		if(f == stand_out || f == stand_er)
			flflush(f);
	}
	return(nullstring);
}

SUBR STRING F_Fput(){
	return(_put());
}

put1(s)
STRING s;{
	SUMDP * argsv;
	int cntsv, retsv;

	argsv = arg;
	cntsv = argcnt;
	retsv = retcnt;
	arg = Gevalsp.sp_psumdp;
	PUSHFILE(Gevalsp,stand_out);
	PUSHSTRING(Gevalsp,s);
	argcnt = 2; _put();
	POP(Gevalsp); POP(Gevalsp);
	arg = argsv;
	argcnt = cntsv;
	retcnt = retsv;
	flflush(stand_out);
}

putstring(s)
char *s;{
	while(*s)
		fputc(stand_out, *s++);
	flflush(stand_out);
}

fgetc(af)
FILE af;{
	register int n;
	register FILE f;
	register char c;

	f = af;
	if(f->fl_nleft == 0){
		f->fl_index = 0;
	read_retry:
		if(inter_catched)
			putstring("interrupted, still waiting for input ...\n");
		n = read(f->fl_descr, f->fl_buffer, f->fl_bufsize);
		if(n < 0){
			INTERRUPT(read_retry);
			error("read error");
		}
		if(n == 0)
			return(-1);
		f->fl_nleft = n;
		f->fl_offset += n;
	}
	f->fl_nleft--;
	c = f->fl_buffer[f->fl_index++];
	return(c);
}

fputc(af, c)
FILE af;
int c;{
	register int n;
	register FILE f;
	f = af;
	if(f->fl_index == f->fl_bufsize){
	write_retry:
		n = write(f->fl_descr, f->fl_buffer, f->fl_bufsize);
		if(n < f->fl_bufsize){
			INTERRUPT(write_retry);
			error("write error");
		}
		f->fl_index = 0;
		f->fl_offset += n;
	}
	f->fl_buffer[f->fl_index++] = c;
}





flflush(fp)
FILE fp;{
	if(((fp->fl_lastaccess == WRITE) ||
	    (fp->fl_lastaccess = WRITEBINARY)) &&	/* flush the buffer */
	   (fp->fl_index > 0))
		write(fp->fl_descr, fp->fl_buffer, fp->fl_index);
	fp->fl_index = fp->fl_nleft = 0;
}

union int2char {
	int	intval;
	char	charval[4];
};

put_bin_int(f, n)
FILE f; int n;{
	union int2char u;
	int i;

	u.intval = n;
	for(i = 0; i < 4; i++)
		fputc(f, u.charval[i]);
}

int get_bin_int(f)
FILE f;{
	union int2char u;
	int i, n;
	for(i = 0; i < 4; i++){
		n = fgetc(f);
		if(n == -1 && f->fl_nleft == 0)
			return(-1);
		u.charval[i] = n;
	}
	return(u.intval);
}

SUBR DATATYPE write_instance(f, val)
FILE f; SUMDP val;{
	extern SUMDP _copy();
	extern int copy_all;
        SUMDP p;
	int nbytes, i;
	char *buf;

	if(T_DATATYPE(val) == T_DATATYPE(undefined)){
		nbytes = 0;
		buf = 0;
	} else {
		copy_all = 1;
		T_DATATYPE(p) = CAST(DATATYPE) call(1, _copy, val);
		copy_all = 0;
        	nbytes = (T_DATATYPE(surf) - T_DATATYPE(p)) * SZ_SUMDP;
		buf = CAST(char *) T_DATATYPE(p);
        	surf = p;	/* potentially dangerous */
	}
	put_bin_int(f, nbytes);
	put_bin_int(f, buf);
	for(i = 0; i < nbytes; i++){
		fputc(f, buf[i]);
	}
#ifdef BINDEBUG
	printinst(buf, &buf[nbytes]);
#endif
        return(T_DATATYPE(p));
}

#ifdef BINDEBUG
printstr(p)
SUMDP p;{
	char stopchar; int k; STRING str;
	str = T_STRING(p);
	k = str->str_size;
	stopchar = str->str_contents[k];
	str->str_contents[k] = '\0';
	printf(":%s)\n", str->str_contents); 
	str->str_contents[k] = stopchar;
}

printinst(first, last)
SUMDP *first; SUMDP *last; {
	SUMDP p; SUMDP *pp; SUMDP *b; SUMDP *e;

	pp = first;
	while (pp < last){
		T_DATATYPE(p) = pp;
		limits(p, &b, &e);
		printf("%d: %d\t(%s", p, DT(p),
			class_names[DT(p)]->str_contents);
		if(DT(p) == DT_STRING)
			printstr(p);
		else if (DT(p) == DT_INTEGER)
			printf(":%d)\n", INTVAL(p));
		else {	SUMDP *a = pp;
			printf(")\n");
			for(a = a + 1; a < b; a++)
				printf("\t%d\n", *a);
		}
		while(b < e){
			if(T_DATATYPE(*b) == NIL)
				printf("\tnil\n");
			else {	char c = (b < first || b > last) ? '*' : ' ';

				printf("%c\t%d\t(%s", c, *b,
					class_names[DT(*b)]->str_contents);
				if(DT(*b) == DT_STRING)
					printstr(*b);
				else if (DT(*b) == DT_INTEGER)
					printf(":%d)\n", INTVAL(*b));
				else printf(")\n");
			}
			b++;
		}
		pp = e;
	}
}
#endif

DATATYPE read_instance(f)
FILE f; {
	int i, nbytes, base, offset;
	SUMDP p; SUMDP *b; SUMDP *e;
	DATATYPE inst;
	char *buf;

	nbytes = get_bin_int(f);
	base = get_bin_int(f);
	if(nbytes == -1 || base == -1)
		FAIL;
	if(nbytes == 0)
		return(T_DATATYPE(undefined));
	buf = alloc(nbytes);
	for(i = 0; i < nbytes; i++)
		buf[i] = fgetc(f);
	inst = CAST(DATATYPE) buf;
	T_DATATYPE(p) = inst;
	offset = CAST(int) inst;
	offset -= base;
	while (T_DATATYPE(p) < T_DATATYPE(surf)){
		DT(p) = INTVAL(f->fl_ctrans->ar_elements[DT(p)]);
		limits(p, &b, &e);
		while(b < e){
			if(T_DATATYPE(*b) == T_DATATYPE(f->fl_undef))
				*b = undefined;
			else
			if(T_DATATYPE(*b) == T_DATATYPE(f->fl_nullstring))
				T_STRING(*b) = nullstring;
			else
			if(T_DATATYPE(*b) == NIL)
				/* do not touch nils */;
			else
				T_DATATYPE(*b) += offset/SZ_SUMDP;
			b++;
		}
		T_DATATYPE(p) = e;
	}
#ifdef BINDEBUG
	printinst(buf, &buf[nbytes]);
#endif
	return(inst);
}

save_file(f)
FILE f;{
	struct cache *c, *ctop;
	extern struct cache *save_in_cache();

	ctop = cachetop;
	c = save_in_cache(f, 0);	/* dummy offset */
	if(ctop != cachetop)		/* a new element was added */
		if(f->fl_lastaccess == WRITE)
			T_INTEGER(c->val_old) = newinteger(f->fl_offset + f->fl_index);
		else
			T_INTEGER(c->val_old) = newinteger(f->fl_offset - f->fl_nleft);
}

rest_file(c)
struct cache *c;{
	FILE f;
	int n;
	long oldpos;

	f = T_FILE(c->val_base);
	oldpos = INTVAL(c->val_old);
	if((f->fl_lastaccess == WRITE) &&
	   (f->fl_offset < oldpos) &&
	   (oldpos < f->fl_offset + f->fl_bufsize)){
		/*
		 * We are writing and have not yet written to
		 * the outside world any information that
		 * should now be discarded.
		 * Just reset file information.
		 */
		f->fl_index = oldpos - f->fl_offset;
	} else
	if((f->fl_lastaccess == READ) &&
	   (f->fl_offset - f->fl_nleft < oldpos) &&
	   (oldpos < f->fl_offset)){
		/*
		 * We are reading and the old file position is
		 * still contained in the current file buffer.
		 * Reset file administration.
		 */
		n = f->fl_nleft;
		f->fl_nleft = f->fl_offset - oldpos;
		f->fl_index = f->fl_index + n - f->fl_nleft;
	} else {
		/*
		 * The general case: the old file position lies
		 * outside the current file buffer. Seek to old
		 * position.
		 */
	seek_retry:
		if(lseek(f->fl_descr, oldpos, 0) < 0){
			INTERRUPT(seek_retry);
			error("seek failed during file recovery");
		}
		f->fl_index = f->fl_nleft = 0;
		f->fl_offset = oldpos;
	}
}


/*
 * Check that "f" is file with accesstype "access".
 */

FILE tofile(f, access)
SUMDP f;				/* not used after proc call */
int access;{
	int ac;
	if(DT(f) != DT_FILE)
		error("file expected");
	ac = T_FILE(f)->fl_lastaccess;
	if(!(((access == READ) && (ac == READ || ac == READBINARY)) ||
	    ((access == WRITE) && (ac == WRITE || ac == WRITEBINARY))))
		error("illegal file access");
	return(T_FILE(f));
}

struct subr Fclose, Fget, Fput;

file_init(){
	extern struct fld f_close, f_get, f_put;

	DCLSUBR(Fclose,F_Fclose,&f_close,cvt_string);
	DCLSUBR(Fget,F_Fget,&f_get,cvt_string);
	DCLSUBR(Fput,F_Fput,&f_put,cvt_string);
}
