#{figs+>;}
.NC #{PRELIMINARIES=sn+} "PRELIMINARIES TO" "THE DEFINITION OF SUMMER"
.ds LH "PRELIMINARIES TO THE DEFINITION OF SUMMER
.PP
In this chapter we introduce the techniques that will be used to
describe the syntax and semantics of the \s-2SUMMER\s0 programming language.
Section #{Syntactical considerations} introduces an extended form of
BNF notation that will be used to describe the syntax.
Section #{Lexical considerations} defines the lexical primitives of \s-2SUMMER\s0.
In section #{Semantic considerations} the method used for
the description of semantics is introduced and, at the same time,
the semantic primitives used in the \s-2SUMMER\s0 definition are defined.
In section #{Unspecified} some peculiarities and shortcomings of
the definition are discussed.
.SH #{Syntactical considerations=sn>1}. "Syntactic considerations"
.PP
.iy I "syntax notation"
An extended form of BNF notation will be used to describe the syntax
of \s-2SUMMER\s0.
It aims at providing a concise notation for the description
of repeated and optional syntactic notions.
A syntactic notion suffixed with `\*{+\*}' means one or more repetitions of that notion.
A notion suffixed with `\*{*\*}' stands for zero or more repetitions
of that notion.
The notation
.DS
{ \*{notion\*} \*{separator\*} } \*{replicator\*}
.DE
i.e. a \*{notion\*} followed by a \*{separator\*} enclosed in braces
and followed by a \*{replicator\*},
is used to describe lists of notions
separated by the given separator.
A separator should be a terminal symbol of the grammar.
A replicator is either `\*{+\*}' or `\*{*\*}'.
The replicator `\*{+\*}' indicates that the list consists of one or more notions.
The list begins and ends with a notion.
The replicator `\*{*\*}' indicates that the list consists of zero or more notions.
.PP
An optional syntactic notion is indicated by
enclosing it in square brackets, e.g. `$[~notion~]$'.
The terminal symbols of the grammar are represented either
by their constituent characters enclosed in single
quotes (for example: \*{','\*} or \*{':='\*}) or by upper case letters
if the terminal symbol consists solely of lower case letters
(for example:
both `\*{IF\*}' and `\*{'if'\*}' may be used to denote
the terminal symbol `\*{if\*}\|').
Single quote characters that occur in a terminal symbol are duplicated.
Where necessary, parentheses are used for grouping.
.PP
A description of this formalism in its own notation is:
.sp 1
.<<
<grammar>          ::=  <rule>+ .
.sp 0.5
<rule>             ::=  <rule-name> '::=' <rule-body> '.' .
.sp 0.5
<rule-body>        ::=  {<primary>* '|' }+ .
.sp 0.5
<primary>          ::=  (  <terminal-symbol> | <rule-name> |
                           <option> | <list> | <compound>
                        )  [ '+' | '*' ] .
.sp 0.5
<option>           ::=  '[' <rule-body> ']' .
.sp 0.5
<list>             ::=  '{' <primary> <terminal-symbol> '}' ( '+' | '*') .
.sp 0.5
<compound>         ::=  '(' <rule-body> ')' .
.sp 0.5
<terminal-symbol>  ::=  <upper-case-letter>+ |
                        '''' <arbitrary-ascii-character>+ '''' .
.sp 0.5
<rule-name>        ::=  '<' (<lower-case-letter> | '-')+ '>'.
.>>
.sp 1
.PP
The syntactic notions \*<upper-case-letter\*>,
\*<lower-case-letter\*> and \*<arbitrary-ascii-character\*> are not further
defined here, but have an obvious meaning.
.PP
In the description of the semantics an extended version of this syntax notation
is used;
this is further explained in section #{Evaluation process}.
.SH #{Lexical considerations=sn+}. "Lexical considerations"
.PP
The ASCII character set is used as the basic character set of the language.
.PP
.iy I "lexical units"
The lexical units of a program are:
\*<delimiter\*>,
\*<identifier\*>
.iy I <identifier>
(including keywords, see below),
\*<integer-constant\*>,
.iy I <integer-constant> ,
\*<real-constant\*>,
.iy I <real-constant> ,
\*<string-constant\*>
.iy I <string-constant>
and
\*<operator-symbol\*>.
.iy I <operator-symbol> .
Lexical units may be separated by zero or more \fBlayout symbols\fP:
.iy I "layout symbols"
space (SP), horizontal tab (HT), newline (NL) or
.ix I comment .
.iy I "comment symbol"
A comment consists of a comment symbol (`\*#'), zero or more arbitrary
characters except the comment symbol, followed by a comment symbol.
At least one layout symbol is required between adjacent
\*<identifier\*>s, \*<integer-constant\*>s and \*<real-constant\*>s.
Except where a layout symbol occurs inside a \*<string-constant\*> or
is required as separator,
it may be removed from a program without changing the semantics of the program.
.PP
A \*<delimiter\*> is used as separator in lists of language constructs or
to enclose (lists of\|) language constructs.
The following
\*<delimiter\*>s
.iy I <delimiter> s
are defined:
.br
.DS L
.<<
.so lex/delim
.>>
.DE
.LP
An \*<identifier\*>
.iy I <identifier> s
is used as a name and has the form:
.DS L
.<<
.so lex/id
.>>
.DE
The \*<identifier\*>s listed below are
\fBkeywords\fP
.iy I keywords
and have a special significance in the language;
they can not be redeclared by the programmer:
.DS
.ta 8m 16m 24m 32m
array	else	monadic	subclass
assert	end	od	subject
begin	esac	of	succeeds
case	fails	op	table
class	fetch	proc	then
code	fi	program	try
const	for	return	undefined
default	freturn	rof	until
do	if	scan	var
dyadic	in	self	while
elif	init	store	yrt
.DE
.LP
An \*<integer-constant\*>
.iy I <integer-constant> s
is used to denote an instance of the class
\fBinteger\fP
.iy I integer
{#{Lib/integer}} and has the form:
.DS L
.<<
.so lex/integer-const
.>>
.DE
.LP
A \*<real-constant\*>
.iy I <real-constant> s
is used to denote an instance of the class
\fBreal\fP
.iy I real
{#{Lib/real}} and has the form:
.DS L
.<<
.so lex/real-const
.sp 0.5
.so lex/real-exponent
.>>
.DE
.LP
A \*<string-constant\*>
.iy I <string-constant> s
is used to denote an instance of the class \fBstring\fP
{#{Lib/string}}
.iy I string
and has the form:
.sp 1
.<<
.so lex/string-const
.>>
.sp 1
A \*<string-constant\*> consists of zero or more characters from a limited set
(i.e. all ASCII characters
except the characters: single quote (`\*''), backslash (`\*{\\*}') and newline (NL))
enclosed in single quote characters.
.iy I "single quote character"
The single quote character itself can be obtained by writing two
adjacent single quote characters.
There are two ways to associate a printable representation
with non-printable characters.
.iy I "non-printable characters"
The escape sequences `\*{\b\*}', `\*{\n\*}', `\*{\t\*}\|' and `\*{\\\*}'
.iy I "escape sequence"
are used to denote respectively
the characters backspace (BS), newline (NL), horizontal tab (HT) and
backslash (`\*{\\*}').
Arbitrary non-printable characters can be denoted by `\*{\abc\*}',
where `\*{abc\*}'
is the three-digit octal representation of the desired character in
the ASCII character set.
.LP
An \*<operator-symbol\*>
.iy I <operator-symbol> s
is used to denote a built-in or user-defined
\fBoperator\fP
{#{Procedure and operator declarations}} and must adhere to:
.sp 1
.<<
.so lex/op-sym
.>>
.sp 1
The recognition of \*<operator-symbol\*>s is described in
#{Operator symbol declarations}.
.SH #{Semantic considerations=sn+}. "Semantic considerations"
.SH #{Description method=sn>1}. "Description method"
.PP
An \fBevaluation process\fP
.iy I "evaluation process"
or \fBinterpreter\fP
(with the name `\*{eval\*}\|') will be defined
that takes an arbitrary, but syntactically correct, source text (`the source program')
as input and either computes the result of the execution of that program
(if it is a legal \s-2SUMMER\s0 program),
or detects a semantic error, or does not terminate.
In the latter two cases no meaning is attached to the program.
The evaluation process operates directly on the text of the source program.
During this process a global \fBenvironment\fP
.iy I environment
is inspected or updated.
An environment is a mapping from identifiers in the source program
to their actual values during the evaluation process.
In this way environments determine the meaning of names in the source program and
are used to describe concepts such as variables, assignment
and scope rules.
.PP
A fundamental question arises here:
in which language do we write the definition?
Several choices can be made, such as the formalism used in
.ix I "denotational semantics"
([Gordon79], which boils down to a mathematical notation for recursive functions
and domains)
or the
.ix I "Vienna Definition Language"
([Wegner72], which is a programming language designed for the manipulation of trees).
The merits of these formalisms will not be discussed here, but
they have one disadvantage in common:
yet another language and yet another notation have to be introduced.
Since this conflicts with our aim of providing a concise, precise and readable
definition, it was decided to describe the semantics of \s-2SUMMER\s0 in
a subset of \s-2SUMMER\s0 itself.
This choice has the obvious disadvantage that the definition is \fBcircular\fP,
i.e. language and metalanguage coincide.
It will become clear later that we make a meticulous distinction
between notions in the definition language (e.g. `\*{1\*}', an integer
as used in the formal definition) and notions in
the defined language (e.g. `\*{a_integer(1)\*}', an expression in the definition
language that describes the integer `1' as it may occur in a program in
the defined language).
At first sight, the reader may find parts of the formal definition
needlessly complicated and perhaps even confusing.
In many cases, this apparent complexity is due to our making a careful distinction
between the two language levels involved in the definition.
.PP
The choice of \s-2SUMMER\s0 as definition language
has the practical advantage that readers who have only
a moderate familiarity with the language will be able to read the definition
without great difficulty.
It should be noted that there is no \fBfundamental\fP
reason for making the definition circular.
The definition method used here would also work if, for example,
\s-2ALGOL\s068 were used as definition language.
In any case, it is essential that the definition language has powerful
string operations and allows the creation of data structures of
dynamically varying size.
This requirement makes, for example, \s-2PASCAL\s0 less suited as definition language.
Choosing \s-2SUMMER\s0 as definition language gives us the opportunity to investigate
the suitability of that language in the area of language definition
(see Chapter #{FORMAL LANGUAGE DEFINITIONS}).
[Reynolds72] contains an extensive discussion of circular language
definitions.
.PP
A final remark should be made regarding the \fBoperational\fP
aspects of the definition method.
As explained above, the meaning of each source program $S$ is defined
by the result of `executing' the interpreter \*{eval\*}
with $S$ as input.
However, the parts of $S$ that are not visited during this execution
are not checked for their semantic correctness.
Thus there is no guarantee that $S$ is free of semantic errors.
.PP
The following sections describe
some aspects of the use of \s-2SUMMER\s0 as a metalanguage,
the semantic domains used by the
evaluation process, and the evaluation process itself.
.SH #{SUMMER as metalanguage=sn+}. "S\s-2UMMER\s0 as a metalanguage"
.iy I metalanguage
.PP
This paragraph focuses on some aspects of \s-2SUMMER\s0 that are used in
the formal definition, but have not yet been covered in Chapter #{SUMMER OVERVIEW}.
Most of the constructs to be used in the definition have some similarity to constructs in, for instance,
\s-2PASCAL\s0 and are assumed to be self-explanatory.
Only less obvious constructs that are essential for the understanding of
the definition are mentioned here.
.PP
S\s-2UMMER\s0 is an object-oriented language with pointer semantics.
This means that an object can be modified by assignment and that
such modifications are visible through all access paths to that object.
For example,
.DS
.{{
s := stack(10);
t := s;
.}}
.DE
assigns one and the same \*{stack\*} object to
the variables \*{s\*} and \*{t\*}, and
.DS
.{{
s.push(v)
.}}
.DE
pushes the value of \*{v\*} onto this stack.
As a side-effect, the stack is modified in such a way that subsequent operations on
\*{s\*} and \*{t\*} can perceive the effect of that modification.
In the formal definition this is relevant to the concepts `state'
and `environment', which are modified in this way.
.PP
The language is dynamically typed, i.e. the type of variables is not fixed
statically (as in \s-2PASCAL\s0 and \s-2ALGOL\s060) but is only determined during the execution of
the program (as in \s-2LISP\s0 and \s-2SNOBOL\s04).
Moreover, generic operations on data structures are allowed.
If an operation is defined on several data types, then the
procedure to be executed when that operation is encountered is determined
by the type of the (left) operand of that operation.
.PP
Control structures and data structures are self-explanatory
except possibly for \fBarrays\fP and \fBfor-expressions\fP.
.PP
Arrays are vectors of values,
indexed by $0 ~,..., ~N-1$,
where $N$ is the number of elements in the array.
If $A$ is an array then the operation $A.size$ will yield the number
of elements in the array.
A new array is created by
.DS
$[V sub 0 ~,..., ~V sub N-1 ]$
.DE
or
.DS
$array(N,~V)$ .
.DE
In the former case, an array of size $N$ is created and initialized to the
values $V sub 0 ~,..., ~V sub N-1$.
In the latter case, an array of size $N$ is created and all elements are
initialized to the value $V$.
Arrays are also allowed on the left-hand side of assignments.
This provides a convenient notation for multiple assignments.
For example,
.DS
\*{x := 10; y := 20; z := 30;\*}
.DE
is equivalent to
.DS
\*{[x, y, z] := [10, 20, 30]\*}
.DE
and, more generally,
.DS
\*{x\*}$"" sub 0$\*{ := a[0];  ...  ; x\*}$"" sub k$\*{ := a[k];\*}
.DE
is equivalent to
.DS
$[x sub 0 ~,..., ~x sub k ]~:=~a$
.DE
The general form of a for-expressions is:
.DS
.{{
for V in G do S od
.}}
.DE
where $V$ is a variable,
$G$ an expression
capable of generating a sequence of values $VAL sub i$ and where $S$ is an
arbitrary statement.
For each iteration the assignment $V:=VAL sub i$ is performed
and $S$ is evaluated.
As used in the formal definition,
the value of $G$ is either an array
(in which case consecutive array elements are generated) or
$G$ is an array on which the operation \*{index\*} is performed
(in which case all indices of consecutive array elements are generated).
For example, in
.DS
.{{
a := [144, 13, 7];
for x in a do print(x) od
.}}
.DE
an array object is assigned to the variable \*{a\*} and
the values 144, 13, 7 will be printed, while
.DS
.{{
for i in a.index do print(i) od
.}}
.DE
will print the values 0, 1, 2.
Further examples of for-expressions can be found in the
following paragraphs.
.SH #{Semantic domains=sn+}. "Semantic domains"
.PP
A
.ix I "semantic domain"
is a set,
whose elements either describe a primitive notion in the defined language
(like `variable' or `procedure declaration')
or have some common properties
as far as the evaluation process is concerned.
First, the relationship between these domains is given by a series of
\fBdomain equations\fP.
Next, we give an operational definition of each domain by specifying its
abstract properties.
.PP
The relationship between the domains
$BASIC$-$INSTANCE$, $COMPOSITE$-$INSTANCE$, $INSTANCE$,
$STORABLE$-$VALUE$, $DENOTABLE$-$VALUE$, $PROCEDURE$, $CLASS$,
$LOCATION$, $STATE$ and $ENVIRONMENT$ is as follows:
.DS L
.ta \w'$COMPOSITE$-$INSTANCE$ 'u
$BASIC$-$INSTANCE$	= $INTEGER~\(cu~STRING~\(cu~UNDEFINED$
$COMPOSITE$-$INSTANCE$	= $CLASS~\(mu~ENVIRONMENT$
$INSTANCE$	= $BASIC$-$INSTANCE~\(cu~COMPOSITE$-$INSTANCE$
$STORABLE$-$VALUE$	= $INSTANCE$
$DENOTABLE$-$VALUE$	= $STORABLE$-$VALUE~\(cu~PROCEDURE~\(cu$
	\h'\w'= 'u'$CLASS~\(cu~LOCATION$
$PROCEDURE$	= $PROCEDURE$-$DECLARATION~\(mu$
	\h'\w'= 'u'$ENVIRONMENT$
$CLASS$	= $IDENTIFIER~\(mu~CLASS$-$DECLARATION$
$STATE$	= $LOCATION~\(->~(STORABLE$-$VALUE~\(cu~"{"unused"}")$
$ENVIRONMENT$	= $IDENTIFIER~\(->~DENOTABLE$-$VALUE$
.DE
.PP
Here, $IDENTIFIER$, $PROCEDURE$-$DECLARATION$
and $CLASS$-$DECLARATION$ are the sets of
strings that can be derived from the syntactic notions
\*<identifier\*>,
.iy I <identifier> ,
\*<procedure-declaration\*>
.iy I <procedure-declaration>
and
\*<class-declaration\*>
.iy I <class-declaration>
in the \s-2SUMMER\s0 grammar.
All values in \s-2SUMMER\s0 are an instance of some class.
The domain $INSTANCE$ describes all those values.
$BASIC$-$INSTANCE$ is the domain of
.iy I "basic values ($BASIC$-$INSTANCE$)"
the primitive values in the language.
$COMPOSITE$-$INSTANCE$ is the domain of user-defined values.
$STORABLE$-$VALUE$ is the domain of
.iy I "$STORABLE$-$VALUE$"
values which can be assigned to variables in the source program.
$DENOTABLE$-$VALUE$ is the domain of
.iy I "$DENOTABLE$-$VALUE$"
values which can be manipulated by the evaluation process.
The domains $PROCEDURE$ and $CLASS$ describe declarations for procedures and classes.
The domain $LOCATION$ is used
.iy I "$LOCATION$"
to model the notion `address of a cell capable of containing a (single) value'.
.iy I "state ($STATE$)"
$STATE$ is the domain of functions which map locations onto
actual values or \*{unused\*}.
$ENVIRONMENT$ is the domain of functions which map names onto denotable values.
These semantic domains will now be described in more detail.
.PP
The domain $BASIC$-$INSTANCE$ describes the instances of basic, built-in classes
in the defined language;
it can be subdivided into three parts:
the subdomains $INTEGER$, $STRING$ and $UNDEFINED$,
which are now described in turn.
.PP
.ix I $INTEGER$
is the domain of the built-in class integer.
The following operations are defined on it:
.RS
.IP "$a\*_integer(intval)$, "
.iy I $a\*_integer$
with $intval$ an integer value of the definition language,
creates a new element of $INTEGER$.
.IP "$i.intval$, "
.iy I $intval$
with $i~\*(el~INTEGER$, gives the value of the integer part of $i$.
Note that for all integers $n$ the equality
$a\*_integer(n).intval ~=~ n$ holds.
.IP "$is\*_integer(i)$, "
.iy I $is\*_integer$
with $i~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $i~\*(el~INTEGER$.
{More precisely, $is\*_integer$ is a function from $DENOTABLE$-$VALUE$
to \*{{succeeds, fails}\*}.
Here, \*{succeeds\*} denotes successful expression evaluation (as used in \s-2SUMMER\s0)
and may be interpreted as `\*{true\*}';
\*{fails\*} denotes evaluation of a failing expression and may
be interpreted as `\*{false\*}'.}
.IP "$i.has(oper)$, "
.iy I $has$
with $i~\*(el~INTEGER$ and $oper$ a string,
succeeds if \*{oper\*} is an operation defined for $INTEGER$ values,
and is false otherwise.
.IP "$i.operation(oper,~actuals)$, "
.iy I $operation$
with $i~\*(el~INTEGER$, $oper$ a string and actuals an array of $STORABLE$-$VALUE$s,
performs the operation with the name \*{oper\*} on $INTEGER$ value \*{i\*} with \*{actuals\*} as
actual parameter list, and delivers a $STORABLE$-$VALUE$ as result.
The list of operations defined on integers and the semantics of these
operations are described in #{Lib/integer}.
.RE
.PP
.ix I $STRING$
is the domain of the built-in class string.
The following operations are defined on it:
.RS
.IP "$a\*_string(stringval)$, "
.iy I $a\*_string$
with $stringval$ a string,
creates a new element of $STRING$ consisting of the characters
in $stringval$.
.IP "$s.stringval$, "
.iy I "$stringval$"
with $s~\*(el~STRING$, gives the value of the string part of $s$.
Note that for all strings $t$ the equality $a\*_string(t).stringval~=~t$ holds.
.IP "$is\*_string(s)$, "
.iy I $is\*_string$
with $s~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $s~\*(el~STRING$.
.IP "$s.has(oper)$, "
.iy "$has$"
with $s~\*(el~STRING$ and $oper$ a string,
succeeds if an operation with the name equal to the string value of \*{oper\*} is
defined for values in $STRING$ and is false otherwise.
.IP "$s.operation(oper,~actuals)$, "
.iy I "$operation$"
with $s~\*(el~STRING$, $oper$ a string and $actuals$ an array
of $STORABLE$-$VALUE$s,
performs the operation with name \*{oper\*} on the $STRING$ value \*{s\*} with \*{actuals\*}
as list of actual parameters, and delivers a $STORABLE$-$VALUE$ as result.
The list of operations defined on strings and the semantics of these operations are described in #{Lib/string}.
.RE
.PP
.ix I $UNDEFINED$
is the domain consisting of undefined values.
Undefined values can only be used in a few situations;
they may be used in assignments,
tests for equality or inequality, or they may be used as actual parameters.
All variables are initialized to an undefined value;
in that way undefined values serve to detect errors due to
the use of otherwise uninitialized variables.
The following operations are defined on it:
.RS
.IP "$a\*_undefined$ "
.iy I $a\*_undefined$
creates a new $UNDEFINED$ value.
.IP "$is\*_undefined(u)$, "
.iy I $is\*_undefined$
with $u~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $u~\*(el~UNDEFINED$.
.IP "$u.has(oper)$, "
.iy I $has$
with $u~\*(el~UNDEFINED$ and $oper$ a string,
is always false.
.IP "$u.operation(oper,~actuals)$, "
.iy I $operation$
with $u~\*(el~UNDEFINED$, $oper$ a string
and $actuals$ an array of $STORABLE$-$VALUE$s,
always results in a semantic error.
.RE
.PP
.ix I $COMPOSITE$-$INSTANCE$
is the domain of instances of user-defined classes.
A composite-instance consists of an element of $CLASS$ (to be defined below)
that describes the class to which the instance belongs and an environment
that has to be used to inspect or update components in the instance.
The following operations are defined:
.RS
.IP "$a\*_composite\*_instance(c,~e)$, "
.iy I $a\*_composite\*_instance$
with $c~\*(el~CLASS$ and $e~\*(el~ENVIRONMENT$,
creates a new element $i~\*(el~COMPOSITE$-$INSTANCE$,
such that $i.class\*_decl~=~c$ and $i.env~=~e$.
.IP "$is\*_composite\*_instance(i)$, "
.iy I $is\*_composite\*_instance$
with $i~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $i~\*(el~COMPOSITE$-$INSTANCE$.
.IP "$i.class\*_decl$ and $i.env$, "
.iy I "$class\*_decl$"
.iy I "$env$"
with $i~\*(el~COMPOSITE$-$INSTANCE$,
give the values of the
class declaration and environment part of $i$.
.IP "$i.same\*_as(j)$, "
.iy I "$same\*_as$"
with $i,~j~\*(el~COMPOSITE$-$INSTANCE$, succeeds if and only if $i$ and $j$ are the same
element of $COMPOSITE$-$INSTANCE$,
i.e. they are the result of the same invocation of $a\*_composite\*_instance$.
.RE
.PP
$INSTANCE$ is the domain of values that may occur during the evaluation of a
program.
It simply consists of the union of the domains $BASIC$-$INSTANCE$ and
$COMPOSITE$-$INSTANCE$.
For convenience, the following operations will be used:
.RS
.IP "$is\*_instance(i)$, "
with $i~\*(el~DENOTABLE$-$VALUE$, succeeds if and only if $i~\*(el~INSTANCE$.
.IP "$is\*_basic\*_instance(i),$ "
with $i~\*(el~DENOTABLE$-$VALUE$, succeeds if and only if $i~\*(el~INTEGER$, or
$i~\*(el~STRING$ or $i~\*(el~UNDEFINED$.
.RE
.PP
$STORABLE$-$VALUE$ is the domain of all values that may be assigned to
variables in a program.
It is identical to the domain $INSTANCE$; this stresses the fact that all
values that can be created by a program can also be assigned to a variable.
.PP
$DENOTABLE$-$VALUE$ is the domain of values that can be manipulated by
the evaluation process itself.
It consists of the union of the domain $STORABLE$-$VALUE$
(described above) and the domains $PROCEDURE$,
$CLASS$ and $LOCATION$, which are now described in turn.
.PP
.ix I $PROCEDURE$
is the domain of procedures.
Each element of this domain describes one procedure declaration and
contains a literal copy of the text of the procedure declaration itself
and an environment that reflects all names and values available at the
point of declaration.
The following operations are defined:
.RS
.IP "$a\*_proc(procdecl,~e)$, "
.iy I "$a\*_proc$"
with $procdecl~\*(el~PROCEDURE$-$DECLARATION$ and $e~\*(el~ENVIRONMENT$,
creates a new element $p~\*(el~PROCEDURE$,
such that $p.text~=~procdecl$ and $p.env~=~e$.
.IP "$is\*_proc(p)$, "
.iy I "$is\*_proc$"
with $p~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $p~\*(el~PROCEDURE$.
.IP "$p.text$ and $p.env$ "
give the value of the text and environment part of $p$.
.RE
.PP
.ix I $CLASS$
is the domain of classes.
Each element of this domain describes one class declaration and contains
the name of the class and a literal copy of the text of the
class declaration.
The following operations are defined on it:
.RS
.IP "$a\*_class(id,~classdecl)$, "
.iy I $a\*_class$
with $id~\*(el~IDENTIFIER$ and $classdecl~\*(el~CLASS$-$DECLARATION$,
creates a new element $c~\*(el~CLASS$,
such that $c.name~=~id$ and $c.text~=~classdecl$.
{Note that, strictly speaking, the class name is already contained in
the literal text of its declaration. For convenience, i.e. to easily
describe the \*{type\*} function {#{Identifiers and procedure calls},#{Lib/type}},
an additional \*{name\*} component is used.}
.IP "$is\*_class(c)$, "
.iy I $is\*_class$
with $c~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $c~\*(el~CLASS$.
.IP "$c.name$ and $c.text$ "
give the value of the name and declaration text part of $c$.
.RE
.LP
{An aside on the asymmetric treatment of procedures and classes
is appropriate here.
A \*<class-declaration\*> can only appear at the most `global' level, i.e.
immediately contained in a \*<summer-program\*>.
A \*<procedure-declaration\*>, however, may appear either at this most global
level or may be contained in a \*<class-declaration\*>.
This implies that for \*<procedure-declaration\*>s the declaring environments
must be distinguished, while for \*<class-declaration\*>s always the
most global environment must be used.}
.PP
The following operations are defined on $LOCATION$s and $STATE$s:
.RS
.IP "$s.extend(v)$, "
.iy I "\fIextend\fP (state)"
with $s~\*(el~STATE$ and $v~\*(el~STORABLE$-$VALUE$s,
associates an unused location $l$ with $v$,
i.e. location $l$, originally associated with the value \*{unused\*},
is associated with value $v$ (until later modification occurs).
Location $l$ is returned as value.
.IP "$s.contents(l)$, "
.iy I "$contents$"
with $s~\*(el~STATE$ and $l~\*(el~LOCATION$,
returns the value $v~\*(el~STORABLE$-$VALUE$ associated with location $l$.
Location $l$ should not be associated with \*{unused\*}.
.IP "$s.modify(l,~v)$, "
.iy I "modify (a location)"
with $s~\*(el~STATE$, $l~\*(el~LOCATION$ and $v~\*(el~STORABLE$-$VALUE$,
changes the value associated with location $l$ to the value $v$.
Location $l$ should not be associated with $unused$.
Location $l$ is returned as value of this operation.
.IP "$is\*_loc(l)$, "
.iy I "$is\*_loc$"
with $l~\*(el~DENOTABLE$-$VALUE$,
succeeds if and only if $l~\*(el~LOCATION$.
.RE
.LP
Inspection of the contents of a location does not
affect either its own contents or that of any other location.
Modification of the contents of a location does not affect the contents of
any other location.
Note that the above operations respect the following rules:
.DS
$is\*_loc(s.extend(v))$
.br
$s.contents(s.extend(v))~\(==~v$
.br
$s.contents(s.modify(l,~v))~\(==~v$
.DE
.PP
.ix I $ENVIRONMENT$
is the domain of environments.
.iy I environment
Environments administer the binding between names and values and the
introduction of new scopes, i.e. ranges in the program where
new names may be declared {#{Declarations}}.
Unless stated otherwise, the following operations modify the environment
to which they are applied:
.RS
.IP "$e.bind(n,v)$, "
.iy I $bind$
with $e~\*(el~ENVIRONMENT$, $n~\*(el~IDENTIFIER$
and $v~\*(el~DENOTABLE$-$VALUE$,
binds name $n$ to value $v$.
This operation results in a semantic error if the name $n$ is redeclared, i.e.
a $bind$ operation has already been performed for name $n$, without intervening
$new\*_inner\*_scope$ or $new\*_proc\*_scope$ operation.
.IP "$e.binding(n)$, "
.iy I $binding$
with $e~\*(el~ENVIRONMENT$ and $n~\*(el~IDENTIFIER$,
gives the value previously bound to name $n$.
A semantic error occurs if $n$ has no binding.
.IP "$e.has\*_binding(n)$, "
.iy I $has\*_binding$
with $e~\*(el~ENVIRONMENT$ and $n~\*(el~IDENTIFIER$,
succeeds if and only if name $n$ has been bound to a value.
.IP "$e.names$, "
.iy I $names$
with $e~\*(el~ENVIRONMENT$, returns an array of strings which represent
all identifiers
for which a \*{bind\*} operation has been performed in the environment $e$.
Note that $n~\*(el~e.names~\(==~e.has\*_binding(n)$ holds.
.IP "$e.new\*_inner\*_scope$, "
.iy I $new\*_inner\*_scope$
with $e~\*(el~ENVIRONMENT$, marks the start of a new inner scope.
This operation is used to delimit scopes in order to allow redeclarations of
variables.
The reverse operation (`$previous\*_inner\*_scope$') is not
needed, since environments are always copied before a new scope is entered.
.IP "$e.new\*_proc\*_scope$, "
.iy I $new\*_proc\*_scope$
with $e~\*(el~ENVIRONMENT$,
marks the start of a new inner scope that coincides with a procedure boundary.
This operation is needed to distinguish the local variables
of the `current' procedure
from all other variables in the program.
This distinction is necessary for proper environment restoration in
try expressions (see below).
.IP "$e.name\*_copy$, "
.iy I $name\*_copy$
with $e~\*(el~ENVIRONMENT$,
creates a copy of environment \*{e\*}.
If one looks at environments as sequences of name-value pairs, then this
operation creates a new sequence consisting of precisely the
same name-value pairs,
with names identical to the names in the original,
and with value-parts that refer to the same values.
This has the effect that modifications made to values referred to by
value-parts in the original and in the copied environment,
are visible in both environments.
However, bindings added to one of the environments will not be part of the other.
.IP "$e.partial\*_state\*_copy$, "
.iy I $partial\*_state\*_copy$
with $e~\*(el~ENVIRONMENT$, creates a copy of environment \*{e\*} in the same manner as
described for $name\*_copy$,
except that, under certain circumstances, the value referred to
by a value-part is \fBcopied\fP.
The latter is applicable to the pairs that satisfy the following
two requirements:
.RS
.IP 1)
The value-part refers to a location (say, $l$).
.IP 2)
The binding between the name-part (say, $n$) and the value-part
occurred \fBbefore\fP the last $new\*_proc\*_scope$ operation.
.RE
.sp 0.5
For each such pair, $n$ is bound to a new location $l'$
with contents $v'$,
where $v'$ is a copy of $v$ if $v~\*(el~COMPOSITE$-$INSTANCE$,
and $v'$ is the same as $v$ if $v~\*(el~BASIC$-$INSTANCE$.
The local variables of the current procedure are distinguished by
\*{partial_state_copy\*}.
This is necessary for a proper treatment of \*<try-expression\*>s
{#{Try expressions}}.
.RE
.SH #{Evaluation process=sn+}. "Evaluation process"
.PP
The
.ix I "evaluation process"
is described in \s-2SUMMER\s0 extended with \fBparse expressions\fP$"" sup 1$
.iy I "parse expression"
.FS
1) There is no \fBfundamental\fP
reason for introducing this rather \fIad hoc\fP language extension.
However, the disadvantage of introducing it
is more than compensated by the fact that it is
sufficiently similar to BNF notation to be almost self-explanatory.
The effect of introducing a language extension as proposed here
is interesting in its own right but this falls outside the scope of the
current discussion.
.FE
of the form
.sp 0.5
.D{
\&\*{'{{' <identifier>\*} \*`\*{==\*}\*' \*{<tagged-rule-body> '}}'\*}
.D}
.sp 0.5
which provide a concise notation for parsing and extracting
information from the text of the source program.
The precise definition of a \*<tagged-rule-body\*> is as follows:
.DS L
.<<
<tagged-rule-body> ::= ( [ <tag> ':' ] <primary> )* .
.sp 1
<tag> ::= <lower-case-letter> (<lower-case-letter> | <digit>)* .
.>>
.DE
These syntax rules extend the syntax notation given in Section
#{Syntactical considerations}.
.PP
A parse expression succeeds if the identifier on the
left-hand-side of the `\*{==\*}' sign has
a string as value and if this string has the form described by the
\*<tagged-rule-body\*> on the right of the `\*{==\*}' sign.
All \*<tag\*>s occurring in the \*<tagged-rule-body\*> should have been declared as
variables in the program containing the parse expression,
in this case the evaluation process.
Substrings of the parsed text recognized by the syntactic categories
on the right-hand-side of a `:' symbol are assigned to
the variable that occurs on its left-hand-side.
Consider, for example, the following program fragment:
.sp 0.5
.D{
.{{
if {{ e == WHILE t:<test> DO b:<body> OD }}
then
   put('While expression recognized')
fi
.}}
.D}
.sp 0.5
The parse expression will succeed if \*{e\*} has the form of a `while expression'.
The literal text of the
\*<test\*>
is then assigned to variable \*{t\*}
and the text of the \*<body\*> is assigned to variable \*{b\*}.
.PP
If the recognized part of the text is a list or repetition,
an array of string values is assigned to the variable.
In the case of a list of notions separated by separators, the latter are
omitted and only the notions occurring in the list are assigned to
(consecutive) elements in the array.
This is exemplified by:
.sp 0.5
.D{
.{{
if {{ e == VAR list:{<identifier> ','}+ }}
then
   put('Variable declaration contains:');
   for id in list do put(id) od
fi  .
.}}
.D}
.sp 0.5
The parse expression succeeds if \*{e\*} has the form of a `variable declaration'
(i.e. the keyword `\*{var\*}' followed by a list of \*<identifier\*>s
separated by commas)
and in that case
an array of string values corresponding to the \*<identifier\*>s occurring in
the declaration is assigned to the variable \*{list\*},
which is subsequently printed.
.KF
.sp 2
.D{
.{{
var ENV;
var ENVglobal;
var STATE;
var varinit;
proc ERROR ... ;
     # Immediately aborts the evaluation process #
proc eval_call(procname, actuals) ... ;
     # Evaluates procedure calls; this includes the #
     # creation of new class instances. #
proc eval_field_selection(access_type, object, field, actuals) ... ;
     # Evaluates a field selection. #
proc has_field(access_type, object, field) ... ;
     # Utility procedure to determine whether a given #
     # field selection can be performed. #
proc expand_super_class(c) ... ;
     # Utility procedure used for class declarations. #
proc eval_array_init(sz, def, initexpr) ... ;
     # Evaluates array initializations. #
proc eval_table_init(sz, def, initexpr) ... ;
     # Evaluates table initializations. #
proc eval(e)
( var v, sig, ... ;

  if {{ e == <summer-program> }}
  then
     ...
     return([v, sig])
  fi;
  if {{ e == <variable-declaration> }}
  then
     ...
     return([v, sig])
  fi;
  ...
  if {{ e == <empty> }}
  then
     ...
     return([v, sig])
  fi;
);
.}}
.D}
.sp 1
.ce
\s-1\fBFigure #{Fig eval overview=figs+}\fP. General organization of evaluation process.\s0
.sp 2
.XP 1
.KE
.PP
Parse expressions may be used in \*{if\*}-expressions or may stand on their own.
In the latter case, the string to be parsed \fBhas\fP to be of the form
described by the parse expression.
In this way, parse expressions can be used to decompose a string
with a known form into substrings.
.PP
Now we turn our attention to the
.ix I "evaluation process" .
Its overall structure is given in Figure #{Fig eval overview}.
Five utility procedures ($require\*_constant\*_expression$, $equal$,
$string\*_equal$, $substring$ and $dereference$) are not shown there.
.PP
The variables \*{ENV\*} and \*{ENVglobal\*} have as respective values the current
environment and the environment at the moment that all global
declarations have been evaluated.
The variable $STATE$ has the current state as value.
The variable
.ix I $varinit$
has as value a string consisting of the
text of all
\*<variable-initialization\*>s
.iy I <variable-initialization> s
in the current
\*<block\*>.
.iy I <block> .
.PP
The main procedure is \*{eval\*}, which selects an appropriate case
depending on the syntactic form of its argument \*{e\*}.
The details of these various cases will be given in the next chapter.
The evaluation process is initiated by creating an initial empty
environment \*{ENV\*} and by calling \*{eval\*} with the text of the
source program as argument.
If the evaluation process is not terminated prematurely
(by the detection of a semantic error),
the result of the evaluation of the source program can be obtained
from the resulting environment \*{ENV\*}.
It is assumed that \*{eval\*} is initially called with a syntactically
correct \s-2SUMMER\s0 program, i.e. a string that has the form
of a \*<summer-program\*>.
.PP
The definition of \s-2SUMMER\s0 has been profoundly influenced by the
success-directed evaluation scheme in the language:
an expression can either \fBfail\fP or \fBsucceed\fP.
The meaning of failure is that evaluation of the `current' expression
is abandoned and that evaluation is continued at a point where
a `handler' (i.e. \*<if-expression\*>, \*<while-expression\*>)
occurs to deal with the failure case.
A similar situation exists for \*<return-expression\*>s, which terminate
the evaluation of a procedure call and thereby abandon the evaluation of
(possibly nested) expressions.
Both language features can thus influence the flow-of-control
in a program.
.PP
How are these properties of \s-2SUMMER\s0 reflected in the definition?
The procedure \*{eval\*} delivers as result an array
of the form \*{[value, signal]\*}, where \*{value\*} is the actual result of the
procedure and \*{signal\*} is a success/failure flag that indicates how \*{value\*}
should be interpreted.
The signal is used to describe the occurrence of
failure and/or \*<return-expression\*>s and may have the following values:
.IP \*{N\*}:
evaluation terminated normally.
.IP \*{F\*}:
evaluation failed.
.IP \*{NR\*}:
normal return; a
\*<return-expression\*>
.iy I <return-expression>
was encountered during evaluation.
.IP \*{FR\*}:
failure return; a failure return was encountered during evaluation.
.LP
The signal is tested after each (recursive) invocation of \*{eval\*}.
In most cases \*{eval\*} performs an immediate return if the signal is not equal
to \*{N\*} after the evaluation of a subexpression.
Exceptions to this rule are of two kinds:
.IP \*(MK
The semantics of certain constructs is such that the flow of control
is intentionally influenced by the success or failure of expressions
(e.g. \*<test\*>s in \*<if-expression\*>s).
This corresponds in \*{eval\*} to appropriate reactions
to \*{N\*} and \*{F\*} signals.
Aborting the evaluation of the `current'
expression, which is necessary if failure occurs in a deeply nested
subexpression, can be achieved by passing an \*{F\*} signal upwards until it
reaches an incarnation of \*{eval\*} that can take appropriate measures.
.IP \*(MK
The semantics of the \*<return-expression\*> is such that the execution
of the procedure in which it occurs is terminated and that execution
is to be continued at the place of invocation.
This is reflected by the signal values \*{FR\*} and \*{NR\*}, that are only
\fBgenerated\fP by \*<return-expression\*>s and are only \fBhandled\fP
by the semantic rules associated with procedure calls.
The latter rules turn \*{NR\*} into \*{N\*} and \*{FR\*} into \*{F\*} before
the evaluation process
is resumed at the point where it left off to perform the (by then completed)
procedure call.
All other semantic rules return immediately when an \*{NR\*}
or \*{FR\*} signal occurs.
.SH #{Unspecified=sn<+}. "Features not specified in the definition"
.PP
Chapters #{PRELIMINARIES}, #{SEMI FORMAL DEFINITION} and #{SUMMER LIBRARY}
form a nearly complete definition of the \s-2SUMMER\s0 programming language.
There are, however, a few language features that are left unspecified
in the formal definition.
These features are now briefly summarized.
.PP
Chapters #{PRELIMINARIES} and #{SEMI FORMAL DEFINITION}
define a \fBkernel\fP
of \s-2SUMMER\s0, i.e. a small subset of the language that allows a semantic
description of the whole language using only primitives in this kernel.
In chapter #{SUMMER LIBRARY} these primitives are used to define
more elaborate data types.
To reduce the size of the definition of the kernel, the availability
of three data types (classes) is assumed in the definition of the kernel
which are defined only informally in chapter #{SUMMER LIBRARY}.
These classes are:
\*{real\*} {#{Lib/real}},
\*{array\*} {#{Lib/array}} and
\*{table\*} {#{Lib/table}}.
.PP
The definition does not formally define the \fBpriorities of operators\fP.
It is assumed that all expressions are fully parenthesized in order
to establish the relative priorities of monadic and dyadic operators.
This is further discussed in Sections
#{Field selection},
#{Subscription},
#{Monadic expressions} and
#{Dyadic expressions}.
.PP
The \fBoperating system interface\fP
is not specified.
This is apparent in the way arguments are passed from
the operating system to \s-2SUMMER\s0 programs {#{Declarations}} and in the
way \s-2SUMMER\s0 programs communicate with the operating system
if certain operations on files have to be performed.
Except for opening and closing files, all file operations can be
modeled by means of string operations.
Only two additional semantic primitives (open and close file) would
then be needed to describe files completely.
For reasons of simplicity,
these two primitives have not been included in the current definition.
.SH #{sn+}. "References for chapter #{PRELIMINARIES}"
.so refs/Gordon79
.so refs/Liskov77
.so refs/Reynolds72
.so refs/Wegner72
#{sn<;}#{figs<;}
.EC
