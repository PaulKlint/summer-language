#{figs+>;}
.NC #{SUMMER LIBRARY=sn+} "THE SUMMER LIBRARY" " "
.ds LH "THE SUMMER LIBRARY
.SH #{sn>1}. Introduction
.PP
This chapter describes the \s-2SUMMER\s0 library of standard classes.
The library is made available to each \s-2SUMMER\s0 program automatically, i.e.
the standard classes can be used
without any definitions or declarations being required on the part
of the programmer.
.PP
The types of formal parameters and return values of procedures and operators
are indicated explicitly, in a \s-2PASCAL\s0-like style.$"" sup 1$
.FS
1) This notation is
used in this chapter only, and is not available in \s-2SUMMER\s0 itself.
.FE
For example,
.DS
.{{
proc move(n : integer) : string
.}}
.DE
denotes a procedure with \*{integer\*} parameter \*{n\*} and
a return value of type \*{string\*}.
If more than one type is allowed, the names of the
legal types are joined with the infix -\*{or\*}- as exemplified
by \fIinteger-or-real-or-string\fP.
A value of arbitrary type is denoted by \*{arbtype\*}.
.PP
If during the execution of a program, some procedure or operator
described in this chapter is called with actual parameter values of a type
that is not equal to one of the specified types, then
an error is signalled.
In the sequel the phrase `an error is signalled' will be understood to mean that
a semantic error is detected, that the execution of the program is terminated
and that the user is notified of this fact by an appropriate error message.
.PP
The reader should be aware that this chapter contains
an informal definition of the standard classes;
this implies that no formal definitions in metalanguage will be given.
.PP
Each of the following paragraphs describes a separate class definition.
.SH #{Lib/integer=sn+}. "Class integer"
.iy I integer
.PP
Class \*{integer\*} defines integer values and their associated operations.
The global organization of this class is:
.DS
\*{class integer(arg :\*} \fIinteger-or-real-or-string\fR)
.{{
begin fetch +, -, *, /, %, <, <=, =, ~=, =>, >;

      var intval;

      op + (n) ( ... );
      ...
      op > (n) ( ... );

init: intval := convert_to_integer(arg);

end integer;
.}}
.DE
When an instance of class \*{integer\*} is created,
the actual value of \*{arg\*} may be one of several types.
The following conversion rules apply:
.IP Integer: 10
No conversion is required.
.IP Real: 10
The real value \*{arg\*} is rounded to an integer, i.e.
to the value $sign(arg)~\(mu~entier(abs(arg)~+~0.5)$.
.IP String: 10
If the string \*{arg\*} has the form
.DS
.{{
['+' | '-'] <integer-constant>
.}}
.DE
.iy I <integer-constant>
then it can be converted to an integer.
The creation of this instance of
class \*{integer\*} fails if \*{arg\*} does not have this form.
.LP
From now on we assume that the result of the above conversion
has been assigned to the instance variable \*{intval\*}.
.PP
As described in Section #{Constants}, a special denotation (i.e. \*<integer-constant\*>s)
exists for instances of class \*{integer\*}.
For example,
.{{
integer('37')
.}}
may be also be written as `$37$'.
.PP
The operations on integers are now described in more detail.
.OB #{sn>1} "\*{+\*}" " (n : integer-or-real) : integer-or-real" "Integer addition:" 
.OM #{sn+} "\(mi" " (n : integer-or-real) : integer-or-real" "Integer subtraction:"
.OM #{sn+} "\*{*\*}" " (n : integer-or-real) : integer-or-real" "Integer multiplication:"
.OE #{sn+} "\*{/\*}" " (n : integer-or-real) : real" "Division:"
Performs the arithmetic operation $intval~\*(o1~n$, where $\*(o1$
is one of the above arithmetic operators.
If the type of \*{n\*} is \*{integer\*}, the (integer) value obtained by
the arithmetic operation is returned.
If the type of \*{n\*} is \*{real\*},
the value of $real(intval)~\*(o1~n$ is returned as a (real) value.
For division (`\*{/\*}'), \*{n\*} is always converted to real.
.EX #{sn}
\*{2 + 3\*}	{value: \*{5\*}}
.br
\*{2 + 3.5\*}	{value: \*{5.5\*}}
.br
\*{2 - 3.5\*}	{value: \*{-1.5\*}}
.br
\*{integer(2.8) + 2\*}	{value: \*{5\*}}
.br
\*{8 / 5\*}	{value: \*{1.6\*}}
.NX #{sn}
.OP #{sn+} "\*{%\*}" " (n : integer) : integer" ""
The (integer) value obtained by integer division of \*{intval\*} by \*{n\*}
is returned as value.
The result is positive if the values of \*{intval\*} and \*{n\*} are
either both positive or both negative; the result is negative otherwise.
.EX #{sn}
\*{7 % 2\*}	{value: \*{3\*}}
.br
\*{-7 % 2\*}	{value: \*{-3\*}}
.br
\*{7 % -2\*}	{value: \*{-3\*}}
.br
\*{-7 % -2\*}	{value: \*{3\*}}
.NX #{sn}
.OB #{sn+} "\*{<\*}" " (n : integer-or-real) : integer-or-real" "Integer less-than:"
.OM #{sn+} "\*{<=\*}" " (n : integer-or-real) : integer-or-real" "Integer less-than-or-equal:"
.OM #{sn+} "\*{=\*}" " (n : integer-or-real) : integer-or-real" "Integer equal:"
.OM #{sn+} "\*{~=\*}" " (n : integer-or-real) : integer-or-real" "Integer not-equal:"
.OM #{sn+} "\*{>=\*}" " (n : integer-or-real) : integer-or-real" "Integer greater-than-or-equal:"
.OE #{sn+} "\*{>\*}" " (n : integer-or-real) : integer-or-real" "Integer greater-than:"
Performs the arithmetic comparison $intval~\*(o2~n$, where $\*(o2$ is
one of the above operators.
If the type of \*{n\*} is \*{real\*}, the comparison
$real(intval)~\*(o2~n$ is performed.
If the comparison succeeds,
the (unconverted) value of \*{n\*} is returned as the value of the operation.
Otherwise the operation fails.
The correspondence between these operators and their mathematical counterparts
is as follows:
.DS L
.ta 2c 6c
	Operation	Corresponds to
.sp 0.5
	\*{m < n\*}	$m~<~n$
	\*{m <= n\*}	$m~<=~n$
	\*{m = n\*}	$m~=~n$
	\*{m ~= n\*}	$m~\(!=~n$
	\*{m >= n\*}	$m~>=~n$
	\*{m > n\*}	$m~>~n$
.DE
.EX #{sn}
\*{2 < 3\*}	{value: \*{3\*}}
.br
\*{3 < 2\*}	{fails}
.br
\*{3 < 4.5\*}	{value: \*{4.5\*}}
.br
\*{3 < 1 < 5\*}	{fails}
.br
\*{3 < 4 < 5\*}	{value: \*{5\*}}
.NX #{sn}
.SH #{Lib/real=sn<+}. "Class real"
.iy I real
.PP
Class \*{real\*} defines floating point numbers and their associated
operations. The global organization of this class is:
.DS
\*{class real(arg :\*} \fIinteger-or-real-or-string\fR)
.{{
begin fetch +, -, *, /, <, <=, =, ~=, >, >=;

      var realval;

      op + (r) ( ... );
      ...
      op >= (r) ( ... );

init: realval := convert_to_real(arg);

end real;
.}}
.DE
When an instance
of \*{real\*} is created, the actual value of \*{arg\*} may be one of several types.
The following conversion rules apply to values of these types:
.IP Integer: 10
The integer value \*{arg\*} is converted to the corresponding real number.
.IP Real: 10
No conversion is required.
.IP String: 10
If the string \*{arg\*} has the form of a
\*<real-constant\*>,
.iy I <real-constant> ,
then it can be converted
to a real value.
Otherwise, the creation of this instance of class \*{real\*} fails.
.LP
From now on we assume that the result of the above conversion has been
assigned to the instance variable \*{realval\*}.
.PP
As described in Section #{Constants}, a special denotation
(i.e. \*<real-constant\*>s) exists for instances of class \*{real\*}.
.PP
The operations on reals are now described in more detail.
.OB #{sn>1} "\*{+\*}" " (r : real-or-integer) : real" "Real addition:"
.OM #{sn+} "\(mi" " (r : real-or-integer) : real" "Real subtraction:"
.OM #{sn+} "\*{*\*}" " (r : real-or-integer) : real" "Real multiplication:"
.OE #{sn+} "\*{/\*}" " (r : real-or-integer) : real" "Real division:"
Performs the operation $real~\*(o1~r$, where $\*(o1$ is one
of the above arithmetic operators.
If the type of \*{r\*} is \*{integer\*} then \*{r\*} is first converted to \*{real\*}
before the operation is performed.
.EX #{sn}
\*{2.0 + 3.0\*}	{value: \*{5.0\*}}
.br
\*{2.5 + 3\*}	{value: \*{5.5\*}}
.NX #{sn}
.OB #{sn+} "\*{<\*}" " (r : real-or-integer) : real-or-integer" "(Real less-than)"
.OM #{sn+} "\*{<=\*}" " (r : real-or-integer) : real-or-integer" "(Real less-than-or-equal)"
.OM #{sn+} "\*{=\*}" " (r : real-or-integer) : real-or-integer" "(Real equal)"
.OM #{sn+} "\*{~=\*}" " (r : real-or-integer) : real-or-integer" "(Real not-equal)"
.OM #{sn+} "\*{>\*}" " (r :real-or-integer) : real-or-integer" "(Real greater-than)"
.OE #{sn+} "\*{>=\*}" " (r : real-or-integer) : real-or-integer" "(Real greater-than-or-equal)"
Performs the arithmetic comparison $realval~\*(o2~r$,
where $\*(o2$ is one of the above operators.
If the type of \*{r\*} is \*{integer\*}, \*{r\*} is first converted to real
before the comparison is performed.
If the comparison succeeds, the operation returns
the (unconverted) value of \*{r\*} as result.
Otherwise, the operation fails.
The correspondence between these operators and their mathematical counterparts
is as follows:
.DS L
.ta 2c 6c
	Operation	Corresponds to
.sp 0.5
	\*{p < q\*}	$p~<~q$
	\*{p <= q\*}	$p~<=~q$
	\*{p = q\*}	$p~=~q$
	\*{p ~= q\*}	$p~\(!=~q$
	\*{p >= q\*}	$p~>=~q$
	\*{p > q\*}	$p~>~q$
.DE
{This correspondence is only approximate, since it depends on the precision
of the floating point representation used to implement \*{real\*}s.}
.EX #{sn}
\*{2.0 < 3.0\*}	{value: \*{3.0\*}}
.br
\*{2.5 < 2.0\*}	{fails}
.br
\*{2.5 < 3\*}	{value: \*{3\*}}
.NX #{sn}
.SH #{Lib/string=sn<+}. "Class string"
.iy I string
.PP
Class \*{string\*} provides character strings and their associated operations.
The global organization of this class is:
.DS
\*{class string(arg :\*} \fIinteger-or-real-or-string\fP)
.{{
begin fetch center, index, left, next, repl, replace,
            retrieve, reverse, right, size, substr, 
            <, <=, =, ~=, >=, >, || ;

      var stringval;

      proc center(n, s) ( ... );
      ...
      op || (s) ( ... );

init: stringval := convert_to_array_of_char(arg);

end string;
.}}
.DE
.PP
When an instance of class \*{string\*} is created, the actual value of \*{arg\*}
may be one of several types.
The following conversion rules apply:
.IP Integer: 10
The result of converting the integer value of \*{arg\*} to a string is assigned
to \*{stringval\*}.
The conversion is performed in such a way that the equality $arg~=~integer(stringval)$ holds.
.IP Real: 10
The result of converting the real value of \*{arg\*} to a string is assigned
to \*{stringval\*}.
The conversion is performed in such a way that the equality $arg~=~real(stringval)$ holds.
.IP String: 10
No conversion is required.
.PP
As described in Section #{Constants}, a special denotation (i.e.
\*<string-constant\*>s)
.iy I <string-constant> s)
exists for instances of class \*{string\*}.
.PP
Although \*{character\*} is not an available data type in \s-2SUMMER\s0, we will,
for reasons of convenience, consider strings to be equivalent to
\fBarrays of characters\fP.
Characters are defined to be equivalent to strings of length one.
In this context, a phrase like `some character in string \*{S\*}' means `some
substring of \*{S\*} of length one'.
The string \*{'abc'\*}, for example, is equivalent to an array of
length three, consisting of the characters `\*{a\*}', `\*{b\*}' and `\*{c\*}'.
.PP
The operations on strings are now described in detail.
.PC #{sn>1} "center" "(n : integer, s : string) : string"
Returns a new instance of class \*{string\*} obtained by centering
\*{stringval\*} in a string of length \*{n\*}.
The remainder of that string is filled with replications of \*{s\*}, starting at
both the left and right ends.
Coming from the left end, \*{s\*} is truncated on the right, if necessary.
Coming from the right end, \*{s\*} is truncated on the left, if necessary.
If \*{stringval\*} cannot be centered exactly, it is placed one position
left of the center.
\*{n\*} should be non-negative.
.EX #{sn}
\&\*{''.center(0, '.')\*}	{value: \*{''\*}}
.br
\&\*{''.center(5, '.')\*}	{value: \*{'.....'\*}}
.br
\&\*{'a'.center(0, '.')\*}	{value: \*{''\*}}
.br
\&\*{'a'.center(1, '.')\*}	{value: \*{'a'\*}}
.br
\&\*{'a'.center(5, '.')\*}	{value: \*{'..a..'\*}}
.br
\&\*{'a'.center(4, '.')\*}	{value: \*{'.a..'\*}}
.br
\&\*{'a'.center(6, '. ')\*}	{value: \*{'. a . '\*}}
.br
\&\*{'#'.center(5, 'abcd')\*}	{value: \*{'ab#cd'\*}}
.br
\&\*{'ab'.center(5, '.')\*}	{value: \*{'.ab..'\*}}
.br
.NX #{sn}
.PC #{sn+} "index" " () : interval"
Delivers the set of all legal indices in this string, i.e.
.iy I interval
.{{
interval(0, self.size-1, 1)
.}}
{#{Lib/interval}}.
.EX
.{{
for k in 'grass'.index do put(k, '\n') od
.}}
.sp 0.5
{Prints the integers 0, 1, 2, 3 and 4.}
.NX #{sn}
.PC #{sn+} "left" "(n : integer, s : string) : string"
Returns a new instance of class \*{string\*} obtained by positioning
\*{stringval\*} at the left of a string of length \*{n\*}.
The remainder of that string is filled with replications of \*{s\*},
starting at the right.
The last replication of \*{s\*} is truncated on the left, if necessary. \*{stringval\*}
is truncated on the right if its size is greater than \*{n\*}.
\*{n\*} should be non-negative.
.EX #{sn}
\&\*{''.left(0, '.')\*}	{value: \*{''\*}}
.br
\&\*{''.left(5, '.')\*}	{value: \*{'.....'\*}}
.br
\&\*{'a'.left(0, '.')\*}	{value: \*{''\*}}
.br
\&\*{'a'.left(1, '.')\*}	{value: \*{'a'\*}}
.br
\&\*{'a'.left(5, '.')\*}	{value: \*{'a....'\*}}
.br
\&\*{'a'.left(5, '. ')\*}	{value: \*{'a. . '\*}}
.br
\&\*{'#'.left(3, 'abc')\*}	{value: \*{'#bc'\*}}
.br
\&\*{'ab'.left(5, '.')\*}	{value: \*{'ab...'\*}}
.br
\&\*{'ab'.left(5, '. ')\*}	{value: \*{'ab . '\*}}
.br
.NX #{sn}
.PC #{sn+} "next" "(state : undefined-or-integer) : array"
This procedure produces the consecutive characters of \*{stringval\*} as
strings of size one.
This procedure is most often used in
\*<for-expression\*>s
.iy I <for-expression> s
{#{For expressions}}
that iterate over all characters in a string.
Calls to this procedure are generated automatically in \*<for-expression\*>s, and
usually one need not be aware of the existence of this procedure.
\*{next\*} proceeds as follows.
If \*{state\*} has the value \*{undefined\*},
then first set \*{state\*} to zero.
Then, if $state~<~self.size$, the array
$[self.retrieve(state),~state~+~1]$ is returned,
otherwise \*{next\*} fails.
.EX #{sn}
.{{
for c in 'lawn' do put(c, '\n') od
.}}
.sp 0.5
{Prints the characters `\*{l\*}\|', `\*{a\*}', `\*{w\*}' and `\*{n\*}'  on consecutive lines.
Note that this \*{for\*}-expression is equivalent to:
.DS L
.{{
        gen := 'lawn';
.br
        state := undefined;
.br
        while [c, state] := gen.next(state)
.br
        do put(c, '\n') od;
.}}
.DE
where \*{gen\*} and \*{state\*} are hidden local variables.}
.NX #{sn}
.PC #{sn+} "repl" "(n : integer) : string"
Returns a new instance of class \*{string\*} obtained by
concatenating \*{n\*} copies of \*{stringval\*}.
\*{n\*} should be non-negative.
.EX #{sn}
\&\*{''.repl(2)\*}	{value: \*{''\*}}
.br
\&\*{''.repl(0)\*}	{value: \*{''\*}}
.br
\&\*{'a'.repl(0)\*}	{value: \*{''\*}}
.br
\&\*{'a'.repl(1)\*}	{value: \*{'a'\*}}
.br
\&\*{'a'.repl(4)\*}	{value: \*{'aaaa'\*}}
.br
\&\*{'ab'.repl(0)\*}	{value: \*{''\*}}
.br
\&\*{'ab'.repl(1)\*}	{value: \*{'ab'\*}}
.br
\&\*{'ab'.repl(4)\*}	{value: \*{'abababab'\*}}
.br
.NX #{sn}
.PC #{sn+} "replace" "(s1, s2 : string) : string"
Returns a new instance of class \*{string\*}
obtained by replacing in \*{stringval\*} all characters
that occur in \*{s1\*} by the corresponding character in \*{s2\*}.
If \*{s2\*} is shorter than \*{s1\*}, the characters
occurring in the tail of \*{s2\*} are deleted from \*{stringval\*}.
If \*{s1\*} contains the same character more than once,
the value corresponding to the right-most occurrence is used.
.EX #{sn}
\&\*{'abcba'.replace('a', '*')\*}	{value: \*{'*bcb*'\*}}
.br
\&\*{'abcba'.replace('ac', '**')\*}	{value: \*{'*b*b*'\*}}
.br
\&\*{'abcba'.replace('aa', '*-')\*}	{value: \*{'-bcb-'\*}}
.br
\&\*{'abcba'.replace('ax', '*-')\*}	{value: \*{'*bcb*'\*}}
.br
\&\*{'abcba'.replace('xy', '*-')\*}	{value: \*{'abcba'\*}}
.br
\&\*{'abcba'.replace('a', '')\*}	{value: \*{'bcb'\*}}
.br
\&\*{'abcba'.replace('b', '')\*}	{value: \*{'aca'\*}}
.br
\&\*{'abcba'.replace('', '')\*}	{value: \*{'abcba'\*}}
.br
\&\*{''.replace('', '')\*}	{value: \*{''\*}}
.br
.NX #{sn}
.PC #{sn+} "retrieve" "(n : integer) : string"
Returns a new instance of class \*{string\*} of size one, which consists of
the \*{n\*}-th character in \*{stringval\*}.
The condition $0~<=~n~<~self.size$ should hold.
.EX #{sn}
\&\*{'apocalypse now'[6]\*}	{value: \*{'y'\*}}
.NX #{sn}
.PC #{sn+} "reverse" "() : string"
Let \*{stringval\*} consist of the characters $c sub 0 ~,..., ~ c sub {n-1}$.
The result of \*{reverse\*} is a new instance of class \*{string\*}
obtained by concatenating the characters $c sub {n-1} ~,..., ~ c sub 0$
(in this order).
.EX #{sn}
\&\*{''.reverse\*}	{value: \*{''\*}}
.br
\&\*{'a'.reverse\*}	{value: \*{'a'\*}}
.br
\&\*{'wolf'.reverse\*}	{value: \*{'flow'\*}}
.br
\&\*{'rever'.reverse\*}	{value: \*{'rever'\*}}
.NX #{sn}
.PC #{sn+} "right" "(n : integer, s : string) : string"
Returns a new instance of class \*{string\*} obtained by positioning
\*{stringval\*} at the right of a string of length \*{n\*}.
The remainder of that string is filled with replications of \*{s\*},
starting at the left.
The last replication of \*{s\*} is truncated on the right, if necessary. \*{stringval\*}
is truncated on the left if its size is greater than \*{n\*}.
\*{n\*} must be non-negative.
.EX #{sn}
\&\*{''.right(0, '.')\*}	{value: \*{''\*}}
.br
\&\*{''.right(5, '.')\*}	{value: \*{'.....'\*}}
.br
\&\*{'ab'.right(0, '.')\*}	{value: \*{''\*}}
.br
\&\*{'ab'.right(1, '.')\*}	{value: \*{'b'\*}}
.br
\&\*{'ab'.right(5, '.')\*}	{value: \*{'...ab'\*}}
.br
\&\*{'ab'.right(5, '. ')\*}	{value: \*{'. .ab'\*}}
.br
\&\*{'#'.right(5, 'abcdef')\*}	{value: \*{'abcde#'\*}}
.br
.NX #{sn}
.PC #{sn+} "size" " () : integer"
Returns the number of characters in \*{stringval\*}.
.EX #{sn}
\&\*{'andromeda'.size\*}	{value: \*{9\*}}
.br
\&\*{''.size\*}	{value: \*{0\*}}
.NX #{sn}
.PC #{sn+} "substr" "(offset, length : integer) : string"
Returns a new instance of class \*{string\*} obtained by taking a
substring from \*{stringval\*}.
If $length~=~0$, the empty string is returned.
Otherwise, let \*{N\*} be the number of characters in \*{stringval\*}
and let \*{M\*} be equal to $min(N~-~1,~offset~+~length~-~1)$.
Then a string consisting of the characters with indices
$offset,~offset+1 ,..., ~offset+M$ is returned.
The conditions $0~<=~offset~<~N$ and $length~>=~0$ should hold.
.EX #{sn}
\&\*{'abcd'.substr(0, 2)\*}	{value: \*{'ab'\*}}
.br
\&\*{'abcd'.substr(1, 3)\*}	{value: \*{'bcd'\*}}
.br
\&\*{'abcd'.substr(2, 7)\*}	{value: \*{'cd'\*}}
.NX #{sn}
.OB #{sn+} "\*{<\*}" " (s : string) : string" ""
.OM #{sn+} "\*{<=\*}" " (s : string) : string" "(Lexical less-than-or-equal)"
.OM #{sn+} "\*{=\*}" " (s : string) : string" "(Lexical equal)"
.OM #{sn+} "\*{~=\*}" " (s : string) : string" "(Lexical not-equal)"
.OM #{sn+} "\*{>=\*}" " (s : string) : string" "(Lexical greater-than-or-equal)"
.OE #{sn+} "\*{>\*}" " (s : string) : string" "(Lexical greater-than)"
Let \*{ascii(c)\*} be a function that maps a character
on its ordinal position in the ASCII character set.
The lexical comparison of two characters $c sub 1$ and $c sub 2$ can now be
defined by reducing lexical comparison to integer comparison, e.g.:
.DS
$c sub 1~<~c sub 2~==~ascii(c sub 1 )~<~ascii(c sub 2 )$
.DE
Lexical comparison of two strings $S sub 1$ and $S sub 2$ depends on the
lexical comparison of the characters in both strings and on the
size of the two strings.
Let {$c sub 1 ~,..., ~c sub n$} denote the characters in string $S sub 1$,
let {$d sub 1 ~,..., ~d sub m$} denote the characters in string $S sub 2$,
and let $min(n,m)$ be the smallest of the integers \*{n\*} and \*{m\*}.
The string $S sub 1$ is then defined to be
\fBlexically-less-than\fP (\fBllt\fP) the string $S sub 2$ iff
\fBeither\fP there exists an index $k$, $1~<=~k~<=~min(n,m)$, such that
$c sub i ~=~ d sub i$ for all $1~<=~i~<~k$ and $c sub k ~<~ d sub k$,
\fBor\fP $n~<~m$.
.sp 0.5
The string $S sub 1$ is defined to be
\fBlexically-equal-to\fP (\fBleq\fP)
string $S sub 2$ iff $n~=~m$ and $c sub i~=~d sub i$ for all $1~<=~i~<= n$.
.sp 0.5
The lexical operators can now be defined as follows.
The lexical comparison $stringval~\*(o2~s$ is performed, where $\*(o2$
is one of the lexical comparison operators given above.
If the comparison succeeds, the operation returns \*{s\*} as value.
Otherwise, the operation fails.
Success or failure of the lexical operators is defined as follows:
.DS L
.ta 2c 6c
	Operation	Succeeds if
.sp 0.5
	\*{P < Q\*}	$P~bold llt~Q$
	\*{P <= Q\*}	$P~bold llt~Q~roman or~P~bold leq~Q$
	\*{P = Q\*}	$P~bold leq~Q$
	\*{P ~= Q\*}	$\(no~(P~bold leq~Q)$
	\*{P >= Q\*}	$\(no~(P~bold llt~Q)$
	\*{P > Q\*}	$\(no~(P~bold llt~Q)~roman and~\(no~(P~bold leq~Q)$
.DE
.EX #{sn}
\&\*{'a' < 'b'\*}	{value: \*{'b'\*}}
.br
\&\*{'b' < 'a'\*}	{fails}
.br
\&\*{'a' < 'a'\*}	{fails}
.br
\&\*{'abc' < 'abd'\*}	{value: \*{'abd'\*}}
.br
\&\*{'abc' < 'aba'\*}	{fails}
.br
\&\*{'abc' < 'abcdef'\*}	{value: \*{'abcdef'\*}}
.br
\&\*{'abc' <= 'abc'\*}	{value: \*{'abc'\*}}
.br
\&\*{'abc' <= 'abd'\*}	{value: \*{'abd'\*}}
.NX #{sn}
.OP #{sn+} "\*{||\*}" " (s : string) : string" ""
Returns a new instance of class \*{string\*}
consisting of the characters in \*{stringval\*} followed
by the characters in \*{s\*}.
.EX #{sn}
\&\*{'leg' || 'end'\*}	{value: \*{'legend'\*}}
.br
\&\*{'now' || 'here'\*}	{value: \*{'nowhere'\*}}
.SH #{Lib/array=sn<+}. "Class array"
.iy I array
.PP
Class \*{array\*} provides a facility to create
sequences of values.
The organization of this class is:
.DS
.{{
class array(nelems : integer, defval : arbtype)
begin fetch append, delete, index, last, next,
            retrieve, size, sort, update;

      proc append(val) ( ... );
      ...
      proc update(i, val) ( ... );

end array;
.}}
.DE
The elements of the array have arbitrary type.
Different elements of an array may have different types.
All array elements are initialized to the default value \*{defval\*}.
See Section #{Array expressions} for a description of
\*<array-expression\*>s
.iy I <array-expression> s
and in particular for a description of the initialization of arrays.
.PP
The operations on arrays are now described in more detail.
.PC #{sn>1} "append" " (val : arbtype) : arbtype"
Extends the array by adding
a new element to it at index position \*{nelems\*} with value \*{val\*}.
The size of the array (i.e. \*{nelems\*}) is thus effectively
incremented by one.
.EX
.{{
a := array(4, -1);
.}}
.sp 0.5
{Establishes a context for the following examples by
creating a new instance of the class \*{array\*} and assigning it to \*{a\*}.}
.sp 0.5
.{{
a.append(10);
.br
a.append(20);
.}}
.sp 0.5
{These two statements extend array \*{a\*}
with array elements at index positions 4 and 5
and with values 10 and 20 respectively.}
.sp 0.5
\*{a[3]\*}	{value: \*{-1\*}}
.br
\*{a[4]\*}	{value: \*{10\*}}
.br
\*{a[5]\*}	{value: \*{20\*}}
.br
\*{a[6]\*}	{error}
.NX
.PC #{sn+} "delete" " () : arbtype"
Removes the last element
(i.e. the element at index position \*{nelems-1\*}) from the array
and returns its value.
The size of the array (i.e. \*{nelems\*}) is thus effectively decremented
by one.
The condition $nelems~>~0$ should hold prior to the \*{delete\*} operation.
.EX
\*{a := [10, 20, 30];\*}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{a[2]\*}	{value: \*{30\*}}
.br
\*{a.delete\*}	{value: \*{30\*}}
.br
\*{a[2]\*}	{error}
.NX
.PC #{sn+} "index" " () : interval"
Returns \*{interval(0, nelem - 1, 1)\*} {#{Lib/interval}} as value.
This procedure is particularly useful in
\*<for-expression\*>s
.iy I <for-expression> s
{#{For expressions}}
that iterate over all indices of an array.
.EX #{sn}
.{{
a := array(6, 0);
.br
for n in a.index do a[n] := n * n od
.}}
.sp 0.5
{First an instance of \*{array\*} is assigned to variable \*{a\*} and then
the square of its index is assigned to each array element.}
.NX #{sn}
.PC #{sn+} "last" "() : arbtype"
Returns the value of the array element with index \*{nelems-1\*}.
This is useful when the array is treated in a stack-like fashion
by means of \*{append\*} and \*{delete\*} operations.
.EX
\*{a := [10, 20, 30];\*}
.br
\*{a.last\*}	{value: \*{30\*}}
.br
\*{a.delete\*}	{value: \*{30\*}}
.br
\*{a.last\*}	{value: \*{20\*}}
.NX
.PC #{sn+} "next" "(state : undefined-or-integer) : array"
Returns the value of the next array element (if any) and fails otherwise.
This procedure is mostly used in connection with
\*<for-expression\*>s
.iy I <for-expression> s
{#{For expressions}}.
\*{next\*} proceeds as follows.
If \*{state\*} has the value \*{undefined\*} and $nelem~>~0$ holds,
the array $[self.retrieve(0),~1]$ is returned.
If the type of \*{state\*} is \*{integer\*} and $state~<~nelem-1$ holds,
the array $[self.retrieve(state),~state~+~1]$ is returned.
Otherwise, \*{next\*} fails.
.EX #{sn}
.{{
a := array(5, -1); a[1] := 10; a[3] := 20;
.br
for x in a do put(x, '\n') od
.}}
.sp 0.5
{First a new array is created and initialized, next
the values $-1$, $10$, $-1$,
$20$, and $-1$ are printed on consecutive lines.}
.NX #{sn}
.PC #{sn+} "retrieve" "(i : integer) : arbtype"
Returns the \*{i\*}-th value from the array.
The condition $0~<=~i~<~nelems$ should hold.
See also {#{Subscription}}.
.EX #{sn}
.{{
a := [-2, -2, -2, -2];
.br
a[1] := 7;
.}}
.sp 0.5
{Establishes a context for the following examples.
First a new array is assigned to variable \*{a\*}.
Next, $7$ is assigned to the array element with index $1$.}
.sp 0.5
.{{
a.retrieve(3);
.br
a.retrieve(1);
.br
a.retrieve(-5);
.}}
.sp 0.5
{The array elements with indices $3$ and $1$ are retrieved; this gives
the respective values $-2$ and $7$.
An error will be signalled for the last expression since the index $-5$
is out of range.
Note that these three expressions can be abbreviated to
$a[3]$ ,
$a[1]$ and
$a[-5]$ respectively.}
.NX #{sn}
.PC #{sn+} "size" " () : integer"
Returns the integer value \*{nelem\*}.
.EX #{sn}
\*{a := array(17, 'def')\*}	{creates new array}
.br
\*{a.size\*}	{returns 17}
.NX #{sn}
.PC #{sn+} "sort" "() : array"
Returns a new instance of class \*{array\*} obtained by sorting
the contents of the array, i.e. \*{self\*}.
Values are sorted according to their type in the following order:
.DS
.{{
undefined
integer
real
string
array
table
file
bits
scan_string
interval
.}}
(user defined classes in order of declaration in the program)
.DE
Integers and reals are put in order of increasing numeric value.
Strings are sorted lexicographically.
Other values are sorted according to their creation time:
older values come before values that were created more recently.
.EX #{sn}
.{{
[4,'z',3,'a'].sort
.}}
.sp 0.5
{value: \*{[3, 4, 'a', 'z']\*}}
.NX #{sn}
.PC #{sn+} "update" "(i : integer, val : arbtype) : arbtype"
This procedures updates the value of the \*{i\*}-th element from the array
in such a way that subsequent retrieval (without an intervening update)
of the \*{i\*}-th element returns the value \*{val\*}.
\*{val\*} may be of arbitrary type.
The condition $0~<=~i~<~nelems$ should hold.
See also #{Dyadic expressions}.
.EX #{sn}
.{{
a := array(4, -1);
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
.{{
a.update(2, 5);
.br
a.update(7, 'ab');
.}}
.sp 0.5
{The first expression assigns the integer value 5 to the array element with index 2.
For the second expression an error will be signalled, since the index 7
is out of range.
Note that these two expressions can be abbreviated to
.{{
a[2] := 5
.}}
and
.{{
a[7] := 'ab'
.}}
respectively.}
.NX #{sn}
.SH #{Lib/interval=sn<+}. "Class interval"
.iy I interval
.PP
Class \*{interval\*} defines intervals of integer or real values.
Instances of this class are most often used in
\*<for-expression\*>s
.iy I <for-expression> s
{#{For expressions}}.
The organization of this class is as follows:
.DS
\*{class interval(from, to, by :\*} \fIinteger-or-real\fR)
.{{
begin fetch next;

      proc next(state) ( ... );

end interval;
.}}
.DE
The formal parameters \*{from\*}, \*{to\*} and \*{by\*} must be of type \*{integer\*} or \*{real\*}.
If one is of type \*{real\*}, then the values of the other (integer)
parameters are first converted to \*{real\*}.
Note that a definition of this class has been given as an example
in Section #{For expressions}.d.
The only operation (\*{next\*}) on intervals is now described in detail.
.PC #{sn>1} "next" "(state : undefined-or-integer-or-real) : array"
Returns the next value in the \*{interval\*} (if any) and fails otherwise.
This procedure is most often used in connection with
\*<for-expression\*>s.
.iy I <for-expression> s.
\*{next\*} proceeds as follows.
If the type of \*{state\*} is \*{undefined\*} then set \*{V\*} to the value of \*{from\*},
otherwise set \*{V\*} to the value of \*{state + by\*}.
If the value of \*{by\*} is positive and \*{V < to\*} holds,
or the value of \*{by\*} is negative and \*{V >= to\*} holds,
then the array \*{[V, V]\*} is returned.
In all other cases \*{next\*} fails.
.EX #{sn}
.{{
for x in interval(1, 5, 2) do put(x, '\n') od
.}}
.sp 0.5
{Prints the integers $1$, $3$ and $5$}}
.sp 0.5
.{{
for x in interval(5, 0, -2) do put(x '\n') od
.}}
.sp 0.5
{Prints the integers $5$, $3$ and $1$}
.sp 0.5
.{{
for x in interval(2, 5, 1.3) do put(x, '\n') od
.}}
.sp 0.5
{Prints the reals $2.0$, $3.3$ and $4.6$}
.NX #{sn}
.SH #{Lib/table=sn<+}. "Class table"
.iy I table
.PP
Class \*{table\*} provides an associative memory
that can be indexed with values of arbitrary type.
Basically, it is organized as follows:
.DS
.{{
class table(nentries : integer, defval : arbtype)
begin fetch index, next, retrieve, size, update;

      proc index () ( ... );
      ...
      proc update(i, val) ( ... );

end table;
.}}
.DE
A table may contain an arbitrary number of entries,
but (as a hint for the implementation)
an estimate of the expected number of entries must be
given as value of \*{nentries\*}.
Each entry in the table consists of a (key, value) pair.
An update operation either adds a new entry to the table
or replaces the value part of an existing entry.
A retrieve operation returns the value part
of the entry corresponding to a given key.
If such an entry does not exist,
then the default value \*{defval\*} is returned.
As a consequence, no distinction can be made between entries that were
never added to the table
and entries that contain \*{defval\*} as value part.
This property of tables can be used to delete table entries.
A table entry will be called
\fBlive\fP
if its value part is not equal to \*{defval\*}.
All other entries are called \fB dead\fP.
Assigning \*{defval\*} to the value part of an entry, \fBkills\fP that entry.
The operations \*{index\*}, \*{next\*} and \*{size\*}
operate on the live entries in the table.
This distinction between live, dead and nonexistent entries is
necessary for the description of the behavior of tables in \*<for-expression\*>s.
.PP
See Section #{Table expressions} for a description of \*<table-expression\*>s
and in particular for a description of the initialization of tables.
.PP
In the examples the table \*{taste\*} will be used,
It is defined as follows:
.DS
.{{
taste := table(20, 0) init [
         'sweet':        10,
         'bitter':       -8,
         'sour': 'acid': -11,
         'pickled':      +17 ];
.}}
.DE
Operations on tables are now described in more detail.
.PC #{sn>1} "index" "() : array"
Returns an array with (sorted) table keys,
for all live table entries.
The keys are sorted as described in #{Lib/array}.
.EX
.{{
taste.index
.}}
.sp 0.5
{value: \*{['acid', 'bitter', 'pickled', 'sour', 'sweet']\*} }
.sp 0.5
.br
.ne 5
.{{
for t in taste.index do put(t, '\n') od
.}}
.sp 0.5
{Prints the strings \*{'acid'\*}, \*{'bitter'\*},
\&\*{'pickled'\*}, \*{'sour'\*} and \*{'sweet'\*} on consecutive lines.}
.NX #{sn}
.PC #{sn+} "next" "(state : undefined-or-array) : array"
Enumerates the value parts of the live entries in the table.
If \*{state\*} is equal to \*{undefined\*}, the effect of \*{next\*}
is the same as the effect of \*{next(self.index, 0)\*}.
Otherwise, \*{state\*} should have the form $[A,~N]$ and
the following steps are performed:
As long as $N~<~A.size$ and
$self.retrieve(A[N])$ is equal to \*{defval\*},
\*{N\*} is incremented by one.
If $N~=~A.size$, \*{next\*} fails.
Otherwise, $[self.retrieve(A[N]),~[A,~N+1]]$ is returned.
.EX
.{{
for flavor in taste do put(flavor, '\n') od
.}}
.sp 0.5
{Prints the integers $-11$, $-8$, $17$, $-11$ and $10$.}
.NT #{sn}
If we restrict our attention to the use of \*{next\*} in
\*<for-expression\*>s
.iy I <for-expression> s
{#{For expressions}},
the following can be observed:
The \*{index\*} of the table is computed only once.
This gives an array $A$ with a fixed number of keys, which
cannot be affected by operations on the table inside the body
of the \*<for-expression\*>.
However, the value parts of the entries containing the keys in $A$
may be affected by intermediate update operations.
The procedure \*{next\*} is defined in such a way that table entries
that were killed since the creation of the index, are effectively
skipped.
.NX #{sn}
.PC #{sn+} "retrieve" "(key : arbtype) : arbtype"
If a call of the form \*{update(key,val)\*} has occurred previously, \*{val\*}
is returned.
Otherwise the default value \*{defval\*} is returned.
Note that tables are also initialized by means of \*{update\*} operations
{#{For expressions}}.
.EX
\*{taste.retrieve('sour')\*}	{value: \*{-11\*}}
.br
\*{taste.retrieve('dulce')\*}	{value: \*{0\*}}
.sp 0.5
{Note that these examples may be abbreviated to \*{taste['sour']\*} and
\*{taste['dulce']\*} respectively.}
.NX #{sn}
.PC #{sn+} "size" " () : integer"
Returns the number of live entries in the table.
.EX
\*{taste.size\*}	{value: \*{5\*}}
.NX #{sn}
.PC #{sn+} "update" "(key, val : arbtype) : arbtype"
Associates the value \*{val\*} with \*{key\*}.
If \*{val\*} is equal to the default value \*{defval\*} this operation
kills the table entry containing \*{key\*} (if it exists).
The value \*{val\*} is returned as result of \*{update\*}.
.EX
.{{
taste.update('salted', 17)
.}}
.sp 0.5
{Adds the (key, value) pair (\*{'salted'\*}, $17$) to the table and
returns \*{17\*} as value.
Note that the above expression may be abbreviated to \*{taste['salted'] :=\*} 17.}
.NX #{sn}
.SH #{Lib/scan_string=sn<+}. "Class scan\h'-0.2m'\v'0.4m'\(mi\v'-0.4m'\h'-0.2m'string"
.iy I scan_string
.PP
Class \*{scan_string\*} provides a scanning facility for strings and files.
Basically, it is organized as follows:
.DS
\*{class scan_string(arg :\*} \fIstring-or-file\fR)
.{{
begin fetch any, bal, break, cursor, find, lit, move, 
            pos, rtab, span, tab, text;
      var text, cursor;

      proc any(s) ( ... );
      ...
      proc tab(n) ( ... );

init: cursor := 0
      text := convert_to_string(arg);
end scan_string;
.}}
.DE
When an instance of class \*{scan_string\*} is created, the actual value
of \*{arg\*} may be either a \*{string\*} or a \*{file\*}.
In the latter case, the file is (at least conceptually) converted to a string.
All scanning procedures operate on this string.
The (perhaps converted) value of \*{arg\*} is assigned to the class variable \*{text\*}
which is thereafter used by all operations defined for the class.
The current cursor position is maintained in the class variable \*{cursor\*}.
Both \*{text\*} and \*{cursor\*} may be fetched from outside the class instance.
The value of \*{text\*} remains invariant under all class operations,
but the value of \*{cursor\*} may change.
.PP
Sometimes it is convenient to look at the subject string (\*{text\*})
as being an array of characters.
This is done in the way described in Section #{Lib/string}.
.PP
A few general restrictions apply to the following definitions:
.IP 1)
Unless stated otherwise, operations fail if \*{cursor\*} is equal
to $text.size$.
.IP 2)
If more than one cursor value satisfies some condition, then
the smallest of these values is used.
.PP
It must be emphasized that the examples given in this section are not typical:
they serve to illustrate the working of just one procedure, but
do not properly illustrate the use of procedures in more
realistic applications.
All these procedures will, in general, be used in conjunction with
\*<scan-expression\*>s {#{Scan expressions}}.
When used in this way \*{scan_string\*} objects need hardly
ever be created or mentioned explicitly.
See chapters #{SUMMER OVERVIEW} and #{ANNOTATED PROGRAMS} for more interesting examples.
.PP
The meaning of the various procedures is defined below.
.PC #{sn>1} "any" "(s: string) : string"
If $text[cursor]$ is equal to one of the characters in \*{s\*}, then
$text[cursor]$ is returned and \*{cursor\*} is incremented by one.
Otherwise \*{any\*} fails.
.EX
.{{
p := scan_string('quota');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
.{{
p.any('0123456789');
.}}
.sp 0.5
{Tests for the occurrence of digits at the start
of the subject string and fails; the cursor is not affected.}
.sp 0.5
.{{
x := p.any('pqr')
.}}
.sp 0.5
{This test for the occurrence of one of
the characters \*{'p'\*}, \*{'q'\*} or \*{'r'\*}
succeeds: the cursor of \*{p\*} is moved to the right (i.e. $p.cursor=1$)
and the string \*{'q'\*} is returned by \*{any\*} and assigned to
the variable \*{x\*}.}
.NX #{sn}
.PC #{sn+} "bal" "(S, P, Q : string) : string"
If there exists a cursor value \*{c\*} such that $c~>~cursor$,
$text[c]$ equal to one of the characters in \*{S\*}, and
$text.substr(cursor,~c-cursor)$ `balanced' with respect to
\*{P\*} and \*{Q\*}, the balanced substring is returned and \*{cursor\*} is
set to \*{c\*}.
If more than one value of \*{c\*} satisfies the above condition, then
the smallest (i.e. leftmost) one is used.
Otherwise \*{bal\*} fails.
.sp 1
A string \*{S\*} is balanced with respect to two other strings
\*{P\*} and \*{Q\*} iff:
.sp 1
.in +5n
\*{S\*} is a single character not in \*{P\*} or \*{Q\*}
.in -5n
or
.in +5n
\*{S\*} has the form $c sub 1~||~A~||~c sub 2$ where $c sub 1$ is a single character
occurring in \*{P\*} and $c sub 2$ is a single character occurring in \*{Q\*}
and \*{A\*} is balanced with respect to \*{P\*} and \*{Q\*}.
.in -5n
or
.in +5n
\*{S\*} has the form $A~||~B$ and both \*{A\*} and \*{B\*}
are balanced with respect to \*{P\*} and \*{Q\*}.
.in -5n
.EX
.{{
e := scan_string('x:=a+b[i]*(y+5); z:=3');
.}}
.sp 0.5
{Establishes the context for the next example.}
.sp 0.5
.{{
x := e.bal(';', '([', ')]');
.}}
.sp 0.5
{Assigns \*{'x:=a+b[i]*(y+5)'\*} to \*{x\*} and moves the cursor to 15,
i.e. $e.cursor~=~15$.}
.sp 0.5
.{{
e := scan_string('{xx(x())!xx}');
.}}
.sp 0.5
{Establishes the context for the next two examples.}
.sp 0.5
.{{
e.bal('!', '({', '})')
.}}
.sp 0.5
{This expression fails and does not move the cursor.}
.sp 0.5
.{{
x := e.bal('!', '(', ')');
.}}
.sp 0.5
{Assigns \*{'{xx(x())'\*} to \*{x\*} and moves the cursor to 8.}
.NX #{sn}
.PC #{sn+} "break" "(s : string) : string"
If there exists a cursor value \*{c\*} such that $c~>~cursor$ and
$text[c]$ is equal to one of the characters in \*{s\*}, then
$text.substr(cursor,~c-cursor)$ is returned
and the cursor is set to \*{c\*}.
If more than one value of \*{c\*} satisfies the above condition,
the smallest (i.e. leftmost) one is used.
\*{break\*} fails otherwise.
.EX
.{{
answer := scan_string('yes/no');
.}}
.sp 0.5
{Establishes the context for the next two examples.}
.sp 0.5
\*{answer.break('!?;')\*}	{fails}
.br
\*{answer.break('/')\*}
.sp 0.5
{The last expression succeeds, moves the cursor to 3
and returns the string \*{'yes'\*}.}
.NX #{sn}
.PC #{sn+} "find" "(s : string) : string"
If there exists a cursor value \*{c\*} such that
$c~>=~cursor$ and \*{s\*} is a substring of \*{text\*} starting at \*{c\*},
then $text.substr(cursor,~c-cursor)$ is returned
and the cursor is set to \*{c\*}.
Otherwise \*{find\*} fails.
.EX
.{{
fruit := scan_string('apple;pear;lemon;peach');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{fruit.find('banana')\*}	{fails}
.br
.{{
fruit.find('apple')
.}}
.sp 0.5
{Returns the value \*{''\*} (i.e. the empty string) and leaves the cursor at 0}
.sp 0.5
.{{
fruit.find('lemon')
.}}
.sp 0.5
{Succeeds, moves the cursor to 11, and
returns the string \*{'apple;pear;'\*}.}
.NX #{sn}
.PC #{sn+} "lit" "(s : string) : string"
If \*{s\*} is a substring of \*{text\*} starting at the current
cursor position, \*{s\*} is returned and \*{cursor\*}
is incremented by the length of \*{s\*}.
Otherwise \*{lit\*} fails.
.EX
.{{
person := scan_string('the man');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{person.lit('some');\*}	{fails}
.br
\*{person.lit('man');\*}	{fails}
.br
.{{
person.lit('the')
.}}
.sp 0.5
{The last expression succeeds, moves \*{cursor\*} to 3 and
returns the string \*{'the'\*}.}
.NX #{sn}
.PC #{sn+} "move" "(n : integer) : string"
If $0~<=~cursor~+~n~<=~text.size$,
there are two different cases:
1)\ $n~>=~0$:\ Let \*{R\*} be $text.substr(cursor,n)$.
.br
2)\ $n~<~0$:\  Let \*{R\*} be $text.substr(cursor+n,-n)$.
.br
In both cases \*{cursor\*} is incremented by \*{n\*} and \*{R\*} is returned.
Otherwise \*{move\*} fails.
.EX
.{{
digits := scan_string('0123456789');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{digits.move(15)\*}	{fails}
.br
.{{
digits.move(5)
.}}
.sp 0.5
{Succeeds, moves the cursor to 5, and returns the string \*{'01234'\*}.}
.sp 0.5
.{{
digits.move(-2)
.}}
.sp 0.5
{Succeeds, moves the cursor back to 3, and returns the string \*{'34'\*}.}
.NX #{sn}
.PC #{sn+} "pos" "(n : integer)"
If $cursor~=~n$, the empty string is returned.
Otherwise \*{pos\*} fails.
.EX
.{{
digits := scan_string('0123456789');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{digits.pos(0);\*}	{value: \*{''\*}}
.br
.{{
digits.move(2);
.}}
.sp 0.5
{Returns the value \*{'01'\*} and moves the cursor to 2}
.sp 0.5
\*{digits.pos(0);\*}	{fails}
.br
\*{digits.pos(2);\*}	{value: \*{''\*}}
.NX #{sn}
.PC #{sn+} "rpos" "(n : integer)"
If $cursor~=~text.size-n$, the empty string is returned as value.
Otherwise \*{rpos\*} fails.
.EX
.{{
digits := scan_string('0123456789');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{digits.rpos(10)\*}	{value: \*{''\*}}
.br
\*{digits.rpos(4)\*}	{fails}
.br
.{{
digits.move(10)
.}}
.sp 0.5
{Returns the value \*{'0123456789'\*} and moves the cursor to 10}
.sp 0.5
\*{digits.rpos(0)\*}	{value: \*{''\*}}
.NX #{sn}
.PC #{sn+} "rtab" "(n : integer) : string"
Let \*{R\*} be equal to $text.size~-~n$.
If $0~<=~n~<=~text.size$, there are two different cases:
.br
1)\ $cursor~<=~R$:
Set \*{V\*} to $text.substr(cursor,R-cursor)$.
.br
2)\ $cursor~>~R$:
Set \*{V\*} to $text.substr(R,cursor-R)$.
.br
In both cases the cursor is set to \*{R\*} and \*{V\*} is returned.
Otherwise \*{rtab\*} fails.
.NT #{sn}
\*{rtab(n)\*} has the same effect as $tab((text.size)-n)$.
.NX #{sn}
.PC #{sn+} "span" "(s : string) : string"
If there exists a cursor value \*{c\*} such that
$c~>~cursor$, and $text.substr(cursor,~c-cursor)$
consists solely of characters in \*{s\*}, this substring is returned
and the cursor is set to \*{c\*}.
If more than one value of \*{c\*} satisfies this condition, the largest
(i.e. rightmost) one is used.
Otherwise \*{span\*} fails.
.EX
.{{
p := scan_string('.....finally!');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
\*{p.span('?;')\*}	{fails}
.sp 0.5
.{{
p.span('.')
.}}
.sp 0.5
{Succeeds, moves the cursor to 5, and returns the string \*{'.....'\*}.}
.NX #{sn}
.PC #{sn+} "tab" "(n : integer) : string"
If $0~<=~n~<=~text.size$, there are two different cases:
.br
1)\ $n~>=~cursor$:
Set \*{V\*} to $text.substr(cursor,n-cursor)$.
.br
2)\ $n~<~cursor$:
Set \*{V\*} to $text.substr(n,cursor-n)$.
.br
In both cases the cursor is set to \*{n\*} and \*{V\*} is returned.
Otherwise \*{tab\*} fails.
.EX
.{{
h := scan_string('History of exact sciences');
.}}
.sp 0.5
{Establishes the context for the following examples.}
.sp 0.5
.{{
h.tab(7)
.}}
.sp 0.5
{Returns the value \*{'History'\*} and moves the cursor to 7}
.sp 0.5
.{{
h.tab(3)
.}}
.sp 0.5
{Returns the value \*{'tory'\*} and moves the cursor to 3}
.NX #{sn}
.SH #{Lib/file=sn<+}. "Class file"
.iy I file
.PP
The class \*{file\*} provides external character files with associated
operations on them.
The basic organization of this class is as follows:
.DS
.{{
class file(name, accesstype : string)
begin fetch close, get, put;

      proc close() ( ... );

      proc get() ( ... );

      proc put(v1, v2, ... ) ( ... );

end file;
.}}
.DE
When a new instance of class file is created,
an external file with name \*{name\*} is opened or created; \*{name\*}
must be an acceptable file name for the local operating system.  \*{accesstype\*}
determines the intended use of the file as follows:
.DS
.ta 2c
\&\*{'r'\*}	for reading
\&\*{'w'\*}	for writing
.DE
Three predefined file names exist: \*{'stand_in'\*},
\&\*{'stand_out'\*} and \*{'stand_er'\*}
which correspond to the standard input , standard output,
and standard error file respectively.
Apart from these predefined file names, there are also three
predefined global variables \*{stand_in\*}, \*{stand_out\*} and \*{stand_er\*},
which have these three predefined files as initial value.
.NX #{sn}
.PC #{sn>1} "close" "()"
Close file.
After a file has been closed no further i/o operations can be performed on it.
.EX
.{{
scratch := file('tmp1', 'w');
.}}
.sp 0.5
{A file with name \*{'tmp1'\*} is opened for writing and the resulting
file instance is assigned to \*{scratch\*}.}
.sp 0.5
.{{
scratch.close;
.}}
.sp 0.5
{Next, that file is closed.}
.NT #{sn}
All files are closed when the program terminates.
Closing a file from within the scope of a
\*<try-expression\*>
.iy I <try-expression>
{#{Try expressions}} is forbidden.
.NX #{sn}
.PC #{sn+} "get" "() : string"
Returns the next line (without trailing newline symbol) from the file and fails on end of file.
.EX
.{{
source := file('mytext', 'r');
.}}
.sp 0.5
{The file \*{'mytext'\*} is opened for reading and the resulting file instance
is assigned to \*{source\*}.}
.sp 0.5
.{{
line := source.get
.}}
.sp 0.5
{Next, one line is read from that file and the resulting string is
assigned to \*{line\*}.}
.sp 0.5
.{{
stand_in.get
.}}
.sp 0.5
{Reads one line from standard input.}
.NT #{sn}
See also global procedure \*{get\*} {#{Lib/miscellaneous}}
which operates on
standard input.
.NX #{sn}
.PC #{sn+} "put" "(v1, v2, . . . : integer-or-real-or-string)"
Writes the values \*{v1\*}, \*{v2\*}, \*{...\*} on the file,
after converting them to strings.
No newline character is appended.
.EX
.{{
f := file('results', 'w');
.br
f.put('The value of "x" is :', x);
.}}
.sp 0.5
{Creates the file \*{'results'\*} and writes on it.}
.sp 0.5
.{{
stand_er.put('Fatal error!')
.}}
.sp 0.5
{Writes a string on the standard error stream.}
.NT #{sn}
See also global procedure \*{put\*} {#{Lib/miscellaneous}}
which operates on standard output.
.NX #{sn}
.SH #{Lib/bits=sn<+}. "Class bits"
.iy I bits
.PP
Class \*{bits\*} provides arbitrary length bit-strings and associated operations.
A bit-string consists solely of the integer values \*{0\*} and \*{1\*}.
This class is organized as follows:
.DS
.{{
class bits(nelem, defval : integer)
begin fetch conj, compl, disj, index, next,
            retrieve, update, size;

      proc conj(b) ( ... );
      ...
      proc update(i, val) ( ... );

end bits;
.}}
.DE
.PP
The formal parameter \*{nelem\*} must be of type integer and defines
the number of elements in the bit-string. \*{defval\*} must be either integer 0
or integer 1 and defines the value to which all elements of the
bit-string are initialized.
.PP
There is no way to initialize bit-strings other than by explicit
assignment to individual elements.
.PC #{sn>1} "conj" "(b : bits) : bits"
Computes the bit-wise \fBand\fP with the bits value \*{b\*}.
If \*{nelem\*} and \*{b.size\*} are unequal, the smallest bit-string
is first padded with ones at the right end, i.e. starting at the highest index.
.NX #{sn}
.PC #{sn+} "disj" "(b : bits) : bits"
Computes the bit-wise \fBor\fP with the bits value \*{b\*}.
If \*{nelem\*} and \*{b.size\*} are unequal, then the smallest bit-string
is first padded with zeros at the right end, i.e. starting at the highest index.
.NX #{sn}
.PC #{sn+} "compl" " () : bits"
Computes the bit-wise complement.
.NX #{sn}
.PC #{sn+} "index" " () : interval"
.iy I interval
Returns the index set $interval(0,nelems-1,1)$ {#{Lib/interval}}.
.NX #{sn}
.PC #{sn+} "next" " (state : undefined-or-integer) : array"
Returns the value of the next bit (if any) and fails otherwise.
This procedure is mostly used in conjunction with \*<for-expression\*>s
{#{For expressions}}.
\*{next\*} proceeds as follows.
If \*{state\*} is \*{undefined\*} and \*{nelem>0\*}, the
array $[self.retrieve(0),~1]$ is returned.
If the type of \*{state\*} is \*{integer\*} and $state~<~nelem-1$,
the array $[self.retrieve(state),~state+1]$ is returned.
Otherwise \*{next\*} fails.
.NX #{sn}
.PC #{sn+} "retrieve" "(i : integer) : integer"
Returns the \*{i\*}-th element.
The condition $0~<=~i~<~nelem$ should hold.
.NX #{sn}
.PC #{sn+} "size" " () : integer"
Returns the integer value \*{nelem\*}.
.NX #{sn}
.PC #{sn+} "update" "(i, val : integer) : integer"
Assigns the integer value \*{val\*} to the \*{i\*}-th element.
\*{val\*} should be $0$ or $1$, and the condition $0~<=~i~<~nelem$ should hold.
.NX #{sn}
.SH #{Lib/miscellaneous=sn<+}. "Miscellaneous procedures"
.PC #{sn>1} "copy" "(a : arbtype) : arbtype" #{Lib/copy=sn}
Returns a copy of the value \*{a\*}.
If \*{a\*} is composite, all its components are copied
recursively.
.NX #{sn}
.PC #{sn+} "get" "() : string"
This is an abbreviation for \*{stand_in.get()\*}
{#{Lib/file}}.
It reads the next line (without trailing newline character)
from the standard input file and fails on end of file.
.NX #{sn}
.PC #{sn+} "put" "(v1, v2, . . . : integer-or-real-or-string)"
This is an abbreviation for \*{stand_out.put(v1, v2, ...)\*}
{#{Lib/file}}.
It writes the values \*{v1\*}, \*{v2\*}, \*{...\*} on the standard output file,
after converting them to strings.
.NX #{sn}
.PC #{sn+} "stop" "(n : integer)"
Stops program execution.
If \*{n\*} is negative,
the names and values of the actual parameters of all 
currently entered procedures are printed.
The absolute value of \*{n\*} is returned to the operating system.
By convention, values unequal to zero are considered error codes.
.EX #{sn}
.{{
stop(0)
.}}
.NX #{sn}
.PC #{sn+} "type" "(a : arbtype) : string" #{Lib/type=sn;}
Determine the type of \*{a\*}.
The following string values can be returned
depending on the operand type:
.DS
.ta 6
\&\*{'integer'\*}	integer
\&\*{'real'\*}	real
\&\*{'string'\*}	string
\&\*{'file'\*}	file
\&\*{'undefined'\*}	undefined value
\&\*{'table'\*}	table
\&\*{'array'\*}	array
\&\*{'bits'\*}	bits
.DE
For class instances the class name is returned.
.NT
A formal definition of \*{type\*} was given in
Section #{Identifiers and procedure calls}.
.NX #{sn}
#{sn<<;}#{figs<;}
.EC
