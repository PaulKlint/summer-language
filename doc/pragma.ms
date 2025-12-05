#{figs+>;}
.NC #{FORMAL LANGUAGE DEFINITIONS=sn+} "FORMAL LANGUAGE DEFINITIONS" "CAN BE MADE PRACTICAL"
.ds LH "FORMAL LANGUAGE DEFINITIONS
.LP
.in +2.5i
 ` . . . \fIThe metalanguage of a formal definition must not become
a language known to only the priests of the cult.
Tempering science with magic is a sure way to return to
the Dark Ages\fP.' [Marcotty76]
.in
.ls
.SH #{FORMAL/problem=sn>1}. "The problem"
.PP
Programming languages are being designed using pre-scientific methods.
There is of course no substitute for experience, taste, style and intuition,
but a scientific design methodology to support them is lacking.
Methods for describing programming languages are somewhat more
developed, but most definitions are either
ambiguous and inaccurate, or excessively formal and unreadable.
In general, a language definition method should:
.IP \*(MK
help the language \fBdesigner\fP
by giving insight into the language he or she is designing, and by exposing
interactions that might exist between language features.
The definition should at the same time be
a pilot implementation of the defined language,
or it should at least be convertible into one.
It is assumed here, that design and definition can best be carried out
simultaneously.
.IP \*(MK
help the language \fBimplementor\fP
by providing him with an unambiguous and complete definition that is capable
of `executing' small programs in cases where the implementor is not sure
about all implications of a particular language feature.
.IP \*(MK
help the \fBuser\fP
by providing him with a precise definition in a language with which he
is not too \fBun\fPfamiliar.
.LP
These three goals impose different and to a certain extent contradictory
requirements on the definition method to be used.
In particular, it seems difficult to combine precision and readability
in one method, since a precise definition has to use some
formalism into which the reader has to be initiated and such a definition
will have a tendency to become long and unreadable.
This chapter is devoted to an experiment with a language definition method that 
may be considered as a tentative step towards satisfying the above requirements.
.PP
The \fBdefined\fP language is (of course) \s-2SUMMER\s0.
The definition method is similar in spirit to the \s-2SECD\s0 method [Landin64],
i.e. it is an operational language definition method which uses
recursive functions and syntactic recognition functions that 
associate semantic actions with all constructs in the grammar of the language.
In the method presented in this chapter,
readability has been considerably enhanced by using a few
imperative constructs and by introducing a very concise notation
for parsing and decomposing the source-text of programs in the defined language.
S\s-2UMMER\s0, extended with such parsing and decomposing operations, is used as
\fBdefinition language\fP.
The definition is thus circular (see Sections #{FORMAL/method/intro}
and #{FORMAL/assessment}).
.PP
A complete description of the definition method can be found in part II
of this monograph.
The next section gives only a birds-eye view of the description method
and shows some illustrative examples from the \s-2SUMMER\s0 definition.
In Section #{FORMAL/assessment} the method as a whole and its application to \s-2SUMMER\s0
are assessed.
.SH #{FORMAL/method=sn+}. "The method"
.SH #{FORMAL/method/intro=sn>1}. "Introduction"
.PP
An \fBevaluation process\fP or \fBinterpreter\fP (with the name `\*{eval\*}\|')
will be defined that takes an arbitrary, but syntactically correct,
source text (`the source program')
as input and either computes the result of the execution of that program
(if it is a legal program in the defined language),
or detects a semantic error, or does not terminate.
In the latter two cases, no meaning is attached to the program.
The evaluation process operates directly on the text of the source program.
During this process a global \fBenvironment\fP is inspected or updated.
An environment is a mapping from identifiers in the source program
to their actual values during the evaluation process.
In this way environments determine the meaning of names in the source program
and are used to describe concepts such as variables, assignment and scope rules.
.PP
A fundamental question arises here:
in which language do we write the definition?
Several choices can be made, such as the formalism used in
.ix I "denotational semantics"
([Gordon79], which boils down to a mathematical notation for recursive functions
and domains) or the
.ix I "Vienna Definition Language"
([Wegner72], which is a programming language designed for the manipulation of trees).
This is not the right place to discuss the merits of these formalisms, but
none has the desired combination of properties described in the
previous paragraph.
Instead of designing yet another definition language,
the defined language itself (this is \s-2SUMMER\s0 in the examples given in this chapter)
will be used as definition language.
This choice has the obvious disadvantage that the definition is
circular, but it has the practical advantage that readers who have only
a moderate familiarity with the defined language will be able
to read the definition without great difficulty.
An extensive discussion of circular language definitions can be found in [Reynolds72].
It should be emphasized that there is no \fBfundamental\fP
reason for making the definition circular.
The definition method described here would also work if, for instance,
\s-2ALGOL\s068 were used as definition language.
In any case, it is essential that the definition language has powerful
string operations and allows the creation of data structures
of dynamically determined size.
This requirement, for example, makes \s-2PASCAL\s0 less suited as definition language.
Choosing \s-2SUMMER\s0 as definition language gave us the opportunity of
investigating the suitability of that language in the area of
language definition (see Section #{FORMAL/assessment}).
.PP
In the following sections the definition method and an example
of its application (in the \s-2SUMMER\s0 definition) are described simultaneously.
In Section #{FORMAL/method/meta}
some aspects of the use of \s-2SUMMER\s0 as a metalanguage are discussed.
The definition method can be subdivided into the definition of
semantic domains (Section #{FORMAL/meta/domains})
and of the evaluation process (Section #{FORMAL/method/eval}).
Further detailed examples from the \s-2SUMMER\s0 definition are given
in Section #{FORMAL/examples}.
.SH #{FORMAL/method/meta=sn+}. "S\s-2UMMER\s0 as a metalanguage"
.PP
This paragraph focuses on some aspects of \s-2SUMMER\s0 that are used in
the formal definition, but were not covered in Chapter #{SUMMER OVERVIEW}.
Most of the constructs to be used in the definition
have some similarity with constructs in, for instance,
\s-2PASCAL\s0 and are assumed to be self-explanatory.
Only less obvious constructs that are essential to the understanding of
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
assigns one and the same \*{stack\*} object to the
variables \*{s\*} and \*{t\*}, and
.DS
.{{
s.push(v)
.}}
.DE
pushes the value of \*{v\*} onto this stack.
As a side-effect the stack is modified in such a way that subsequent operations
on \*{s\*} or \*{t\*} may perceive the effect of that modification.
In the formal definition this is relevant to the concepts `state'
and `environment', which are modified in this way.
.PP
The language is dynamically typed, i.e. the type of variables is not fixed
statically (as in \s-2PASCAL\s0) but is only determined during the execution of
the program (as in \s-2LISP\s0 or \s-2SNOBOL\s04).
Moreover, generic operations on data structures are allowed.
If an operation is defined on several data types, then the
procedure to be executed when that operation occurs is determined
by the type of the (left) operand of that operation.
.PP
Control structures and data structures are self-explanatory
except possibly \fBarrays\fP and \fBfor-expressions\fP.
.PP
Arrays are vectors of values,
indexed by $0 ~ ,..., ~ N-1$,
where $N$ is the number of elements in the array.
If \*{A\*} is an array then the operation \*{A.size\*} will yield the number
of elements in the array.
A new array is created by
.DS
$[V sub 0 ~ ,..., ~ V sub N-1 ]$
.DE
or
.DS
.{{
array(N, V)
.}}
.DE
In the former case, an array of size $N$ is created and initialized to the
values $V sub 0 ~ ,..., ~V sub N-1$.
In the latter case, an array of size $N$ is created and all elements are
initialized to the value $V$.
Array denotations are also allowed on the left-hand side of assignments.
This provides a convenient notation for multiple assignments.
For example,
.DS
.{{
x := 10; y := 20; z := 30
.}}
.DE
is equivalent to
.DS
.{{
[x, y, z] := [10, 20, 30]
.}}
.DE
and, more generally,
.DS
$x sub 0~:=~a[0];~ ... ~;~x sub k~:=~a[k]$
.DE
is equivalent to
.DS
$[x sub 0 ~ ,..., ~x sub k ]~:=~a$
.DE
The general form of a for-expression is:
.DS
.{{
for V in G do S od
.}}
.DE
where \*{V\*} is a variable, \*{G\*} is an expression
capable of generating a sequence of values $VAL sub i$ and where $S$ is an
arbitrary statement.
For each iteration the assignment $V:=VAL sub i$ is performed
and $S$ is evaluated.
As used in the formal definition, the value of $G$
is either an array
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
the values 144, 13 and 7 will be printed, while
.DS
.{{
for i in a.index do print(i) od
.}}
.DE
will print the values 0, 1 and 2.
Further examples of for-expressions will be found in the
following paragraphs.
.SH #{FORMAL/meta/domains=sn+}. "Semantic domains"
.PP
A
.ix I "semantic domain"
is a set, whose elements either describe a primitive notion
in the defined language (like `variable' or `procedure declaration')
or have some common properties as far as the language definition is concerned.
The relationship between these domains is given by a series of
domain equations.
.PP
In this paragraph the domains in the \s-2SUMMER\s0 definition are briefly described.
The abstract properties of these domains are given in part II.
Here, they are only introduced informally.
First, the domain equations are given.
Next, the meaning of each domain is described.
.PP
The relationship between the domains
$BASIC$-$INSTANCE$, $COMPOSITE$-$INSTANCE$, $INSTANCE$,
$STORABLE$-$VALUE$, $DENOTABLE$-$VALUE$, $PROCEDURE$, $CLASS$, $LOCATION$,
$STATE$ and $ENVIRONMENT$ is as follows:
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
Here, $IDENTIFIER$, $PROCEDURE$-$DECLARATION$ and
$CLASS$-$DECLARATION$ are the sets of string values that can
be derived from the syntactic notions
\*<identifier\*>,
.iy I <identifier> ,
\*<procedure-declaration\*>
.iy I <procedure-declaration>
and
\*<class-declaration\*>
.iy I <class-declaration>
in the \s-2SUMMER\s0 grammar.
$BASIC$-$INSTANCE$ is the domain of primitive values in the language.
$COMPOSITE$-$INSTANCE$ is the domain of user-defined values.
$STORABLE$-$VALUE$ is the domain of
values which can be assigned to variables in the source program.
$DENOTABLE$-$VALUE$ is the domain of
values which can be manipulated by the evaluation process.
The domains $PROCEDURE$ and $CLASS$ describe declarations for procedures
an classes respectively.
The domain $LOCATION$ is
used to model the notion `address of a cell capable of containing a (single) value'.
$STATE$ is the domain that consists of functions which map locations onto
actual values or `$unused$'.
$ENVIRONMENT$ is the domain of functions which map names onto denotable values.
.PP
$STRING$, $INTEGER$ and $UNDEFINED$ are the domains modeling
the values and operations for
the built-in types `string', `integer' and `undefined' respectively.
$UNDEFINED$ is the domain consisting of undefined values.
All variables are initialized to an undefined value.
Operations are defined on elements in $STRING$, $INTEGER$ and $UNDEFINED$
that model the primitive operations on the data types `string', `integer' and `undefined'.
.PP
.ix I $PROCEDURE$
is the domain of procedures.
Each element of this domain describes a procedure declaration and
contains a literal copy of the text of the procedure declaration itself
and an environment that reflects all names and values available at the
point of declaration.
.PP
.ix I $CLASS$
is the domain of classes.
Each element of this domain describes one class declaration and contains
the name of the class and a literal copy of the text of the
class declaration.
.ix I $COMPOSITE$-$INSTANCE$
is the domain of class instances.
All values that are created by a \s-2SUMMER\s0 program are instances of some class
(this has been explained informally in Section #{SUMMER/procedures}.)..
A composite instance consists of the name of the class to which it belongs,
the literal text of the declaration of that class and an environment
that has to be used to inspect or update components from the instance.
Operations are defined on elements in $PROCEDURE$, $CLASS$ and $INSTANCE$
to manipulate the components of an element in these domains.
For completeness, these domains are mentioned here, but they
will not be used in the remainder of this chapter.
A complete definition appears in Section #{Semantic domains}.
.PP
.ix I $ENVIRONMENT$
is the domain of environments.
Environments take care of the binding between names and values and the
introduction of new scopes (i.e. ranges in the program where
names may be declared).
In general, operations defined on environments modify the environment
to which they are applied.
.PP
The definitions given in following sections are centered around operations
on elements of these semantic domains,
but we will see relatively few of them in the examples.
Operations will be explained only when they occur in an example.
.SH #{FORMAL/method/eval=sn+}. "Evaluation process"
.PP
Before turning our attention to the evaluation process (which defines semantics),
a few words must be said about the definition of syntax.
In the definition method to be used the role of a syntax definition is twofold:
.IP \*(MK
to define the grammar of the defined language, and
.IP \*(MK
to unravel a source text in order to define a meaning for its constituent
parts.
.LP
These two aspects of a syntax definition are now considered in turn.
.PP
An extended form of \s-2BNF\s0 notation is used to describe the syntax
of the defined language.
The extensions aim at providing a concise notation for the description
of repeated and optional syntactic notions.
A syntactic notion suffixed with `\*{+\*}' means one or more repetitions of
that notion.
A notion suffixed with `\*{*\*}' stands for zero or more repetitions
of that notion.
The notation
.DS
{ \fInotion separator\fP } \fIreplicator\fP
.DE
i.e. a \fInotion\fP followed by a \fIseparator\fP enclosed in braces
followed by a \fIreplicator\fP,
is used to describe a list of notions separated by the given separator.
A replicator is either `\*{+\*}' or `\*{*\*}'.
The replicator `\*{+\*}' indicates that the list consists of one or more notions.
The list begins and ends with a notion.
The replicator `\*{*\*}' indicates that the list consists of zero or more notions.
.PP
An optional syntactic notion is indicated by
enclosing it in square brackets, e.g. `[ \fInotion\fP ]'.
The terminal symbols of the grammar are either enclosed in single
quotes (for example: \*{','\*} or \*{':='\*}) or written in upper case letters
if the terminal symbol consists solely of letters
(both `\*{IF\*}' and `\*{'if'\*}' may, for instance,
be used to denote the terminal symbol `\*{if\*}\|').
Where necessary, parentheses are used for grouping.
.PP
Some parts of a syntax rule may be labelled with a \*<tag\*>; their
meaning will become clear below.
.PP
The
.ix I "evaluation process"
is described in \s-2SUMMER\s0 extended with \fBparse expressions\fP$"" sup 2$
.FS
2) There is no \fBfundamental\fP reason for introducing this language extension.
However, the disadvantage of introducing such an \fIad hoc\fP extension
is more than compensated by the fact that we use a notation which is
sufficiently similar to \s-2BNF\s0 notation to be almost self-explanatory.
The effect of introducing a language extension as proposed here
is interesting in its own right but falls outside the scope of the
current discussion.
.FE
of the form
.DS
\&\*{'{{' <identifier>\*} \*`\*{==\*}\*' \*{<syntax-rule> '}}'\*}
.DE
which provide a concise notation for parsing and extracting
information from the text of the source program.
A parse expression succeeds if the identifier on the left hand side
of the `\*{==\*}' sign has
a string as value and if this string is of the form described by the
\*<syntax-rule\*> on the right hand side of the `\*{==\*}' sign.
All \*<tag\*>s occurring in the \*<syntax-rule\*> should have been declared as
variables in the program containing the parse expression,
in this case the evaluation process.
Substrings of the parsed text recognized by the syntactic categories
that are labelled with a \*<tag\*>
are assigned to the variable that corresponds to that \*<tag\*>.
Consider, for example, the following program fragment:
.DS
.{{
if {{ e == WHILE t:<test> DO b:<body> OD }}
then
   put('While expression recognized')
fi
.}}
.DE
The parse expression will succeed if \*{e\*} has the form of a `while
expression'.
The literal text of the \*<test\*> is then assigned to variable \*{t\*}
and the text of the \*<body\*> is assigned to variable \*{b\*}.
.PP
If the recognized part of the text is a list or repetition,
then an array of string values is assigned to the variable.
In the case of a list of notions separated by separators, the latter are
omitted and only the notions occurring in the list are assigned to
(consecutive) elements in the array.
This is exemplified by:
.DS
.{{
if {{ e == VAR list:{<identifier> ','}+ }}
then
   put('A variable declaration containing:');
   for id in list do put(id) od
fi
.}}
.DE
The parse expression succeeds if \*{e\*} has the form of a `variable declaration'
(i.e. the keyword `\*{var\*}' followed by a list of \*<identifier\*>s separated
by commas)
and in that case
an array of string values corresponding to the \*<identifier\*>s occurring in
the declaration
is assigned to the variable \*{list\*}, which is subsequently printed.
.PP
Parse expressions may be used in \fBif\fP-expressions or may stand on their own.
In the latter case, the string to be parsed \fBhas\fP to be of the form described by the parse expression.
In this way, parse expressions can be used
to decompose a string with a known form into substrings.
.PP
This concludes our digression on the definition of syntax and we turn now
our attention to the evaluation process that defines semantics.
In the case of the \s-2SUMMER\s0 definition, the overall structure of this
.ix I "evaluation process"
is:
.DS I
.{{
var ENV;
var STATE;
var varinit;
proc ERROR
.sp -0.1
     ... ;
proc eval(e)
( var value, signal, ... ;
  if {{ e == <program-declaration> }}
  then
.sp -0.1
     ...
     return([value, signal])
  fi;
  if {{ e == <variable-declaration> }}
  then
.sp -0.1
     ...
     return([value, signal])
  fi;
.sp -0.1
  ...
  if {{ e == <empty> }}
  then
.sp -0.1
     ...
     return([value, signal])
  fi;
);
.}}
.DE
The variable \*{ENV\*} has as value the current environment, and \*{STATE\*}
has as value the current state.
The variable \*{varinit\*} has as value a string consisting of the
text of all
\*<variable-initialization\*>s
.iy I <variable-initialization> s
in the current
\*<block\*>.
.iy I <block> .
.PP
The procedure \*{ERROR\*} is called when a semantic error is
detected during evaluation.
In this case, the whole evaluation process is aborted immediately.
The main defining procedure is \*{eval\*}, which selects an appropriate case
depending onto the syntactic form of its argument \*{e\*}.
Some examples of these various cases will be given in Section #{FORMAL/examples}.
Note that each of these cases involves a complete syntactic analysis
of the string \*{e\*}.
The evaluation process is initiated by creating an initial, empty
environment \*{ENV\*} and by calling \*{eval\*} with the text of the
source program as argument.
If the evaluation process is not prematurely terminated
(by the detection of a semantic error)
the result of the evaluation of the source program can be obtained
by inspecting the resulting environment \*{ENV\*}.
.PP
The definition of \s-2SUMMER\s0 has been profoundly influenced by the
success-directed evaluation scheme in the language:
an expression can either \fBfail\fP or \fBsucceed\fP.
The meaning of failure is that evaluation of the `current' expression
is abandoned and that evaluation is continued at a point where
a `handler' (i.e. \*<if-expression\*>, \*<while-expression\*>)
occurs to deal with the failing case.
A similar situation exists for \*<return-expression\*>s, which terminate
the evaluation of (possibly nested) expressions.
Both language features can thus essentially influence the flow-of-control
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
In \*{eval\*} this corresponds to appropriate reactions
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
.br
.ne 6
.SH #{FORMAL/examples=sn+}. "Some examples"
.SH #{FORMAL/examples/if=sn>1}. "If expressions"
.PP
An \*<if-expression\*> corresponds to the if-then-else statement found
in most programming languages.
If evaluation of the \*<test\*> immediately contained in the
\*<if-expression\*> terminates successfully, the \*<block\*>
following \*{then\*} is evaluated.
If a \*<return-expression\*> was encountered during evaluation of the \*<test\*>,
then the evaluation of the \*<if-expression\*> as a whole is terminated.
Otherwise, the \*<test\*>s following subsequent \*{elif\*}s
are evaluated until
.XP 0.5
.IP \*(MK
one such evaluation terminates successfully
(the \*<block\*> in the following \*{then\*}-part is then evaluated), or
.IP \*(MK
a \*<return-expression\*> is encountered during evaluation of the \*<test\*>
(the evaluation of the \*<if-expression\*> as a whole is then terminated), or
.IP \*(MK
the list of \*<test\*>s is exhausted.
.XP 0.5
.LP
In the last case, the \*<if-expression\*> may contain
an \*{else\*}-part and if so the \*<block\*> following \*{else\*} is evaluated.
The formal definition is:
.XP 1
.sp 1
.D{
.nm 1
.{{
if {{ e == IF t:<test> THEN b:<block>
           elifpart: (ELIF <test> THEN <block>)*
           elsepart: [ELSE <block>] FI }}
then
   var v, sig;
   [v, sig] := eval(t);
   if sig = N
   then
      return(eval(b))
   elif sig = FR | sig = NR
   then
      return([v, sig])
   else
      var oneelif;
      for oneelif in elifpart
      do {{ oneelif == ELIF t:<test> THEN b:<block> }} ;
         [v, sig] := eval(t);
         if sig = N
         then
            return(eval(b))
         elif sig = FR | sig = NR
         then
            return([v, sig])
         fi
      od;
      if {{ elsepart == ELSE b:<block> }}
      then
         return(eval(b))
      else
         return([a_undefined, N])
      fi
   fi
fi;
.}}
.nm
.D}
.sp 1
The parse expression in lines 1-3 decomposes the string value of \*{e\*}
into several parts.
In line 6 the \*<test\*> of the \*<if-expression\*> is evaluated.
If this evaluation produces the signal \*{N\*}, the \*<block\*>
following \*{then\*} is evaluated.
The occurrence of the signals \*{NR\*} or \*{FR\*}
(denoting the occurrence of a \*<return-expression\*>)
terminates the evaluation of the \*<if-expression\*> (lines 10, 21).
The loop in lines 15-25 iterates over the successive \*<test\*>s and
describes the semantics as explained above.
If all \*<test\*>s fail, the (optional) \*{else\*}-part is evaluated in lines 26-31.
.PP
For a better understanding of the above definition, it may be useful to note
that parts of the source program are parsed \fBrepeatedly\fP during \fBone\fP
evaluation of a given \*<if-expression\*>.
For example, the \*<block\*> following an \*{elif\*} is parsed both
in lines 2 and 16.
(This explains, by the way, why the parse expression in line 16 need
not be contained in an if statement, see Section #{FORMAL/method/eval}.).
In general, the source text of the \*<if-expression\*> is parsed \fBeach\fP
time that it is evaluated.
.SH #{FORMAL/examples/var=sn+}. "Variable declarations"
.PP
A \*<variable-declaration\*> introduces a series of new variables into 
the current environment, i.e. names of locations whose contents
may be inspected and/or modified.
The declaration may contain \*<expression\*>s whose values are to be used
for the initialization of the declared variables.
In the formal definition, this is described by appending all
variable initializations in the current \*<block\*> to the
variable \*{varinit\*} and by evaluating the string value of that
variable before the evaluation of the subsequent
\*<expression\*>s in the \*<block\*>.
The formal definition of \*<variable-declaration\*>s is:
.sp 1
.D{
.nm 1
.{{
if {{ e == VAR varlist:{<variable-initialization> ',' }+ ';' }}
then
   var name, onevar;
   for onevar in varlist
   do if {{ onevar == name:<identifier> ':=' <expression> }}
      then
         varinit := varinit || v || ';'
      else
         {{ onevar == name:<identifier> }}
      fi;
      ENV.bind(name, STATE.extend(a_undefined))
   od;
   return([a_undefined, N])
fi;
.}}
.nm
.D}
.sp 1
In line 1, \*{e\*} is decomposed into an array of strings which have
the form of a \*<variable-initialization\*>.
These string values are considered in succession in the loop in lines 4-12.
If the \*<variable-initialization\*> contains an initializing
expression, that expression is appended to \*{varinit\*} (line 7)
using the string concatenation operator `\*{||\*}'.
Finally, the state \*{STATE\*} is \fBextend\fPed with a location containing
an undefined value, and that new location is \fBbound\fP, in the current
environment \*{ENV\*}, to the identifier being declared.
Note that, in line 9, \*{v\*} is known to have the form of an \*<identifier\*>.
.SH #{FORMAL/examples/block=sn+}. "Blocks"
.PP
A \*<block\*> introduces a new scope to be used for the declaration of
new variables and constants.
It consists of a (perhaps empty) list of declarations followed
by a sequence of expressions separated by semicolons.
A \*<block\*> is evaluated as follows:
.IP \*(MK
Evaluate all declarations (this can never fail).
.IP \*(MK
Evaluate all variable-initializations resulting from the evaluation
of the declarations.
If this evaluation is not completed successfully, the evaluation of the \*<block\*>
is terminated.
.IP \*(MK
Evaluate the sequence of expressions in the \*<block\*>.
S\s-2UMMER\s0 forbids the failure of an expression inside
a sequence of expressions.
Only the last expression in a sequence is allowed to fail; this failure
is passed upwards to enclosing language constructs.
If a \*<return-expression\*> is encountered during evaluation of one of the
\*<expressions\*>s, the evaluation of the \*<block\*> is terminated.
.LP
The formal definition is:
.sp 1
.D{
.nm 1
.{{
if {{ e == decllist:  <variable-declaration>*
           exprlist:  {[<expression>] ';'}* }}
then
   var decl, expr, ENV1, i, varinit1, sig;
   ENV1 := ENV;
   ENV.new_inner_scope;
   varinit1 := varinit;
   varinit := '' ;
   for decl in decllist do [v, sig] := eval(d) od;
   [v, sig] := eval(varinit);
   varinit := varinit1;
   if sig ~= N then ENV := ENV1; return([v, sig]) fi;
   for i in exprlist.index
   do [v, sig] := eval(exprlist[i]);
      case sig
      of  N:        # nothing to do #,
          F:        if i ~= exprlist.size - 1 then ERROR fi,
          NR: FR:   ENV := ENV1; return([v, sig])
      esac
   od;
   ENV := ENV1;
   return([v, sig])
fi;
.}}
.nm
.D}
.sp 1
This definition is a simplified version of the one given in part II.
In lines 5-8 local copies are made of \*{E\*} and \*{varinit\*}
and new values are assigned to them.
In lines 9-12 the list of \*<variable-declaration\*>s in the \*<block\*>
and the resulting \*<variable-initialization\*>s are evaluated.
In lines 13-20 the list of \*<expression\*>s in the \*<block\*> is evaluated.
Note how failure of an expression in the middle of the list
is treated (line 17, see above).
.SH #{FORMAL/assessment=sn<<+}. "Assessment"
.PP
The formal language definition presented in the previous section will now
be assessed.
It is tempting to try to get statements like:
.sp 0.5
.IP "" 3
\fIUsers can answer 87% of their questions on language issues
within five minutes if they have access to a formal language definition
of the kind described in this chapter.\fP
.LP
or
.IP "" 3
\fI35% of all run-time errors in user programs are directly related to
anomalies in the language definition.\fP
.sp 0.5
.LP
In the absence of such results and without methods of obtaining them,
we have to live with qualitative and more or less
speculative observations.
.PP
A rough indication of the \fBconciseness\fP
of the definition can be obtained by comparing various sizes
as they apply to the \s-2SUMMER\s0 definition:
.DS I
.ta 6c
formal definition	\020 pages
reference manual	100 pages
implementation	200 pages
.DE
These figures show that the implementation is ten times larger
than the formal definition.
This is not surprising, since the implementation has
to be efficient while the formal definition does not have to be.
In this light the `a-language-is-defined-by-its-implementation' approach
can be rephrased
as: `\fBif\fP a language
is defined by its implementation,
\fBthen\fP that implementation had better be small'.
.PP
The definition is \fBprecise\fP and \fBcomplete\fP, in the sense that \fBall\fP
semantic operations associated with a particular language construct
\fBhave\fP to be specified to allow the construction of an
\fBexecutable\fP version of the definition.
The number of \fBoperational details\fP,
i.e. details in the definition which stem from the chosen definition method and
are not a reflection of details of the defined language, are surprisingly small.
This is a consequence of the choice of
the definition language (which should have powerful data types and
string manipulation operations) and the choice
of high-level environment
manipulation primitives which correspond directly to operations
in the defined language and which are not (yet)
perverted by implementational details.
S\s-2UMMER\s0, extended with parse expressions, seems a quite reasonable
vehicle for language definition.
However, it is not possible to make `continuation-style' (see [Gordon79])
definitions, since higher-order functions are lacking.
.PP
It is difficult to give an objective judgement as to the \fBreadability\fP
of the definition,
but we have observed that only a moderate effort (of a few days)
is required on the part of a programmer without any training
in formal semantics, and without any previous exposure to the
language, to learn \s-2SUMMER\s0 using only the (annotated) formal
definition.
.PP
The advantages and disadvantages of the formal definition for designer,
implementor and user
will now be discussed in some detail.
.br
.ne 4
.LP
The advantages for the \fBdesigner\fP are:
.IP \*(MK
Anomalies in the design are magnified.
It is a general rule that ill-formed entities can only be described by
ill-formed descriptions or by descriptions which list many exceptional cases.
It is easier to locate such exceptions or anomalies in a concise formal definition
than in an ambiguous natural language definition or in a bulky implementation.
In the \s-2SUMMER\s0 definition, for example, a very specific operation on
environments is needed (`partial-state-copy') to accommodate the definition
of just one language feature (`try-expression').
It turned out that
a slight modification of that feature would
at the same time simplify the definition
and improve the feature.
.IP \*(MK
Exhaustive enumeration of language features.
A formal definition method forces the designer to enumerate all
language features in the same framework and
this may help him to find omissions in the design.
.IP \*(MK
Interactions between language features can be studied.
In the \s-2SUMMER\s0 definition, for example, the designer is forced to
decide what happens when a \*<return-expression\*> is evaluated
during the evaluation of any other expression.
There is, however, no guarantee that all interactions can be found,
since the formal definition may still contain hidden interactions between
language features.
The use of auxiliary functions in the definition is an aid in making
interactions explicit.
One may even apply techniques
such as calling graph analysis and data flow analysis to the
definition to discover clusters of interacting features
and to establish certain properties of the definition.
.IP \*(MK
An executable formal definition can be tested and used.
This may help eliminate
clerical and gross errors from the definition.
An executable definition allows the designer to play with (toy) programs
written in the language he is designing.
There is, however, a problem with circular definitions:
some implementation of the defined language has to exist before
the definition itself can be made executable.
.br
.ne 6
.LP
Disadvantages for the \fBdesigner\fP are:
.IP \*(MK
A considerable effort is required to construct a formal definition.
.IP \*(MK
A general problem is that
there are no canned, satisfactory definition methods available and
that the designer has to begin with either creating a new method or adapting and
extending an existing one.
.br
.ne 6
.LP
Advantages for the \fBimplementor\fP are:
.IP \*(MK
Unambiguous language definition.
.IP \*(MK
The implementor may stumble over a certain combination of features.
Such cases can be executed both by the implementation and by the definition
and the results can be compared.
.br
.ne 6
.LP
Disadvantages for the implementor are:
.IP \*(MK
The implementor must be familiar with the definition method
or become acquainted with it.
This is only a minor effort if one compares it with the total effort
required to implement the language.
.IP \*(MK
It is non-trivial to derive an implementation strategy from the
language definition.
This is a problem shared by all `abstract' language definitions,
in which no attempt is made to use primitives in the definition
with a direct counterpart in an implementation.
This leads to the conclusion that such abstract definitions should
be accompanied by an `annotation for implementors', which states
where well-known implementation techniques can be used and where
certain optimizations are possible.
.br
.ne 6
.LP
Advantages for the \fBuser\fP are:
.IP \*(MK
Unambiguous and concise language definition.
.IP \*(MK
The user is used to reading programs and the formal definition can be read
as such.
In the case of a circular definition,
the formal definition may be considered as a very informative
example program.
.br
.ne 6
.LP
Disadvantages for the \fBuser\fP are:
.IP \*(MK
The user must be exposed to the definition method.
.IP \*(MK
A formal definition is harder to read than a `natural language' definition.
.IP \*(MK
In the case of the \s-2SUMMER\s0 definition,
the circularity may be confusing for the naive user.
.PP
In retrospect, it seems justified to conclude that the method presented
in this chapter is a first step in satisfying the requirements given
in Section #{FORMAL/problem}.
However, many problems remain to be investigated.
Does the method given lend itself to mathematical analysis?
How can the `complexity' of a language be derived from its definition?
Is it possible to `optimize' the executable version of definitions?
Attempts in this direction can be found in [Jones80].
What is the relationship between this definition method
and extensible languages?
Answers to these questions will provide more insight into the
structure of programming languages and the methods of defining them.
.SH #{sn+}. "References for Chapter #{FORMAL LANGUAGE DEFINITIONS}"
.so refs/Gordon79
.so refs/Jones80
.so refs/Klint81a
.so refs/Landin64
.so refs/Marcotty76
.so refs/Reynolds72
.so refs/Wegner72
#{sn<;}#{figs<;}
.EC
