#
/*
 * SUMMER -- string datatype
 *
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include	"summer.h"

/*
 * string: class creation procedure.
 */

SUBR STRING _string() {
	register int dt;

	ARGCNT(2);
	dt = DT(ARG1);
	if(dt == DT_STRING)		/* nothing to do */
		return(T_STRING(ARG1));
	else
	if(dt == DT_INTEGER)
		T_STRING(ARG1) = inttostr(ARG1);
	else
	if(dt == DT_REAL)
		T_STRING(ARG1) = realtostr(T_REAL(ARG1)->real_val, NDIG);
	else
		error("string called with %t argument", ARG1);
	return(substr(&ARG1, 0, T_STRING(ARG1)->str_size));
}

STRING substr(s, from, to)
SUMDP *s;
int from, to;{
	register STRING p;
	register int size;
#ifdef CGSTATS
	extern int substrcnt;
	extern float substrnbytes;
#endif

	if(DT(*s) != DT_STRING)
		error("substr called with non-string argument");
	size = to - from;
	p = newstring(size);
	copy(&T_STRING(*s)->str_contents[from], &T_STRING(*s)->str_contents[from+size],
		p->str_contents);
#ifdef CGSTATS
	substrcnt++;
	substrnbytes =+ (SZ_STR + size * SZ_CHAR);
#endif
	return(p);
}
/*
 * pad: generalized string padding routine.
 *      used by left, right, center and repl.
 */
STRING pad(asource, apadstring, size, base)
STRING *asource; STRING *apadstring;
int base, size;{
	int n, m, padsize;
	STRING result;
	STRING source;
	STRING padstring;


	if((size == (*asource)->str_size) && (base == 0))
		return(*asource);
	result = newstring(size);
	source = *asource;
	padstring = *apadstring;
	padsize = padstring->str_size;
	if(padsize == 0)
		error("empty padstring");

	n = m = 0;
	/*
	 * fase1: repeat the padstring starting at the left of
	 * the result string.
	 */
	while (n < base){
		if(m == padsize)
			m = 0;
		result->str_contents[n++] = padstring->str_contents[m++];
	}
	/*
	 * fase2: move the source string to the result string.
	 */
	m = (base < 0) ? -base : 0;
	while((n < size) && (m < source->str_size))
		result->str_contents[n++] = source->str_contents[m++];
	/*
	 * fase3: repeat the padstring at the right end
	 * of the source.
	 * The padstring index m is initialized in such a way that
	 * the repetitions of the padstring are aligned with the
	 * right end of result.
	 */
	m = padsize - ((size - n) % padsize);
	while(n < size){
		if(m == padsize)
			m = 0;
		result->str_contents[n++] = padstring->str_contents[m++];
	}
	return(result);
}

SUBR STRING F_Srpl(){
	register int n;

	ARGCNT(2);
	ARGTYPE(0,DT_STRING);
	ARGTYPE(1,DT_INTEGER);
	n = INTVAL(ARG1);
	if(n < 0)
		error("repl called with negative count");
	return(pad(&nullstring, &T_STRING(ARG0), n * T_STRING(ARG0)->str_size, 0));
}

SUBR STRING F_Sleft(){
	register int n;

	ARGCNT(3);
	ARGTYPE(0,DT_STRING);
	ARGTYPE(1,DT_INTEGER);
	ARGTYPE(2,DT_STRING);

	n = INTVAL(ARG1);
	if(n < 0)
		error("left called with negative size");
	return(pad(&T_STRING(ARG0), &T_STRING(ARG2), n, 0));
}

SUBR STRING F_Sright(){
        register int n;

        ARGCNT(3);
        ARGTYPE(0,DT_STRING);
        ARGTYPE(1,DT_INTEGER);
        ARGTYPE(2,DT_STRING);

        n = INTVAL(ARG1);
        if(n < 0)
                error("right called with negative size");
        return(pad(&T_STRING(ARG0), &T_STRING(ARG2), n, n - T_STRING(ARG0)->str_size));
}
SUBR STRING F_Scenter(){
        register int n;

        ARGCNT(3);
        ARGTYPE(0,DT_STRING);
        ARGTYPE(1,DT_INTEGER);
        ARGTYPE(2,DT_STRING);

        n = INTVAL(ARG1);
        if(n < 0)
                error("center called with negative size");
        return(pad(&T_STRING(ARG0), &T_STRING(ARG2), n, (n - T_STRING(ARG0)->str_size)/2));
}
/*
 * Reverse a string.
 */

SUBR STRING F_Sreverse(){
	int i, size;
	STRING result;

	ARGCNT(1);
	ARGTYPE(0,DT_STRING);
	size = T_STRING(ARG0)->str_size;
	result = newstring(size);
	for(i = 0; i < size; i++)
		result->str_contents[i] = T_STRING(ARG0)->str_contents[size - 1 - i];
	return(result);
}

