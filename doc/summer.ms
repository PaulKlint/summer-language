#{figs+>;}
.NC #{SUMMER OVERVIEW=sn+} "AN OVERVIEW OF THE" "SUMMER PROGRAMMING LANGUAGE"
.ds LH "OVERVIEW OF SUMMER
.SH #{SUMMER/intro=sn>1}. Introduction
.PP
The language \s-2SUMMER\s0 has been designed for the solution of problems
in text processing and string manipulation.
It consists of a relatively small kernel
which has been extended in several directions.
The kernel supports:
.IP \*(MK
integers
.IP \*(MK
strings
.IP \*(MK
classes
.IP \*(MK
procedure and operator definitions
.IP \*(MK
success-directed evaluation
.IP \*(MK
control structures
.IP \*(MK
recovery of side-effects.
.LP
It has been extended with:
.IP \*(MK
reals
.IP \*(MK
files
.IP \*(MK
arrays (sequences of values)
.IP \*(MK
tables (associative memories)
.IP \*(MK
pattern matching
.IP \*(MK
string synthesis.
.PP
Pattern matching has been completely integrated
with the success-directed expression evaluation mechanism.
It will be shown that the operations in the kernel are sufficient to allow
generalization of pattern matching in two directions:
.IP \*(MK
Simultaneous pattern matches can be expressed, which mutually
affect each other.
.IP \*(MK
Pattern matching can be generalized to domains other than strings.
.PP
In the following sections the novel
features of \s-2SUMMER\s0 and the motivation for their inclusion in the language
will be discussed.
Furthermore, a simplified version of the pattern matching extension is
described in some detail.
.SH #{SUMMER/evaluation=sn+}. "Success-directed evaluation and control structures"
.PP
The expression evaluation mechanism of \s-2SUMMER\s0 is somewhat unusual and merits
special attention.
Expressions consist of a juxtaposition of operators
(like the addition operator: `\*{+\*}' or the string concatenation operator: `\*{||\*}')
and operands (like the numeric constant 10,
the string constant \*{'abc'\*},
the identifier \*{x\*} or the procedure call \*{p(10,x)\*}).
Some operations can deliver only a value, but others can potentially \fBfail\fP.
The syntactic form of an expression completely determines the steps to be
taken when an operation in a subexpression fails.
The evaluation of simple expressions like
.DS
.{{
a + fibonacci(7)
x := duplicate(c, 3) || ' times'
x > y
x := duplicate(an_identifier(s), 5)
.}}
.DE
is aborted immediately when an operation in a subexpression fails
and failure is signalled to constructs surrounding the expression.
In the last example, failure of the expression \*{an_identifier(s)\*}
may abort evaluation of the whole expression before \*{duplicate\*}
even gets called.
Note that failure is a transient entity and must be captured at the moment
it occurs.
The evaluation of more complex constructs in the case of a failing subexpression
depends again completely on the syntactic form of each construct.
There are three cases:
.IP 1)
The construct is capable of handling the failure itself.
This is the case if the failing expression \*{E\*} occurs in contexts like:
.DS I
.ta 4c
\*{if E then ... else ... fi\*}
\*{while E do ... od\*}
\*{E | ...\*}	{Boolean (McCarthy) \fIor\fP operator}
.DE
.IP 2)
The construct is not capable of handling the failure itself, but
is (perhaps dynamically) enclosed in a construct with that capability, like:
.DS I
.ta 4c
\*{E & ...\*}	{Boolean (McCarthy) \fIand\fP operator}
\*{return(E)\*}	{return value from a procedure}
.DE
In this way failure can be passed to the caller of the procedure
in which the failing expression occurs (see below).
.IP 3)
Neither of the above two cases applies.
This results in abnormal program termination with
the error message `Unanticipated failure'.
In
.DS I
.{{
x := read(input); print(x);
.}}
.DE
the call to the read procedure may fail (on end of file).
This failure will not be detected by the program itself and hence
execution of the program will be aborted.
.PP
This expression evaluation scheme was designed to be
concise and powerful, but at the same time an attempt was made to
protect the programmer against unanticipated or unwanted failure.
.PP
\fBConciseness\fP is obtained in two ways.
.PP
In the first place, by computing a value and a failure signal in the same expression.
This allows, for example
.DS I
.{{
while line := read(input) do ... od
.}}
.DE
instead of
.DS I
.{{
while ~eof(input)
do line := read(input);
   if io_errors(input) then ... fi;
   ...
od;
.}}
.DE
.PP
Secondly, by disregarding the \fBsource of failure\fP and focusing attention
on the \fBabsence of failure\fP (i.e. success)
during the evaluation of the expression.
From now on we will use `succeeds' as a synonym for `does not fail and delivers
a value'.
Consider:
.DS I
.{{
if (read(input) || read(input)) ~= expected
then
   error('Bad input')
fi
.}}
.DE
where `\*{~=\*}' denotes the inequality comparison between strings and
\*{expected\*} has the expected input string as value.
Three sources of failure can be identified here:
the two read operations and the inequality test can fail.
The programmer, however, is in most cases interested only in the fact
that the input file does not conform to his expectations.
This is more manifest in the above formulation than in:
.DS I
.{{
l1 := read(input);
if eof(input)
then
   error('Bad input')
else
   l2 := read(input);
   if eof(input) | (l1 || l2 ~= expected)
   then
      error('Bad input')
   fi
fi
.}}
.DE
In principle, this argument works in two directions:
since the source of failure may be lost, the programmer
may be misled about the \fBactual\fP source of failure.
It is our experience that this seldom happens, and in all cases where the
distinction \fBis\fP important, it can be expressed easily.
.PP
\fBProtection\fP is achieved by prohibiting unanticipated failure.
This turns out to be a frequent source of run-time errors,
which always correspond to `forgotten' or `impossible' failure conditions.
A direct consequence of this protection scheme is that one can write
\fBassertions\fP (i.e. expressions which should never fail) in a program.
A run-time error occurs if such an assertion is false.
.PP
Another noteworthy consequence of this evaluation mechanism is its
ability to let a procedure report failure to any procedure which
called it (in)directly.
This effect is obtained by adhering to the programming convention
that procedure bodies have the form
$E sub 1~&~ ... ~&~E sub n$.
If one of the expressions $E sub i$ fails, this failure is passed to
the caller of the current procedure.
If that calling procedure has the same form,
it will not itself handle the failure but pass it on to its caller.
In this way, low-level procedures need not be aware of failure at all
and high-level procedures can detect the failure and take
appropriate measures.
Some programming languages (e.g. \s-2ADA\s0, \s-2CLU\s0)
have special facilities for handling
exceptions of this kind;
in \s-2SUMMER\s0 they can be handled by the standard expression evaluation
mechanism.
.SH #{SUMMER/caches=sn+}. "Recovery of side-effects"
.PP
For the solution of problems such as heuristic searching, or parsing
languages with context-sensitive or non-LL(1) grammars,
it is often necessary to \fBattempt\fP
a solution and to recover from its side-effects
if that attempt is not successful.
Many schemes have been proposed for the formulation of such \fBbacktracking\fP
algorithms, but most involve either opaque control structures or
allow unsatisfactory control over modifications of the program
state (i.e. global variables).
.PP
S\s-2UMMER\s0 provides a special language construct for recovering from the side-effects
caused by the evaluation of a failing expression.
This construct has the form
.DS I
$bold try~E sub 1~ ,~E sub 2~ ,..., ~E sub n~bold until~E sub 0~bold yrt$
.DE
and is, to a first approximation, equivalent to
.DS I
$(E sub 1~&~E sub 0 )~|~ ... ~|~(E sub n~&~E sub 0 )$
.DE
Before the evaluation of each $(E sub i~&~E sub 0 )$ starts,
the complete program state (values of all variables,
status of all input/output operations) is saved.
If the evaluation of the subexpression succeeds, the saved program state
is discarded and the try construct as a whole succeeds.
If the evaluation fails, the saved program state is restored
and evaluation of $(E sub {i+1}~&~E sub 0 )$ is attempted in a similar manner.
The try construct fails if none of the subexpressions succeeds.
Completely automatic backtracking can be achieved by nesting try constructs.
This simple scheme is well suited to the formulation of
problems occurring in pattern matching applications
as will be seen in #{SUMMER/generalized pm}.
.PP
There are two exceptions to the rule that the whole program state
is restored when an expression contained in a try construct fails:
.IP \*(MK
Operations on an input/output stream
that corresponds to an interactive terminal
are not recovered.
In many situations it is not desirable to recover these streams,
and in some cases the meaning of such a recovery may be non-obvious
or confusing.
In \s-2SUMMER\s0 these streams can be used
to interactively control and monitor the backtracking process.
.IP \*(MK
The local variables of the procedures in which the try construct occurs
are not recovered.
In this way information about the reason for failure
can survive the failure itself.
In Sction #{recovery model} a similar effect was achieved using
a `window' of variables whose values were never recovered.
.PP
It is obvious that saving and restoring complete program states would lead to
intolerable inefficiencies when implemented naively.
Fortunately, there exists an implementation technique that eliminates
most of the run-time overhead involved.
The \fBrecovery cache\fP,
which was originally invented to increase software reliability
[Randell75],
has been adapted to act as a device for monitoring program state
modifications in those situations where it may be necessary
to restore a previous program state
(i.e. while evaluating expressions contained in a try construct).
A recovery cache consists of (name, value) pairs.
The name part may refer to simple variables, array elements,
class components or input/output streams.
A new cache is created when the evaluation of a try construct begins, and
from that moment, all assignments to variables are monitored.
Whenever an assignment is about to be made to a variable whose name does
not yet occur in the cache, its name and its old value \fBbefore\fP
the assignment are entered into the cache.
Assignments to components of structured objects (arrays, class instances) and
modifications of input/output streams are registered in a similar way.
The recovery cache is discarded completely
if the evaluation of the try construct succeeds,
but in the case of failure, the information in the cache is used to
restore the program to its state at the moment that the cache
was created (i.e. the try construct was entered).
Since recovery caches may be nested, `discarding' may mean:
merging the information in the current cache with that in the previous one.
In this manner, the information in the previous cache is still
sufficient to describe all modifications which have been made since
that cache was created.
.SH #{SUMMER/procedures=sn+}. "Procedures, operators and classes"
.PP
In this section the remaining features of the \s-2SUMMER\s0 kernel
are summarized.
.PP
\fBProcedures\fP
have a fixed number of parameters, which are, in principle, passed by value.
Procedures may either return zero or more values, or they may fail.
The former is achieved by a return-expression of the form
\*{return\*} or \*{return(expression)\*}.
The latter is achieved by a return-expression of the form \*{freturn\*}
(failure return).
Returning a failing expression is equivalent to a failure return
(e.g. \*{return(3 > 4)\*} is equivalent to \*{freturn\*}).
.PP
An \fBoperator\fP is defined by associating a user-defined operator symbol
with a procedure which has one or two parameters.
.PP
\fBClasses\fP are the only available data structuring mechanism
and have been inspired by the class concept in \s-2SIMULA\s0 [Dahl70].
A class declaration describes the properties of a group of related entities.
One particular entity is described by \fBinstantiating\fP
(i.e. making an \fBinstance\fP of) the class
declaration and filling in the specific properties of that entity.
For example, all entities of the class \fIperson\fP may have
a \fIname\fP and an \fIage\fP.
An individual person can be described by an instance of the class \fIperson\fP
with the appropriate details (e.g. `John', 36) filled in.
This scheme equally applies to built-in classes like \*{integer\*} and
\*{string\*}, as well as to user-defined classes like the class \*{person\*}
just described.
\fBAll values in \s-2SUMMER\s0 are thus instances of some class\fP.
.PP
Nothing has so far been gained when comparing classes with, for example,
records in \s-2PASCAL\s0.
The major difference between the two stems from the fact that \s-2PASCAL\s0 records
are \fBpassive\fP
(i.e. a record resembles a variable and is only a container of values)
and \fBunprotected\fP
(i.e. all components of a record are freely accessible)
while classes are not.
A class can be considered to be \fBactive\fP, since it may contain locally
declared procedures to manipulate the information in each instance
of that class (e.g. increment a person's age)
or to perform computations based on that information.
A class is \fBprotected\fP since the access to the individual information
in the class instance is completely controlled by its class definition.
A simple definition of \fIperson\fP might be:
.DS I
.{{
class person(name, age)
begin fetch name, age;
      store age;
end person;
.}}
.DE
Here \*{name\*} and \*{age\*} may be used from the outside of the class instance,
but only \*{age\*} may be modified, i.e. may occur on the left hand side
of an assignment.
Some examples of the use of this class are:
.DS I
.{{
friend := person('John', 36);
print(friend.name);
friend.age := friend.age + 1;
.}}
.DE
A more restrictive version of \*{person\*} might be:
.DS I
.{{
class person(name, age)
begin fetch name, age;
      store age : grow_older;
      proc grow_older(new_age)
      (  if new_age >= age
         then
            age := new_age
         else
            print('Did you find the elixir of life?')
         fi
      );
end person;
.}}
.DE
This definition prescribes that all assignments to \*{age\*}
are channeled through the procedure \*{grow_older\*} which
ensures the monotonicity of age.
Instances of this class are used in precisely the same 
manner as in the examples given previously.
.PP
A second example of class declarations has to do with the generation 
of unique labels of the form `L1', `L2' and so on.
This might, for example, be used in a compiler.
A declaration for \*{UniqueLabel\*}s looks like:
.DS I
.{{
class UniqueLabel(prefix, start)
begin fetch generate, reset;
      var progress;
      proc generate()
      (  progress := progress + 1;
         return(prefix || string(progress))
      );
      proc reset() ( progress := start );

init:  progress := start
end UniqueLabel;
.}}
.DE
Some applications of this class are:
.DS I
.{{
L := UniqueLabel('L000', -1);
M := UniqueLabel('M', 10);
print(M.generate);	# prints `M11' #
print(L.generate);	# prints `L0000' #
print(M.generate);	# prints `M12' #
M.reset;
print(M.generate);	# prints `M11' #
.}}
.DE
.br
.ne 5
.LP
Summarizing, a class declaration consists of:
.IP \*(MK
A class name and a list of formal parameters.
The class name is used as name for the creation procedure
for instances of the class.
The actual parameters are used to provide initial values for that instance.
.IP \*(MK
Fields, which are used either to contain information related to the instance
(e.g. the \*{name\*} and \*{age\*} fields in
an instance of the class \*{person\*}),
or to hold information local to the class instance
(the variable \*{progress\*} in an instance of \*{UniqueLabel\*}).
Permissions for accessing and/or modifying the fields of a class instance
from the outside have to be stated explicitly by using \*{fetch\*} and \*{store\*}.
.LP
The fields of a class are accessed by means of the `dot' notation.
The type of the left operand in a field selection is used to
disambiguate `overloaded' fields, for which definitions occur in
more than one class.
.PP
Some additional features exist in the language to accommodate the use of classes.
In sequences like
.DS I
.{{
a := S.x; b := S.y; c := S.z(10)
.}}
.DE
it is convenient if the prefix `\*{S.\*}' can be factored out.
P\s-2ASCAL\s0 uses the construct
.DS I
\fBwith\fP \*{record_variable do begin ... end\*}
.DE
for this purpose.
All field references that occur inside `\*{begin ... end\*}'
are automatically prefixed with \*{record_variable\*}.
In this notation the above example would become:
.DS I
\fBwith\fP \fIS\fP \fBdo\fP \*{begin a := x; b := y; c := z(10) end\*}
.DE
Unfortunately, this is not sufficient for the applications we have in mind,
where it is not unusual for many procedures to operate on the same class
instance.
This is illustrated by a set of parsing procedures that operate
on one subject string.
The \s-2PASCAL\s0 approach has the disadvantage that this common class instance
must either be passed as an argument to all procedures involved or must be assigned to
a global variable;
all procedure bodies must in that case be enclosed
in a \fBwith\fP construct.
This problem can be circumvented as follows.
The \s-2SUMMER\s0 construct$"" sup 2$
.FS
2) Inspired by the `scan S using E' construct in Icon
[Griswold79].
.FE
.DS I
.{{
scan S for E rof
.}}
.DE
introduces a new incarnation of a common variable (`\*{subject\*}')
each time the construct
is encountered at run-time and assigns the class instance \*{S\*} to it.
All occurrences of fields from the class to which \*{S\*} belongs are
now prefixed with the common global variable
in the same way as is done in \s-2PASCAL\s0.
The \fBscan\fP construct is more general, however, in the sense that it
not only affects \*{E\*} itself,
but also all procedures called directly or indirectly
as a result of the evaluation of \*{E\*}, while
in \s-2PASCAL\s0 the effect is restricted to the expressions which are
statically enclosed in the body of the \fBwith\fP construct.
If the scan construct is used in a nested fashion, the previous
value of the common global variable is saved and restored properly on exit from
the current scan construct.
This also applies to the case when the scan construct is left
prematurely by means of a return statement.
In summary,
the scan construct introduces a restricted form of \fBdynamic binding\fP.
.SH #{SUMMER/pm extension=sn+}. "A pattern matching extension"
.SH #{SUMMER/string pm=sn>1}. "String Pattern Matching"
.PP
We will now show how a string pattern matching system
can be build on top of the \s-2SUMMER\s0 kernel.
Pattern matching is done on a string
\*{text\*} which is indexed by an integer \*{cursor\*}.
For the sake of this discussion a very simple system will be defined,
which only supports the following operations:
.IP "\*{text\*}:" 12
Gives the value of \*{text\*}.
.IP "\*{cursor\*}:" 12
Gives the current value of \*{cursor\*}.
.IP "\*{lit(S)\*}:" 12
Literally recognize the string \*{S\*}.
If \*{S\*} occurs as substring in \*{text\*} at the current cursor
position, deliver \*{S\*} as value and move the cursor beyond \*{S\*}.
Otherwise report failure.
.IP "\*{break(S)\*}:" 12
Recognize a substring of \*{text\*} that starts
at the current cursor position and consists entirely of
characters not occurring in \*{S\*} and is followed by a
terminating character which does occur in \*{S\*}.
If such a substring exists,
return it (without the terminating character) and
move the cursor to the terminating character.
Fail if such a substring does not exist.
.IP "\*{span(S)\*}:" 12
Recognize the longest non-empty substring of \*{text\*} that starts
at the current cursor position and consists entirely of characters
which occur in \*{S\*}.
If such a substring exists, then return it as value and move the cursor
beyond it.
Fail if such a substring does not exist.
.br
.ne 8
.LP
The following class definition implements this pattern matcher:
.sp 1
.D{
.{{
class scan_string(text)
begin fetch lit, break, span, text, cursor;
      var cursor;
      proc lit(s)
      (  if cursor + s.size <= text.size & text.substr(cursor, s.size) = s
         then
            cursor := cursor + s.size ;
            return(s)
         else
            freturn
         fi
      );
.br
.ne 10
      proc break(s)
      (  var newcursor := cursor;
         while newcursor < text.size 
         do if contains(s, text[newcursor])
            then
               var result := text.substr(cursor, newcursor - cursor);
               cursor := newcursor;
               return(result)
            fi;
            newcursor := newcursor + 1
         od;
         freturn
      );
.br
.ne 10
.sp 0.5
      proc span(s)
      (  var newcursor := cursor;
         while newcursor < text.size & contains(s, text[newcursor])
         do
            newcursor := newcursor + 1
         od;
         if newcursor > cursor
         then
            var result := text.substr(cursor, newcursor - cursor);
            cursor := newcursor;
            return(result)
         else
            freturn
         fi
      );
.br
.sp 0.5
.ne 10
      proc contains(s, c)
      (  var c1;
         for c1 in s
         do
            if c1 = c then return fi;
         od;
         freturn;
      );
init:  cursor := 0;
end scan_string;
.}}
.D}
.sp 0.5
The following example illustrates how identifiers starting with
the letter `\*{X\*}' can be recognized:
.sp 0.5
.D{
.{{
proc identifier(s)
( var t := scan_string(s);
  return(t.lit('X') & (t.span(letter_or_digit) | t.lit('')))
)
.}}
.D}
.sp 0.5
In these examples we assume
\*{letter = 'abcdefghijklmnopqrstuvwxyz'\*},
\*{digit = '0123456789'\*} and
\*{letter_or_digit = letter || digit\*}.
Note that the normal Boolean operators \fIand\fP (`\*{&\*}') and
\fIor\fP (`\*{|\*}') are used
for combination.
Hence there will be no backtracking or reversal of effects if the match fails.
The expression \*{t.lit('')\*} always succeeds and covers the case
when the identifier consists of a single \*{'X'\*}.
This example can be rewritten in a more concise form if we use
the scan construct:
.sp 0.5
.D{
.{{
proc identifier(s)
( scan scan_string(s)
  for
    return(lit('X') & (span(letter_or_digit) | lit('')))
  rof
)
.}}
.D}
.sp 0.5
.PP
A final example may illustrate the use of the value returned by
pattern matching procedures.
The problem is to extract all letters from a given string.
For example \*{'a,b,c'\*} gives \*{'abc'\*}.
A procedure to achieve this can be defined as follows:
.sp 0.5
.D{
.{{
proc extract_letter(s)
( var result := '';
  scan scan_string(s)
  for
    while break(letter) 
    do result := result || span(letter) od
  rof;
  return(result)
)
.}}
.D}
.sp 0.5
.PP
In \s-2SUMMER\s0, pattern matching and backtracking have been completely separated.
It came as a shock to us to discover that the majority of pattern matching
problems which we had solved previously by means of implicit backtracking,
could be solved without any backtracking at all!
Many problems of practical importance can be solved using LL(k) or LR(k)
techniques and are at worst only locally ambiguous.
Using completely automatic backtracking as a parsing technique
is rather wasteful under such circumstances and
this suggests that the close interaction between pattern matching
and backtracking, which can be found in several languages, should be
reconsidered.
See Chapter #{DESIGN CONSIDERATIONS} for an extensive discussion
of this topic.
.PP
How can pattern matching with automatic backtracking be obtained?
Consider the expression:
.DS I
.{{
(lit('ab') | lit('a')) & lit('bc')
.}}
.DE
In the pattern matcher developed above, the alternative \*{lit('a')\*}
is discarded as soon as a substring starting with \*{'ab'\*} is encountered,
since we are using McCarthy \fIand\fP and \fIor\fP operations {#{SUMMER/evaluation}}.
The string \*{'abc'\*} cannot be recognized in this way.
But if we rewrite the expression as
.DS I
.{{
try lit('ab'), lit('a')
    until lit('bc')
yrt
.}}
.DE
then the side-effect recovery mechanism implicit in the try construct
automatically restores the initial cursor value 
and attempts the second alternative if \*{lit('bc')\*} fails the first time.
No special attention need be paid to the cursor:
it is an ordinary variable which is saved and restored automatically by the
try construct just as any other variable.
.SH #{SUMMER/generalized pm=sn+}. "Generalized pattern matching"
.PP
In most pattern matching systems there is only one subject string
involved in the pattern match.
In our scheme, this restriction can be removed without introducing
any new concepts as an example will show.
The following (rather artificial) problem is to ensure that
two strings $S1$ and $S2$ conform to the following rules:
.IP \*(MK
$S1$ is of the form $c sub 1 ; c sub 2 ;~ ... ~;c sub n ;$
where $c sub i$ is a (perhaps empty) sequence of arbitrary characters
except for the character `;'.
.IP \*(MK
For a given $S1$, $S2$ has the form $d sub 1 d sub 2~ ... ~d sub n$,
and either $d sub i~=~c sub i$ or $d sub i~=~reverse(c sub i )$ holds.
Acceptable values for $S2$ with $S1$ equal to \*{'ab;cde;f;'\*}
are \*{'abcdef'\*}, \*{'abedcf'\*}, \*{'bacdef'\*} and \*{'baedcf'\*}.
.br
.ne 4
.LP
The following program checks whether a given $S1$ and $S2$ satisfy this relation:
.D{
.{{
s1 := scan_string(S1);
s2 := scan_string(S2);
scan s1
for
   while (n := break(';')) & lit(';')
   do
      if ~ scan s2 for lit(n) | lit(reverse(n)) rof
      then
            error('check fails')
      fi
   od
rof;
if s1.cursor = S1.size & s2.cursor = S2.size
then
   print('check succeeds')
else
   error('check fails')
fi
.}}
.D}
.PP
Each \*{scan_string\*} object maintains its own cursor.
The innermost scan construct operates each time on the same
\*{scan_string\*} instance \*{s2\*} whose cursor value gets modified.
This allows the innermost pattern match to continue
where it left off the previous time.
.PP
From the preceding paragraphs it will be clear that pattern matching
as presented here, does not depend on the fact that strings are used
as the basic unit of recognition.
One can, for example, easily imagine pattern matching on an array of strings.
The `cursor' must then be replaced by a pair of values to maintain the
current position, and basic scanning procedures like \*{xlit\*}, \*{ylit\*},
\*{xspan\*} and \*{yspan\*} must be defined.
It may be expected that a system like \s-2ESP\s0$"" sup 3$ [Shapiro74]
can be defined in a straightforward manner using the primitives from
the \s-2SUMMER\s0 kernel.
.SH #{SUMMER/related work=sn<+}. "Related work"
.PP
S\s-2UMMER\s0 was inspired by and profited from ideas in
\s-2SNOBOL\s04 [Griswold71]
and SL5 [Griswold76].
The method adopted for the integration of
pattern matching and expression evaluation
(see Chapter #{DESIGN CONSIDERATIONS})
was inspired by Icon [Griswold79].
.PP
The major ideas introduced by \s-2SUMMER\s0 are
the evaluation model which prohibits unanticipated failure,
the recovery from side-effects in failing expressions,
the use of recovery caches as an implementation technique
and the separation of pattern matching and backtracking which
allows more general pattern matching in domains other than strings.
.SH #{sn+}. "References for Chapter #{SUMMER OVERVIEW}"
.so refs/Dahl70
.so refs/Griswold71
.so refs/Griswold76
.so refs/Griswold79
.so refs/Klint80
.so refs/Randell75
.so refs/Shapiro74
#{sn<;}#{figs<;}
.rm LH
.rm RH
.bp
