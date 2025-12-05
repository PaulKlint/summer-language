#
/*
 * SUMMER -- real
 */

#include "summer.h"

/*
 * Class creation procedure.
 */

SUBR REAL _real(){
	int dt;
	double x;

	ARGCNT(2);
	dt = DT(ARG1);
	if(dt == DT_INTEGER){
		x = INTVAL(ARG1);
		return(newreal(x));
	} else
	if(dt == DT_STRING)
		return(strtoreal(T_STRING(ARG1)));
	if(dt == DT_REAL)
		return(T_REAL(ARG1));
	else
		error("real -- illegal argument");
}

/*
 * Convert a string to real.
 * The number syntax is:
 *	[plus|minus][digit*][. digit*][e[plus|minus]digit+]
 */

REAL strtoreal(s)
STRING s;{
	double m, scale, result;
	int sign, expsign, e, k, ncnt;
	char *cp, *ep, *cpstart;

	cp = s->str_contents;
	ep = &s->str_contents[s->str_size];
	m = 0.0;
	e = 0;
	ncnt = 0;
	/*
	 * Skip leading spaces and remember first non-space.
	 */
	while((cp < ep) && (*cp == ' '))
		cp++;
	cpstart = cp;
	sign = 1;
	/*
	 * [plus|minus]
	 */
	if(*cp == '-'){
		sign = -1;
		cp++;
	} else
	if(*cp == '+')
		cp++;
	/*
	 * [digit*]
	 */
	while((cp < ep) && isdigit(*cp)){
		m = m * 10.0 + (*cp - '0');
		cp++;
	}
	/*
	 * [. digit*]
	 */
	if((cp < ep) && (*cp == '.')){
		cp++;
		while((cp < ep) && isdigit(*cp)){
			m = m * 10.0 + (*cp - '0');
			ncnt++;
			cp++;
		}
	}
	/*
	 * [e[plus|minus]digit+]
	 */
	if((cp < ep - 1) && (*cp == 'e')){
		/*
		 * Special case: the number starts with 'e'.
		 */
		if(cp == cpstart)
			m = 1.0;
		expsign = 1;
		cp++;
		if(*cp == '-'){
			expsign = -1;
			cp++;
		} else
		if(*cp == '+')
			cp++;
		while((cp < ep) && isdigit(*cp)){
			e = e * 10 + (*cp - '0');
			cp++;
		}
		if(expsign < 0)
			e = -e;
	}
	/*
	 * Skip trailing space.
	 */
	while((cp < ep) && (*cp == ' '))
		cp++;
	if(cp != ep)
		FAIL;
	ncnt -= e;
	k = abs(ncnt);
	if(k > 38)
		FAIL;
	scale = 1.0;
	if(k != 0){
		do
			scale *= 10.0;
		while(--k);
	}
	result = (ncnt > 0) ? m/scale : m * scale;
	return(newreal(sign > 0 ? result : -result));
}

/*
 * Convert a floating point number to an ascii string.
 * x is stored in the fixed string Snumtostr and should be
 * copied on assignment (or return value) to any SUMMER variable.
 */
STRING realtostr(x, ndig)
double x;{
	int ie, i, k, fstyle;
	double y;
	char *str;

	ie = 0;
	str = Snumtostr->str_contents;
	/*
	 * If x negative, write minus and reverse
	 */
	if(x < 0) {
		*str++ = '-';
		x = -x;
	}
	/*
	 * Now determine output style.
	 */
	if((x > 0.0001) && (x < 100000.0))
		fstyle = 1;
	else
		fstyle = 0;
	/*
	 * Put x in range 1 <= x < 10
	 */
	if(x > 0.0)
		while(x < 1.0) {
			x *= 10.0;
			ie--;
		}
	while(x >= 10.0) {
		x /= 10.0;
		ie++;
	}

	/*
	 * in f format, number of digits is related to size
	 */
	if(fstyle)
		ndig += ie;
	/*
	 * round. x is between 1 and 10 and ndig will be printed to
	 * right of decimal point so rounding is ...
	 */
	for(y=i=1; i<ndig; i++)
		y /= 10.0;
	x += y/2.0;
	if(x >= 10.0) {
		x = 1.0;
		ie++;
	}
	/*
	 * now loop. put out a digit (obtained by multiplying by
	 * 10, truncating, subtracting) until enough digits out
	 * if fstyle, and leading zeros, they go out special
	 */
	if(fstyle && ie<0) {
		*str++ = '0';
		*str++ = '.';
		if(ndig < 0)
			ie -= ndig;	/* limit zeros if underflow */
		for(i = -1; i>ie; i--)
			*str++ = '0';
	}
	for(i=0; i<ndig; i++) {
		k = x;
		*str++ = k+'0';
		if(i == (fstyle?ie:0))	/* where is decimal point? */
			*str++ = '.';
		x -= (y=k);
		x *= 10.0;
	}
	/*
	 * Remove trailing zeros.
	 */
	while((str[-1] == '0') && (str[-2] != '.'))
		str--;
	/*
	 * now, in estyle, put out exponent if not zero
	 */
	if(!fstyle && ie!=0) {
		*str++ = 'e';
		if(ie < 0) {
			ie = -ie;
			*str++ = '-';
		}
		for(k=100; k>ie; k /= 10) ;
		for(; k>0; k /= 10) {
			*str++ = ie/k + '0';
			ie %= k;
		}
	}
	Snumtostr->str_size = str - Snumtostr->str_contents;
	return(Snumtostr);
}