/*
 * Replace in s1 all occurrences of characters in s2 by the corresponding
 * character in s3. If s3 is too short, delete the character.
 */

SUBR STRING F_Sreplace(){
	int i, j, n;
	STRING result;
	STRING s1;
	STRING s2;
	STRING s3;

	ARGCNT(3);
	ARGTYPE(0,DT_STRING);
	ARGTYPE(1,DT_STRING);
	ARGTYPE(2,DT_STRING);
	result = newstring(T_STRING(ARG0)->str_size);
	n = 0;
	s1 = T_STRING(ARG0); s2 = T_STRING(ARG1); s3 = T_STRING(ARG2);
	for(i = 0; i < s1->str_size; i++){
		for(j = s2->str_size - 1; j >= 0; j--){
			if(s1->str_contents[i] == s2->str_contents[j]){
				if(j < s3->str_size)
					result->str_contents[n++] = s3->str_contents[j];
				goto nextchar;
			}
		}
		result->str_contents[n++] = s1->str_contents[i];
	nextchar:;
	}
	if(n < s1->str_size){
		PUSHSTRING(Gevalsp,result);
		result = substr(&Gevalsp.sp_psumdp[-1], 0, n);
		POP(Gevalsp);
	}
	return(result);
}
/*
 * Substr(s, offset, length)
 */

SUBR STRING F_Ssubstr(){
	register int offset, length, to;
	register STRING s;

	ARGCNT(3);
	ARGTYPE(0,DT_STRING);
	ARGTYPE(1,DT_INTEGER);
	ARGTYPE(2,DT_INTEGER);
	s = T_STRING(ARG0);
	offset = INTVAL(ARG1);
	length = INTVAL(ARG2);
	if((offset < 0) || (offset >= s->str_size))
		error("substr offset (%v) out of range", ARG1);
	if(length < 0)
		error("substr negative length (%v)", ARG2);
	to = min(offset + length, s->str_size);
	s = substr(&ARG0, offset, to);
	return(s);
}
SUBR INTEGER F_Ssize(){
	ARGCNT(1);
	ARGTYPE(0,DT_STRING);
	return(newinteger(T_STRING(ARG0)->str_size));
}
SUBR ARRAY F_Snext(){
	int n;
	ARGTYPE(0,DT_STRING);
	if(DT(ARG1) == DT_UNDEFINED)
		n = 0;
	else {
		ARGTYPE(1,DT_INTEGER);
		n = INTVAL(ARG1);
	}
	if(n < T_STRING(ARG0)->str_size){
		T_STRING(ARG0) = substr(&ARG0, n, n + 1);
		ar2->ar_elements[0] = ARG0;
		T_INTEGER(ar2->ar_elements[1]) = newinteger(n + 1);
		return(ar2);
	} else
		FAIL;
}

SUBR ARRAY F_Sindex(){
	register int n;
	extern CLASS _interval();

	ARGCNT(1);
	ARGTYPE(0,DT_STRING);
	n = T_STRING(ARG0)->str_size - 1;
	T_INTEGER(ARG0) = newinteger(n);	/* use ARG0 as save loc */
	return(CAST(ARRAY) call(4, _interval, undefined, ZERO, ARG0, ONE));
}
SUBR STRING F_Sretrieve(){
	register int n;
	register STRING s;

	ARGCNT(2);
	ARGTYPE(0,DT_STRING);
	ARGTYPE(1,DT_INTEGER);
	s = T_STRING(ARG0);
	n = INTVAL(ARG1);
	if((n < 0) || (n >= s->str_size))
		error("%v exceeds size of <string> %v", ARG1, ARG0);
	return(substr(&ARG0, n, n + 1));
}
struct subr Scenter, Sindex, Sleft, Snext, Srepl, Sreplace, Sretrieve,
	    Sreverse, Sright, Ssize, Ssubstr;

string_init(){
	extern struct fld f_center, f_index, f_left, f_next,
			  f_repl, f_replace, f_retrieve, f_reverse,
			  f_right, f_size, f_substr;
	DCLSUBR(Scenter,F_Scenter,&f_center,cvt_string);
	DCLSUBR(Sindex,F_Sindex,&f_index,cvt_array);
	DCLSUBR(Sleft,F_Sleft,&f_left,cvt_string);
	DCLSUBR(Snext,F_Snext,&f_next,cvt_array);
	DCLSUBR(Srepl,F_Srpl,&f_repl,cvt_string);
	DCLSUBR(Sreplace,F_Sreplace,&f_replace,cvt_string);
	DCLSUBR(Sretrieve,F_Sretrieve,&f_retrieve,cvt_string);
	DCLSUBR(Sreverse,F_Sreverse,&f_reverse,cvt_string);
	DCLSUBR(Sright,F_Sright,&f_right,cvt_string);
	DCLSUBR(Ssize,F_Ssize,&f_size,cvt_integer);
	DCLSUBR(Ssubstr,F_Ssubstr,&f_substr,cvt_string);
}
