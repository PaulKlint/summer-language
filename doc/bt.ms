#{figs+>;}.NC #{DESIGN CONSIDERATIONS=sn+} "DESIGN CONSIDERATIONS FOR" "STRING PROCESSING LANGUAGES"
.ds LH "DESIGN CONSIDERATIONS FOR STRING PROCESSING
.SH #{DESIGN/intro=sn>1}. "Introduction"
.PP
The application of backtracking in pattern matching and the integration of
pattern matching operations into string processing languages form
the central themes of this chapter.
.PP
Backtracking can be used to solve
certain classes of pattern matching problems elegantly.
However, the effects of backtracking on the global program state are
often difficult to understand.
Are side-effects postponed until the
backtracking process as a whole has succeeded
(which restricts the class of problems that can be solved),
or are such modifications performed
immediately and undone on failure?
Several methods are being used to control the interaction between
the backtracking process and its side-effects.
Most methods have defects.
In this chapter an attempt will be made to improve on this state of affairs.
.PP
The analysis of backtracking will proceed in three stages.
First, in Section #{set of pm operators} some representative pattern matching functions and operators are defined.
These functions are sufficiently powerful that they exhibit the same problems
with regard to side-effects and backtracking as occur in, for example, \s-2SNOBOL\s04.
They are, at the same time, sufficiently simple to
allow a concise formal definition of their semantics and an analysis
of the problems at hand.
In other words, these functions are used to \fBmodel\fP
(i.e. imitate on a smaller scale) certain features of existing
programming languages.
.PP
Secondly, we have to choose a
method for describing the semantics of backtracking processes.
After comparing several methods found in the literature,
an improved description method is introduced, which is
based on operational semantics.
This is the subject of Section #{description methods}.
.PP
Thirdly, the description method is used to compare
two different pattern matching models.
In Section #{immediate/conditional model} the
\fBimmediate/conditional model\fP is described.
This is a generalization of the \s-2SNOBOL\s04 model [Griswold71].
In Section #{recovery model} the \fBrecovery model\fP is introduced.
This new model is based on the recovery block concept 
[Randell75]
which has been used for the construction of fault-tolerant software.
It is an attractive alternative to existing backtracking models,
since it combines simplicity and consistency with adequate expressive
power and ease of implementation.
.PP
Finally, Section #{unification} is devoted to the question of how pattern matching
and normal expression evaluation can be integrated and how
the domain of pattern matching can be extended beyond the domain of strings.
In the following chapters these ideas will be explored further.
.SH #{set of pm operators=sn+}. "Some representative pattern matching functions and operators"
.PP
We first introduce a uniform terminology with the aid of which the
problems inherent in the two pattern matching models can be discussed.
A \fBpattern\fP defines a set of \fBacceptable\fP strings.
It is a predicate which
succeeds or fails when presented with a string that is or is not
an element of the set of acceptable strings.
Arbitrary (terminating) computations may be performed while determining
whether a given string is acceptable or not.
A \fBpattern match\fP
is the process of deciding whether a given string $S$ is acceptable to
a given pattern $P$ or not.
The notation $S~?~P$ will be used to denote a pattern match.
All (sub)patterns in $P$ will operate on the same subject string $S$.
An implicit index (the \fBcursor\fP)
holds the position in the subject string where each subpattern
should start its recognition task.
.PP
Three types of primitive patterns will be used:
\fBstring literals\fP, \fBunevaluated expressions\fP and \fBactions\fP.
These are informally defined as follows:
.IP "String literal: $T$"
.br
Try to match a given string value $T$
in the subject string starting at the current cursor position.
.IP "Unevaluated\ expression: \*{*E\*}"
.br
Evaluate expression $E$ and use the result as a pattern.
.IP "Action: $act(E)$"
.br
Evaluate expression $E$ for its side-effects.
This primitive pattern always succeeds and does not cause any movement of
the cursor (i.e. it matches the empty string).
.PP
These primitive patterns can be combined to form more
complicated patterns by means of the pattern construction functions
\fBalternation\fP, \fBsubsequentiation\fP and \fBsubject assignment\fP.
Note that we will attach different meanings to alternation and subsequentiation 
in the two pattern matching models to be considered.
Here, their meaning is the one used in the immediate/conditional model.
Their meaning in the recovery model is given in Section #{recovery model}.
The pattern construction functions are informally defined as follows:
.IP "Alternation: $P~|~Q$"
.br
If pattern $P$ fails, attempt pattern $Q$; if $P$ succeeds, remember $Q$
in case failure occurs later on
(this can only happen if the alternation is part of a larger pattern).
.IP "Subsequentiation:\ \*{P -- Q\*}"
.br
Attempt pattern $Q$ after a successful match of pattern $P$.
.IP "Subject\ assignment:\ $sbas(P,V)$"
.br
The part of the subject string
successfully matched by pattern $P$is assigned to variable $V$.
(This resembles the `.' and `$roman "$"$' operators in \s-2SNOBOL\s04.)
Note that subject assignments are more restricted than primitive action patterns:
the latter may contain assignments of any value to any variable,
but the former only allow assignment of a matched part
of the subject string to an explicitly mentioned variable.
.PP
This collection of functions and operators
exhibits most features found in pattern matching languages.
Later on, some additional functions that are typical for each
individual model will be introduced.
.SH #{description methods=sn+}. "Description methods for pattern matching"
.PP
Before we embark on our attempt to compare both models, 
it is necessary to select appropriate semantic description tools.
Four methods are discussed:
.IP SET: 6
patterns are characterized by the (possibly infinite)
set of strings recognized by them.
.IP ALG: 6
patterns are described by algebraic transformations on (subject, cursor) values.
.IP COR: 6
patterns are described by collections of recursive coroutines
.IP OPS: 6
patterns are described by operational semantics.
.SH #{set of strings=sn>1}. "Patterns defined by sets of strings"
.PP
SET is the oldest method for describing patterns and
was used during the design of \s-2SNOBOL\s03
[Farber64].
It is possible to view patterns as generative grammars and
to associate a set of strings with every pattern constructed
from simple strings by sequentiation and alternation.
This method has several disadvantages.
A first difficulty stems from the fact that
alternation is not commutative, i.e. it applies its left and right
operands in left-to-right order.
(This could be repaired by using \fBordered\fP sets of string.)
.PP
More severe difficulties arise, however, with several primitive patterns.
It is extremely difficult, if not impossible, to associate a unique set of
strings with patterns containing
primitives like \*{POS(n)\*}, \*{TAB(n)\*} or \*{BREAK(s)\*}, since the strings
that are matched by such primitives depend on the patterns in which they occur.
.SH #{algebraic transformations=sn+}. "Patterns defined by algebraic transformations"
.PP
This method (based on [Gimpel73] and [Stewart75])
describes the meaning of a pattern as an algebraic transformation
of (subject string, cursor) values.
The meaning $M$ of a pattern $P$ is defined by a function $M(P) ^ (S,~c)$,
where $S$ is the subject string and $c$ is an integer indexing $S$.
$c$ is called the \fBpre-cursor\fP position.
The value of $M(P) ^ (S,c)$ is an ordered sequence of integers, indexing $S$,
which are called the respective \fBpost-cursor positions\fP.
Cursor positions can take on the values $0,~1 ,..., ~length(S)$,
where $length(S)$ denotes the length of the subject string $S$.
As soon as the meaning of the elementary scanning functions has been
expressed in terms of transformations on sequences of pre-cursor values
to sequences of post-cursor values, one can simply use composition of
cursor sequences to define the meaning of arbitrary patterns.
.PP
For instance, the meaning of a string literal $T$ can be described by
.DS
.{{
M(T)(S,c) =  if substring(S,c,length(T)) = T
             then
                {c+length(T)}
             else
                {}
             fi .
.}}
.DE
In other words, take a substring from $S$, starting at cursor position $c$,
that has the same length as $T$.
If such a substring exists and it is equal to $T$,
the string literal is said to match and the result is the
post-cursor sequence $"{"c+length(T)"}"$, i.e. the cursor moved past string $T$.
Otherwise the match fails and this is indicated by the empty
post-cursor sequence $"{}"$.
.PP
Alternation of patterns $P sub 1$ and $P sub 2$ can be described by
.DS
$M(P sub 1~|~P sub 2 ) ^ (S,c)~=~M(P sub 1 ) ^ (S,c)~\*(sc~M(P sub 2 ) ^ (S,c)$
.DE
where \*(sc denotes the concatenation of two sequences.
.PP
Subsequentiation of patterns $P sub 1$ and $P sub 2$ can be described by
.DS
$M(P sub 1~$\*{--\*}$~P sub 2 ) ^ (S,c)~=~M(P sub 2 ) ^ (S,~M(P sub 1 ) ^ (S,~c))$ .
.DE
It is tacitly assumed here that $M(P)$ has been generalized so as to
operate on cursor sequences, i.e.
the function $M(P):~S~\(mu~N~->~2 sup N$ has been generalized
to $M(P):~S~\(mu~2 sup N~->~2 sup N$,
where $S$ denotes the set of subject strings and $N$ denotes the natural numbers.
.PP
We now apply these definitions in an example.
If $P$ and $S$ are defined by
.DS
\*{P = 'ab' | 'aab' | 'a'\*}
\*{S = 'aab'\*}
.DE
then the application of pattern $P$ to the string $S$ can be characterized by
.DS
$M(P) ^ (S,~0)~=~"{"3,~1"}"$
$M(P) ^ (S,~1)~=~"{"3,~2"}"$
$M(P) ^ (S,~2)~=~"{}"$
$M(P) ^ (S,~3)~=~"{}"$.
.DE
Continuing in the same spirit, one can give concise definitions for
the elementary scanning functions as defined in Chapter #{INTRODUCTION}:
.DS L
.ta 22n 25n
$M(LEN(n)) ^ (S,~c)	=	bold "if"~c~+~n~<=~length(S)~bold then~"{"c~+~n"}"~bold else~"{}"~bold fi$
$M(POS(n)) ^ (S,~c)	=	bold "if"~c~=~n~bold then~"{"c"}"~bold else~"{""}"~bold fi$
$M(RPOS(n)) ^ (S,~c)	=	bold "if"~n~=~length(S)~-~c~bold then~"{"c"}"~bold else~"{""}"~bold fi$
$M(TAB(n)) ^ (S,~c)	=	bold "if"~n~>=~c~\*(an~n~<=~length(S)~bold then~"{"n"}"~bold else~"{""}"~bold fi$
$M(RTAB(n)) ^ (S,~c)	=	bold "if"~length(S)~-~n~>=~c~\*(an~n~<=~length(S)$
$		bold then~"{"length(S)~-~n"}"$
$		bold else~"{""}"$
$		bold fi$
.DE
.PP
This method is suited to the description of the
recognition properties of patterns but it does not lend itself to the
description of side-effects occurring during a pattern match.
.SH #{recursive coroutines=sn+}. "Patterns defined by recursive coroutines"
.PP
SL5 is a language that provides programmable backtracking based on recursive coroutines.
For a description of this method the reader is referred to
[Doyle75],
[Druseikis75]
or [Griswold76].
The latter reference also contains an overview of SL5.
There is a straightforward relationship between SL5 coroutines and
the more familiar detach/resume operations in \s-2SIMULA\s0 [Dahl70].
SL5 has been used to describe patterns:
a separate coroutine is associated with each component in the pattern
and signaling between coroutines is used to
control the pattern matching process.
.PP
The recursive coroutine method is powerful in that it allows the
description of both the recognition process itself as well as the side-effects
caused by it.
Although the primitives used are powerful, they are not generally known
and rather complex,
and this would lead us to the undesirable situation
that a complex problem would have to be described
using complex primitives.
We therefore explore a much simpler description method.
.SH #{rewriting systems=sn+}. "Patterns defined by operational semantics"
.PP
The previous methods are either based on high-level
concepts (coroutines) or do not address the problems of environment
modification during a pattern match.
In this section we shall develop a description technique
based on an operational method for defining the semantics of programming languages.
In this way we obtain a precise, operational definition of
pattern matching semantics
which is not based on complex primitives but nevertheless
completely describes all aspects of pattern matching.
.PP
To describe a pattern matching model completely
two entities must be specified:
.IP $PAT$ 6
A grammar describing all patterns.
.IP $match$ 6
A function describing the meaning of those patterns.
.LP
To structure the following discussion we further identify:
.IP $EXP$ 6
A subset of $PAT$ containing
the syntax rules that describe the expressions that may occur in a pattern.
.IP $eval$ 6
A function describing the meaning of expressions.
Obviously, $eval$ may be considered as an auxiliary function of $match$.
.LP
In the next section
the functions $match$ and $eval$ will be described in a simple, but powerful
programming language.
.SH #{comparison bt methods=sn<+}. "A comparison of two backtracking models"
.SH #{common defs=sn>1} "Common definitions for the two models"
.PP
Some global variables are shared by $PAT$, $match$, $EXP$ and $eval$.
It is not essential to do so, but it makes the resulting descriptions more concise.
This global information consists of:
.IP \*{subject_string\*}: 6
.br
the current subject string for each pattern matching process being described.
For convenience, we introduce the set $CURS$
of legal indices (i.e. cursor positions) in the current subject string.
.IP \*{INITIAL_ENV\*}: 6
.br
the program environment (i.e. the values of variables)
at the start of the pattern matching process.
.IP \*{CURRENT_ENV\*}: 6
.br
the initial environment modified by expressions evaluated during the
pattern match.
.PP
Environments consist of $(name,~value)$ pairs and for reasons of simplicity
we assume here that all names are global.
An identifier $id$ with value $val$ is added to environment $ENV$ by the operation:
.DS
$ENV.bind(id,~val)$ .
.DE
If $id$ occurred already as the name-part in some pair
in that environment, only the value-part of that pair is modified.
The value associated with an identifier \*{id\*} in the environment \*{ENV\*}
is retrieved by:
.DS
$ENV.binding(id)$ .
.DE
We require $id$ to be the name-part of some pair in $ENV$.
Finally, complete environments can be copied by the operation
.DS
$ENV sub 2 ~:=~copy(ENV sub 1 )$
.DE
which assigns a copy of environment $ENV sub 1$ to $ENV sub 2$.
.PP
Another aspect common to both models is the expression language $EXP$.
In the remainder of this paragraph, $EXP$
and its formal definition will be explained.
The syntax$"" sup 1$
.FS
1) See #{Syntactical considerations} for a definition of the syntax notation used.
.FE
of $EXP$ is given by:
.DS L
.<<
.so match/exp.syn
.>>
.DE
An \*<expression\*> thus consists of zero or more \*<assignment\*>s \fBseparated\fP by semicolons.
Each \*<assignment\*> consists of an \*<identifier\*> followed by
an assignment operator (`:=') and a \*<right-hand-side\*>.
A \*<right-hand-side\*> consists either of a \*<string-literal\*>, an \*<identifier\*>,
or an \*<identifier\*> followed by a plus sign followed by a \*<string-literal\*>.
.PP
The semantics of \*<expression\*>s is as follows.
The \*<assignment\*>s in an \*<expression\*> are treated from left to right.
An \*<assignment\*> can have
three different kinds of \*<right-hand-side\*>:
.sp 0.5
.IP "Case 1:" 12
\*<identifier\*>$"" sub 1$ := \*<identifier\*>$"" sub 2$:
\&`Bind' the value of \*<identifier\*>$"" sub 2$ to \*<identifier\*>$"" sub 1$
in the current environment.
.IP "Case 2:" 12
\*<identifier\*>$"" sub 1$ := \*<identifier\*>$"" sub 2$ + \*<string-literal\*>:
Concatenate the (string) value of \*<identifier\*>$"" sub 2$ and
the \*<string-literal\*> to obtain a new string value.
This new string value is bound to \*<identifier\*>$"" sub 1$ in the current environment.
.IP "Case 3:" 12
\*<identifier\*> := \*<string-literal\*>:
The \*<string-literal\*> is bound to \*<identifier\*> in the current environment.
.sp 0.5
.LP
For instance, the evaluation of the expression
.DS
.{{
x:='abc';y:=x;z:=y+'def'
.}}
.DE
will add the pairs \*{(x,'abc')\*}, \*{(y,'abc')\*} and \*{(z,'abcdef')\*} to
the current environment (provided that no previous bindings
existed for the variables $x$, $y$ and $z$).
.PP
The formal definition of the semantics of $EXP$ is given
in Figure #{Fig eval}.
The notation for formal definitions as used there will be used throughout.
Its most unusual feature are the
\fBparse expression\fPs of the form
.DS
\&\*{'{{'\*} \*<identifier\*> \*`\*{==\*}\*' \*<syntax-rule\*> \*{'}}'\*} .
.DE
These parse the string value of a given identifier
and at the same time extract substrings from it.
To this end, parts of the \*<syntax-rule\*> can be labelled with tags.
Each tag corresponds to a variable declared elsewhere in the program
(such as $exprs$ and $id1$ in the above definition)
and upon a successful parse of the string value,
each such variable receives, as value,
the substring recognized by the part of the syntax rule following the tag.
If the tag labels a repetitive syntax construct
(as with $exprs$ above), the corresponding variable
receives an array of strings (one string for each repetition of the construct)
as value.
Obviously, parse expressions can succeed or fail.
If it is known in advance that a parse expression will always succeed
(as is the case in the lines marked with \*#a\*# and \*#b\*#
in Figure #{Fig eval}),
the expression need not be
contained in an if-statement and can be used for the sole
purpose of extracting substrings.
.PP
Our notation is fully described in part II of this monograph and
an informal description can be found in Chapter #{FORMAL LANGUAGE DEFINITIONS}.
In the following sections we assume it to be self-explanatory.
.KF
.sp 2
.D{
.so match/match1.so
.D}
.ce 1
\s-1\fBFigure #{Fig eval=figs+}\fP. Formal definition of \fIeval\fP.\s0
.sp 2
.KE
.br
.ne 8
.SH #{immediate/conditional model=sn+}. "The immediate/conditional model"
.SH #{sn>1}. "Overview" -
.PP
In this model (a generalization of the \s-2SNOBOL\s04 model) the moment at
which operations are performed can be controlled
at the programming language level.
The meaning of the functions $act$ (action)
and $sbas$ (subject assignment) may depend on the moment they are carried out.
There are two versions of these functions.
The \fBimmediate\fP versions $imact$ and $imsbas$
are performed at the moment they are encountered during the pattern match;
the global environment is neither saved nor restored on failure.
The \fBconditional\fP versions $cdact$ and $cdsbas$
are remembered when they are encountered during the pattern match
but are performed only after the successful completion of
the complete pattern match.
Remembered conditional functions are forgotten if the pattern match fails.
.PP
Conditional functions do not
add recognition power, because only immediate modifications of the environment 
can influence the direction in which the recognition process proceeds.
The recognition power of pattern matching is thus based on 
the existence and power of immediate functions.
One can, for instance, build context dependent patterns
by combining (immediate) subject assignment and unevaluated expressions.
.PP
An example may illustrate why it is, in principle, desirable to use
such a powerful model.
.PP
Suppose pattern matching is used to parse a program.
Parsing of certain constructs in the program, like variable declarations,
must have an immediate effect on the parsing of the remainder of the program.
Later occurrences of variables can then be compared with their declaration.
.PP
Immediate operations allow the recognition of context-sensitive languages.
One way of recognizing the (context-sensitive) language
$A sup n B sup n C sup n$ is:$"" sup 2$
.FS
2) In order to present a non-trivial example,
we have taken the liberty of using a slightly more
powerful $EXP$ language than defined in #{common defs};
\*<right-hand-side\*>s consisting of function calls and
functions (like \*{length\*} and \*{replicate\*}) were not defined
there but have an obvious meaning.
.FE
.DS L
.{{
row_of_A  :=  'A' -- *row_of_A | '' ;
.br
abc       :=  imsbas(row_of_A,as) -- imact(n:=length(as)) --
.br
              *replicate('B',n) -- *replicate('C',n) ;
.}}
.DE
Here, \*{row_of_A\*} recognizes arbitrarily long sequences
of \*{'A'\*}s.
Pattern \*{abc\*} first attempts to recognize a row of \*{'A'\*}s which
is immediately assigned to variable \*{as\*}.
Next, the length of \*{as\*} is computed and assigned to variable \*{n\*}.
Finally, two new patterns are constructed (and attempted) consisting
of \*{n\*} \*{'B'\*}s and \*{n\*} \*{'C'\*}s respectively.
.PP
The above example illustrates the usefulness of immediate operations.
But under which circumstances is it desirable to perform operations conditionally?
An extreme example is in the code generation phase of a compiler:
all code generation operations would be remembered until the whole program
had been parsed.
After the program was found to be syntactically correct, the code generation
operations would be carried out.
If, on the other hand, syntax errors were detected, all
code generation operations would be discarded.
A less extreme example is the parsing of (locally) ambiguous
or non-LL(1) languages.
If a construct can be identified only after having
been parsed in its entirety, it may be necessary to postpone
all operations associated with it until that time.
This may, for instance, arise in a language allowing multiply labelled statements:
in that case an identifier is either the next label or the beginning of the
actual statement.
The same phenomenon also occurs for case statements allowing
an arbitrary number of expressions to be associated with each case.
.PP
We now list some advantages and disadvantages of the immediate/conditional model.
The advantages are:
.IP \*(MK
Information about failure can be passed to higher levels;
it is thus possible to construct patterns that do not require rescanning
of the subject string.
.IP \*(MK
The programmer has explicit control over the moment operations are performed.
This is also a disadvantage however, since it complicates the model.
.IP \*(MK
The model can be implemented efficiently.
.LP
Disadvantages of the immediate/conditional model are:
.IP \*(MK
Mixing of conditional and immediate operations is problematical.
First, the program text no longer reflects the order of events, which
greatly reduces its readability.
Secondly (and worse), conditional operations are performed in the
environment as it exists at the end of the successful pattern match in
which they occur.
This is the price paid for an efficient implementation: the environment is
not saved when a conditional operation is encountered during the pattern match.
Consider, for example:
.DS L
.{{
P := 'ab'--imact(n:='X')--'c'--cdact(res:=n)--imact(n:=n+'Y');
.}}
.DE
During the pattern match \*{'abc' ? P\*} the following steps are performed:
.RS
.IP 1)
The string \*{'ab'\*} is recognized.
.IP 2)
The operation \*{n:='X'\*} is performed.
.IP 3)
The string \*{'c'\*} is matched.
.IP 4)
The operation \*{res:=n\*} is remembered.
.IP 5)
The operation \*{n:=n+'Y'\*} is performed.
This amounts to assigning the string \*{'XY'\*} to variable \*{n\*}.
.IP 6)
The pattern match succeeds and all remembered operations
(in this example only \*{res:=n\*})
are performed in left to right order.
.LP
Variable \*{res\*} thus receives \*{'XY'\*} as final value, but \*{'X'\*} instead
of \*{'XY'\*} would in many respects have been a more reasonable outcome.
.RE
.IP \*(MK
Each implementation of the immediate/conditional model
has to solve the non-trivial problem of not imposing
restrictions on the number of simultaneously remembered conditional operations.
If an implementation does impose such restrictions,
it may not be possible to perform pattern matches in which large numbers
of conditional operations occur
(such as compiling a whole program in one pattern match).
In practice, this would have the highly undesirable effect of forcing
the programmer to use immediate operations exclusively and of
seriously limiting the usefulness of the backtracking facility.
.IP \*(MK
It is not visible whether a pattern
modifies the global environment on failure or not.
.PP
A final illustration of the intricacies
of the immediate/conditional model follows.
Considering
.DS
.{{
x   := 'A'; y := 'B';
p1  := 'a'--imact(x:=x+'X') | 'ab'--cdact(x:=x+y);
p2  := imact(y:=y+'Y')--'c';
p   := p1 -- p2;
.}}
.DE
the match \*{'abc' ? p\*}
succeeds and results in \*{x = 'AXBYY'\*}, \*{y = 'BYY'\*},
while \*{'aef' ? p\*}
fails and results in \*{x = 'AX'\*}, \*{y = 'BY'\*}.
These results are baroque, to say the least.
.SH #{sn+}. "Formal description" -
.PP
In the immediate/conditional model, the grammar $PAT$ is described by
the syntax rules:
.sp 1
.<<
.so match/pat-ic.syn
.>>
.sp 1
In order to simplify the formal definition, we assume
without loss of generality, that all syntactic ambiguities are eliminated
by the proper use of parentheses,
e.g. $P~|~((Q--R)--S)$ should be used instead of $P~|~Q--R--S$.
In the examples, the non-parenthesized version will be used
(for better readability) and the operator `\*{--\*}' is assumed to have higher
priority than the operator `|'.
.PP
Roughly speaking, the state a pattern match is in is fully$"" sup 3$
.FS
3) The existence of the global variables \*{subject_string\*},
\*{INITIAL_ENV\*} and \*{CURRENT_ENV\*} is not considered here.
.FE
specified by the following three parameters:
.IP \*(MK
The pattern that has to match in order
to complete the pattern match successfully.
.IP \*(MK
The cursor position in the subject string where the above
pattern should match.
.IP \*(MK
An expression that is equivalent to all remembered conditional operations.
Evaluating this expression has the same effect as evaluating
all remembered conditional operations in left to right order.
.LP
The meaning of a pattern can now be expressed in terms of its effects
on the above three entities.
.br
.ne 5
.PP
More formally, the semantics of patterns is given by the function
.DS
$match:~CURS~\(mu~EXP~\(mu~PAT~->~CURS~\(mu~EXP~\(mu~PAT sup 0~\(cu~FAIL$
.DE
where $PAT sup 0$ is equal to $PAT ~\(cu~ "{"null"}"$ and $null$ is the
pattern that always fails.
Note that $null$ can only come into existence as the result of applying $match$,
but that $match$ is not defined on it.
$match$ attempts to transform the (cursor, expression, pattern)
triple $(C,~E,~P)$ into a new triple $(C',~E',~P')$ as follows.
If pattern $P$ matches successfully, the cursor is moved to $C'$,
all conditional operations performed during this part of the match are
appended to expression $E$ (resulting in $E'$), and $P'$ is a pattern
consisting of all untried alternatives of $P$.
If $P$ fails, $match$ should deliver the value $FAIL$.
The function $match$ to be described below achieves this by
performing an \*{freturn\*} (failure return) operation.
This is equivalent to returning the Boolean value \*{false\*} which can
subsequently be tested for by the caller of $match$.
.PP
Apart from \*<compound\*>s,
all notions in the grammar given above correspond to some primitive pattern.
An implicit semantic property of the immediate/conditional model made
it, however, necessary to add a new type of pattern:
As was illustrated previously,
attempting `untried alternatives' of a pattern requires a mechanism
to restore a previous state of the pattern match.
To achieve this, \*<compound\*>s have been introduced
as explicit representations of the pattern matching state.
.PP
The formal definition uses several auxiliary functions.
Functions like \*{mk_alt\*} and \*{mk_comp\*} construct new elements of $PAT$
from given components.
For example, let \*{subject_string\*} have \*{'abcdef'\*} as value, then
.DS
.{{
p := mk_string(0,3);
q := mk_string(3,6);
a := mk_alt(p, q);
.}}
.DE
will assign the pattern \*{'abc'|'def'\*} to \*{a\*}.
The correspondence between such functions and the alternatives in the grammar
$PAT$ is:
.DS
.{{
mk_alt(p,q)             ->   p | q
mk_subs(p,q)            ->   p -- q
mk_comp(c,e,p)          ->   <c,e,p>
mk_string(from,to)      ->   <string-literal>
mk_cdsbas(p,id)         ->   cdsbas(p,id)
mk_imsbas(p,id)         ->   imsbas(p,id)
.}}
.DE
Note that \*{mk_string\*} constructs a new string
by extracting the characters with indices $from,~from+1 ,..., ~to-1$
from the global \*{subject_string\*}.
Also note that \*{mk_alt\*},
\*{mk_subs\*}, \*{mk_comp\*}, \*{mk_imsbas\*} and \*{mk_cdsbas\*}
do not construct a new pattern if one
of their arguments is \*{null\*}, e.g.
.DS
.{{
mk_alt(p,null)          ->   p
mk_alt(null,q)          ->   q
mk_subs(p,null)         ->   null
mk_subs(null,q)         ->   null
mk_comp(c,e,null)       ->   null
mk_imsbas(null,id)      ->   null
mk_cdsbas(null,id)      ->   null
.}}
.DE
Similar functions exist for the grammar $EXP$:
.DS
.{{
mk_assign(id,v)         ->   id := v
mk_expr(e1,e2)          ->   e1 ; e2
.}}
.DE
These functions are used to construct `remembered expressions'
as required for the modeling of conditional subject assignment (see below).
.PP
We now present the formal definition followed by a detailed explanation.
.sp 1
.D{
.so match/pat-ic1.so
.D}
.sp 1
The cases \*#a\*# to \*#l\*# correspond to the various alternatives
in the grammar $PAT$.
Each case will now be discussed in more detail:
.LP
a)\ If the pattern is an alternation of the form $P~|~Q$,
an attempt is first made to match the pattern $P$.
If successful, it delivers a new cursor, expression and pattern.
The new cursor value corresponds to the point to which the pattern $P$
has proceeded in the subject string.
The new expression consists of the old expression augmented by
the conditional operations encountered during the evaluation of $P$.
The new pattern ($P1$) corresponds to the remaining (untried) alternatives of $P$.
The pattern $P1~|~Q$ is delivered by the evaluation of $P~|~Q$.
If the match of $P$ fails, an attempt is made to match $Q$.
If the latter fails, $P~|~Q$ fails.
If it succeeds, again, a new cursor, expression and pattern are delivered.
In this case the pattern $Q1$ is delivered by the evaluation of $P~|~Q$.
.LP
b)\ If the pattern is a subsequentiation of the form \*{P -- Q\*},
the operations performed are of a similar nature
as the ones performed for alternation.
.LP
c)\ If the pattern consists of a pattern enclosed in parentheses,
the enclosed pattern is attempted.
.LP
d)\ If the pattern is a \*<string-literal\*>, it should
occur in the subject string, starting at the current cursor position.
This is taken care of by the function \*{litmatch(s)\*}.
If, for example, the subject string is \*{'abcd'\*},
then \*{litmatch(1,'bc')\*}
will deliver the value 3, while \*{litmatch(2,'bc')\*} will fail.
.LP
e)\ If the pattern is an \*<identifier\*>, the corresponding value in the
\fBinitial environment\fP is used as pattern.
In this way the notion of \fBpattern construction\fP,
as it exists, for example, in \s-2SNOBOL\s04 is modeled.
Before a pattern match starts, the expression describing the pattern
is used to build a data structure which is subsequently used
to control the recognition process.
In the formal description, this is reflected by the use of the initial
values of the variables occurring in the pattern.
.LP
f)\ If the pattern is an unevaluated expression of the form \*{*x\*},
the value of \*{x\*} in the current environment is used as pattern.
This introduces the possibility of context sensitive patterns,
that are modified dynamically during the pattern match.
.LP
g)\ It was already explained above that
\*<compound-pattern\*>s are a way of representing the pattern matching state.
They consist of a cursor value, an expression
describing remembered conditional operations, and a pattern.
Evaluation of a \*<compound-pattern\*> amounts to evaluating
its pattern component, starting at its cursor value.
The role of the expression component is further explained
in points i) and k) below.
.LP
h)\ If the pattern is an immediate subject assignment of the form \*{imsbas(P,x)\*},
an attempt is made to match pattern $P$.
If this is successful, the part of the subject
recognized by $P$ is immediately assigned to variable \*{x\*}.
.LP
i)\ If the pattern is a conditional subject assignment of the form \*{cdsbas(P,x)\*},
an attempt is made to match pattern $P$.
If this is successful, an assignment statement is constructed
that will eventually (i.e. at the end of the pattern match)
assign the recognized part of the subject string to variable \*{x\*}.
.LP
j)\ If the pattern is an immediate action, it is evaluated.
.LP
k)\ If the pattern is a conditional action, it is appended
to the current list of conditional operations.
.LP
l)\ In all other cases the pattern is syntactically incorrect.
.PP
It is instructive to trace the series of events taking place
during a simple pattern match (see Figure #{fig trace}).
For reasons of readability, arguments and results that are equal to the empty string
are denoted by a single space character.
.KF
.sp 2
.DS I 4c
.so match/examp.so
.DE
.ce 1
\s-1\fBFigure #{fig trace=figs+}\fP. Trace of pattern match \*{'abe' ? ('a'|'ab')--'e'\*}.\s0
.sp 2
.KE
.SH #{recovery model=sn<+}. "The recovery model"
.SH #{sn>1}. "Overview" -
.PP
This new model was inspired by the concept of recovery blocks.
In [Randell75] it is shown how
the reliability of a program can be increased by inserting
\fBacceptance tests\fP at appropriate places in the program.
Whenever such a test fails, the program state is restored to a state
at a previous well-defined point, and an attempt is
made to perform the same computation using an alternative algorithm.
This process is repeated until either the result
satisfies the acceptance test or no more alternative algorithms are available.
In the latter case, the failure has to be handled at a higher, more global,
level in the program.
To this end the program is split up into (nested) recovery blocks.
Each recovery block starts with a `begin of recovery block' statement
indicating that a roll-back to this point may take place,
and ends with an acceptance test.
The body of the recovery block consists of the various alternative algorithms
to be tried.
.PP
This approach clearly bears a certain resemblance to backtracking.
Given the problems with the immediate/conditional model,
two further observations led to the idea that backtracking could be
completely replaced by the recovery block method:
.IP \*(MK
It is desirable for the programmer to have complete control over the scope of backtracking.
.IP \*(MK
A failing pattern component should only be allowed to change the local
(innermost) but not the global environment.
In this way, the side-effects of failing patterns can be localized.
.LP
It is possible to interpret the recovery model in such a way that the
above two requirements are satisfied and that the disadvantages of the
immediate/conditional model disappear.
First, alternation and subsequentiation are stripped of their capability
to remember untried alternatives.
Secondly, a single operation is defined for the control of both
backtracking and environment modification.
For this purpose the construction:
.EQ I
bold try~<id sub 1 ~,..., ~id sub n >~p sub 1 ~,..., ~p sub m~bold until~p sub 0~bold yrt
.EN
is introduced, where $p sub 1 ~,..., ~p sub m$ are patterns to be tried successively
and $p sub 0$ is a pattern to be applied after the successful matching of
one of the patterns $p sub 1 ~,..., ~ p sub m$.
If $p sub 0~,~ p sub 1~,...,~p sub m$ fail, the environment is restored to the state it was in
at the moment the \*{try\*} construction was entered,
\fBexcept for the values of the variables\fP $id sub 1 ~,..., ~id sub n$.
These variables can be used as a communication channel or
\fBwindow\fP between the patterns $p sub 0 ~,~ p sub 1 ~,..., ~p sub m$.
In this way, each alternative can inspect
information supplied by previous (necessarily unsuccessful) attempts.
Note, that the variables in the window have to be declared elsewhere;
the occurrence of a variable in a window only establishes the fact that
its value will not be recovered.
.PP
Since all language aspects related to backtracking have been
concentrated in the try construct, the
alternation and subsequentiation of patterns
(represented by `|' and `\*{--\*}' in the immediate/conditional model)
can now be expressed by the ordinary Boolean operators \fIand\fP and \fIor\fP.
We shall, however, continue to use the same notation
in order to make the comparison between the two models easier.
.PP
The recovery model is superior to the immediate/conditional model
in several respects:
.IP \*(MK
It is possible to save information gathered during a failing pattern match
in a way which is more structured than in the immediate/conditional model.
.IP \*(MK
It is much simpler than the immediate/conditional model:
the number of operators is smaller and no unexpected effects can occur by
mixing immediate and conditional operations.
In the immediate/conditional model the programmer has to be aware of
unwanted `backing into previous alternatives'.
Consider the pattern:
.DS L
.{{
  '[' --
      ( expr |
        imact(error:='invalid index')
      ) --
  ']'
.}}
.DE
applied to the string \*{'[a+b}'\*}.
On encountering the invalid symbol `}', automatic backtracking
causes the (inappropriate) error message to be assigned to
the variable \*{error\*}.
This cannot occur in the recovery model, since the programmer has
to ask for backtracking explicitly.
In the recovery model, one can formulate the above problem in two ways.
The error message alternative can either be discarded, leading to
.DS L
.{{
  '[' --
      ( expr |
        act(error:='invalid index')
      ) --
  ']'
.}}
.DE
(where `|' is used as the ordinary Boolean \*{or\*} operator
and the action is only evaluated if \*{expr\*} fails),
or it can be remembered explicitly
.DS L
.{{
  '[' --
      try expr,
          act(error:='invalid index')
      until ']'
      yrt
.}}
.DE
.IP \*(MK
A reasonably efficient implementation is possible
using a \fBcache\fP containing the modifications to the
enclosing environment.
Such a cache mechanism evenly distributes the work of saving
and restoring the program state, i.e.
the amount of work increases in proportion to
the number of modifications to the original state.
The absence of automatic backtracking renders this implementation method feasible.
It is crucial that the beginning and end of a try construct are known
so that the period during which modifications
have to be remembered is well-defined.
.PP
An example will illustrate the main properties of the recovery model.
Consider
.DS
.{{
p := ('a' | 'ab') -- 'c' .
.}}
.DE
Both \*{'abc' ? p\*} and \*{'abd' ? p\*} fail, since backtracking is not automatic.
If, on the other hand, \*{p\*} is defined by
.DS
.{{
p := try <> 'a', 'ab' until 'c' yrt
.}}
.DE
then \*{'abc' ? p\*} will succeed.
.SH #{sn+}. "Formal description" -
.PP
In the recovery model, the pattern language $PAT$ is described by
the following syntax rules
.sp 0.5
.<<
.so match/pat-rc.syn
.>>
.sp 0.5
The syntax rules for \*<expression\*>s and their meaning have already been
described in Section #{common defs}.
The semantics of patterns is described by the function
.DS
$match:~CURS~\(mu~PAT~->~CURS~\(cu~FAIL$.
.DE
This function attempts to match a given pattern starting at a given
cursor position and delivers a new cursor position.
In contrast to the immediate/conditional model,
it is not necessary to accumulate expressions describing conditional
operations, nor to remember untried alternatives.
We now present the semantics of pattern matching in the recovery model.
.sp 1
.D{
.so match/pat-rc1.so
.D}
.sp 1
Cases \*#c\*#, \*#d\*#, \*#e\*#, \*#f\*#, \*#g\*#, \*#h\*# and \*#j\*#
have direct counterparts in
the immediate/conditional model
and need no further explanation.
Only the remaining cases will be discussed.
.LP
a)\ If the pattern is an alternation of the form $P~|~Q$,
$P$ is attempted first.
If successful, the new cursor value is returned.
If not successful, $Q$ is attempted.
Again, if $Q$ is successful, the cursor delivered by $Q$ is returned.
In all other cases $P~|~Q$ fails.
It is interesting to compare the simplicity of this alternation
operator with the much more complex alternation operator in the
immediate/conditional model.
.LP
b)\ If the pattern is a subsequentiation, it is handled in a similar fashion.
Again, compare this operator with its counterpart in the immediate/conditional model.
.LP
i)\ If the pattern is a \*{try\*} construct of the form
.DS
$bold try~<id sub 1 ~,..., ~id sub n >~p sub 1 ~,..., ~p sub m~bold until~p sub 0~bold yrt$
.DE
the current environment is copied first.
The patterns $p sub 1~,...,~ p sub m$ are attempted next from left to right.
If one of them matches \fBand\fP
$p sub 0$ matches, the try construct as a whole succeeds.
When either one of $p sub 1~,...,~ p sub m$ fails or $p sub 0$ fails, the environment
is restored \fBexcept\fP
for the variables $id sub 1 ~,..., ~id sub n$ whose values are retained.
It is assumed here that all variables in the window have a well-defined
value at the moment the try construct is entered.
.SH #{unification=sn<<+}. "Unification of pattern and expression language"
.PP
In the preceding sections a careful analysis was made of two backtracking models.
By choosing the right primitive operations we were able to develop a simple,
but powerful backtracking method.
Is it possible to introduce further simplifications?
To do this, we first explicitly formulate our basic assumptions:
.IP \*(MK
A pattern matching model is characterized by a language $PAT$ of patterns
(with associated definition function \*{match\*})
and a language $EXP$ of expressions (with associated definition function \*{eval\*}).
.IP \*(MK
The definition function \*{match\*} assumes the existence of a subject string
and keeps track of the progress of the match by means of an integer-valued cursor.
The only assumption regarding the data type of the subject string is made
by the function \*{litmatch\*} that does the actual string matching.
.LP
These assumptions immediately lead to two guidelines for making
further simplifications:
.IP \*(MK
Unify the languages $EXP$ and $PAT$.
.IP \*(MK
Remove all dependencies on strings as the domain of pattern matching.
.PP
The unification of the languages $EXP$ and $PAT$ amounts to removing the
\fBlinguistic dichotomy\fP
in pattern matching languages, so eloquently described in [Griswold80].
This unification can be achieved by eliminating the language $PAT$ completely.
This is done by modeling all operations in $PAT$ by operations in $EXP$
and by extending $EXP$ when necessary in the process.
Typical examples of this modeling are:
.DS I
.ta 4c 5c
Operation in $PAT$:		Modeled in $EXP$ by:

pattern match fails	\(->	add success/fail
or succeeds		mechanism to $EXP$.
string-literal	\(->	$lit$(string-literal),
		where \*{lit\*} is a built-in string
		matching procedure defined in $EXP$.
alternation	\(->	Boolean \*{or\*}.
subsequentiation	\(->	Boolean \*{and\*}.
action	\(->	expression.
unevaluated expression	\(->	procedure call.
subject assignment	\(->	ordinary assignment.
try construct	\(->	add try construct to $EXP$.
.DE
.PP
It is surprising that this redefinition of $EXP$ also
eliminates all dependencies on string pattern matching:
the special role played by the subject string and cursor is no longer cared for
and the recovery mechanism (embodied in the try construct)
is sufficiently powerful that it permits
the saving and restoring of variables with arbitrary values.
Such variables could be used to describe the progress
of a pattern match in some arbitrary, user-defined, domain.
.PP
These ideas form the conceptual basis for subsequent chapters.
.SH #{sn+}. "References for Chapter #{DESIGN CONSIDERATIONS}"
.so refs/Dahl70
.so refs/Druseikis75
.so refs/Doyle75
.so refs/Farber64
.so refs/Gimpel73
.so refs/Griswold71
.so refs/Griswold76
.so refs/Griswold80
.so refs/Randell75
.so refs/Stewart75
#{sn<;}#{figs<;}
.EC
