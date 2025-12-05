#
/*
 * SUMMER -- file
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

SUBR FILE _file(){
	char name[51];
	int i, type, fd;

	ARGCNT(3);
	ARGTYPE(1,DT_STRING);
	ARGTYPE(2,DT_STRING);
	if(curcache != NIL)
		/* This case requires a less crude approach */
		error("file creation not allowed with active cache");
	for(i = 0; (i < T_STRING(ARG1)->str_size) && (i < 50); i++)
		name[i] = T_STRING(ARG1)->str_contents[i];
	name[i] = '\0';
	fd = -1;
	if(streq(T_STRING(ARG1), Sstand_in))
		fd = 0;
	else
	if(streq(T_STRING(ARG1), Sstand_out))
		fd = 1;
	else
	if(streq(T_STRING(ARG1), Sstand_er))
		fd = 2;

	if(streq(T_STRING(ARG2), Sr)){
		type = READACCESS;
		if((fd == 1) || (fd == 2))
			goto badtype;
		if(fd == 0)
			return(stand_in);
		else {
		open_r1:
			if((fd = open(name, 0)) < 0)
				INTERRUPT(open_r1);
		}
	} else
	if(streq(T_STRING(ARG2), Sw)){
		type = WRITEACCESS;
		if(fd == 0)
			goto badtype;
		if(fd == 1)
			return(stand_out);
		else
		if(fd == 2)
			return(stand_er);
		else {
		creat_retry:
			if((fd = creat(name, 0666)) < 0)
				INTERRUPT(creat_retry);
		}
	} else
	if(streq(T_STRING(ARG2), Srw)){
		type = READWRITEACCESS;
		if(fd >= 0)
			goto badtype;
	open_r2:
		if((fd = open(name, 2)) < 0)
			INTERRUPT(open_r2);
	} else {
	badtype:
		error("Illegal access type");
	}
	if(fd < 0)
		FAIL;
	return(newfile(fd, type, 512));
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


SUBR STRING _get(){
	register int c, k;
	register FILE f;
	STRING r;
	char buf[MAXLINE];
	extern FILE tofile();

	f = stand_in;
	if(argcnt == 1){
		f = tofile(ARG0, READACCESS);
		if((curcache != NIL) && (f != stand_in))
			save_file(f);
	}
	k = 0;

	while(1) {
		c = fgetc(f);
		if((c == '\n') || (c == -1)){
			if((c == -1) && (k == 0))
				FAIL;
			r = newstring(k);
			copy(buf, &buf[k], r->str_contents);
			return(r);
		} else {
			buf[k++] = c;
                        if(k == MAXLINE)
				error("too long input line");
                }
	}
}


SUBR STRING F_Fget(){
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

	f = stand_out;
	argindex = 0;
	if((argcnt > 0) && (DT(ARG0) == DT_FILE)){
		f = tofile(ARG0, WRITEACCESS);
		if((curcache != NIL) && (f != stand_out))
			save_file(f);
		argindex = 1;
	}
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
	if(f == stand_out)
		flflush(stand_out);
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
	return(f->fl_buffer[f->fl_index++]);
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
	if((fp->fl_lastaccess == WRITEACCESS) &&	/* flush the buffer */
	   (fp->fl_index > 0))
		write(fp->fl_descr, fp->fl_buffer, fp->fl_index);
	fp->fl_index = fp->fl_nleft = 0;
}


save_file(f)
FILE f;{
	struct cache *c, *ctop;
	extern struct cache *save_in_cache();

	ctop = cachetop;
	c = save_in_cache(f, 0);	/* dummy offset */
	if(ctop != cachetop)		/* a new element was added */
		if(f->fl_lastaccess == WRITEACCESS)
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
	if((f->fl_lastaccess == WRITEACCESS) &&
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
	if((f->fl_lastaccess == READACCESS) &&
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
	if(DT(f) != DT_FILE)
		error("file expected");
	if(T_FILE(f)->fl_lastaccess != access)
		if(T_FILE(f)->fl_access == READWRITEACCESS){
			flflush(f);
			T_FILE(f)->fl_lastaccess = access;
		} else
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
