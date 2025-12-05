#
/*
 * SUMMER -- integer
 * Copyright, 1979, Paul Klint, Mathematisch Centrum, Holland.
 */

#include	"summer.h"

/*
 * Class creation procedure.
 */
SUBR INTEGER _integer(){
	register int i, sum, sign;
	int ch;

	ARGCNT(2);
	if(DT(ARG1) == DT_INTEGER)	/* nothing to do */
		return(T_INTEGER(ARG1));
	if(DT(ARG1) == DT_REAL){
		double x = T_REAL(ARG1)->real_val;
		if (x > 0)
			x += 0.5;
		else
			x -= 0.5;
		i = x;
		return(newinteger(i));
	}
	ARGTYPE(1,DT_STRING);

	sum = 0;
	sign = 1;
	for(i = 0; i < T_STRING(ARG1)->str_size; i++){
		ch = T_STRING(ARG1)->str_contents[i];
		if(!isdigit(ch)){
			if(i == 0)
				if(ch == '+')
					continue;
				else
				if(ch == '-'){
					sign = -1;
					continue;
				}
			FAIL;
		}
		sum = sum * 10 + (ch - '0');
	}
	if(sum < 0){
		error("integer overflow in number conversion");
		return(ZERO);
	}
	return(newinteger(sign * sum));
}

/*
 * Convert integer to string.
 */
STRING inttostr(n)
SUMDP n;{
	register int val;
	int i, k, sign;
	char buf[20];
	register char *s;

	if(DT(n) != DT_INTEGER)
		error("non-numeric operand in number conversion");
	val = INTVAL(n);
	if(val < 0){
		sign = -1;
		val = -val;
	} else
		sign = 1;
	s = buf;
	do {
		*s++ = val % 10 + '0';
	} while((val /= 10) > 0);

	if(sign < 0)
		*s++ = '-';
	k = s - buf;
	Snumtostr->str_size = k;
	for(i = 0; i < k; i++)
		Snumtostr->str_contents[i] = *--s;
	return(Snumtostr);
}


isdigit(c)
char c;{
	return(('0' <= c) && (c <= '9'));
}

