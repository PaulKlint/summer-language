#{figs+>;}
.NC #{EPILOGUE=sn+} "ASSESSMENT" " "
.ds LH ASSESSMENT
.SH #{sn>1}. "Looking backward"
.PP
We have come a long way since we began considering string processing
in Chapter #{INTRODUCTION}.
In Chapter #{DESIGN CONSIDERATIONS}, formal techniques were
used to analyze the pattern matching method of \s-2SNOBOL\s04.
Special attention was paid to
the confusion that can arise from side-effects due to failing
attempts during a pattern match.
As a result of this analysis, a new model for side-effect recovery
was designed and formally described.
.PP
This model, together with new insights of
how string processing should be incorporated into a programming language,
led to the design of the language \s-2SUMMER\s0 (Chapter #{SUMMER OVERVIEW}).
In order to define the semantics of \s-2SUMMER\s0 formally,
an improved method for operational language definitions was
developed in Chapter #{FORMAL LANGUAGE DEFINITIONS}.
.PP
In the current chapter we evaluate the results of this research
and indicate some directions for further investigation.
.SH #{sn>1}. "S\s-2UMMER\s0 as a language"
.PP
Language design and compromise are almost synonymous.
A language designer has to reconcile simplicity, expressive power,
orthogonality, economy of concepts, anticipated application area,
tradition, style, taste,
implementation considerations, experience, enthusiasm and
available time (to mention but a few) with each other when designing a new language.
Compromises are thus inevitable.
Evidence of this kind of compromise can also be found in \s-2SUMMER\s0.
Some weak points of \s-2SUMMER\s0 are:
.IP \*(MK
Certain useful language features (like procedure variables
and advanced array operations)
were omitted in favour of simplicity.
.IP \*(MK
A very general notion of `subject' was included in the language.
This generality has (so far) not been fully exploited.
.IP \*(MK
Try-expressions do not recover the values of local variables in the `current'
procedure.
This inelegant way of obtaining information from an attempt that failed
was dictated by implementation considerations.
It would have been more elegant to include in the try-expression
an explicit list of variables whose values should \fBnot\fP be recovered.
.IP \*(MK
The mechanism to control access to class instances
(fetch- and store-associations) is too complicated.
.IP \*(MK
The string scanning functions in \s-2SUMMER\s0 are based on the functions for lexical
scanning as found in \s-2SNOBOL\s04.
It would have been better to design a new set of higher level primitives
for string scanning.
.IP \*(MK
Some cosmetic changes should be made to the syntax.
.IP \*(MK
The system of dynamic types used is adequate.
However, a slightly more restrictive type system
would make static type checking much easier.
In such a system, variables may still have values of arbitrary type, but
as soon as a variable has received a value of a certain type,
only values of that particular type may be assigned to it.
.LP
Some strong points of \s-2SUMMER\s0 are:
.IP \*(MK
Expression evaluation and pattern matching have been completely unified,
resulting in a substantial reduction in the number of language primitives.
.IP \*(MK
Incorporation of failure handling into the expression evaluation mechanism
leads to a concise notation, since the same expression can either
compute a result or produce a failure signal.
.IP \*(MK
The language is based on a consistent view of side-effect recovery, thus
eliminating the problems with immediate/conditional side-effects found
in \s-2SNOBOL\s04.
It turned out that the `recovery cache' could be used effectively to implement
side-effect recovery.
.IP \*(MK
The use of `classes' as a data abstraction mechanism
was a good choice.
Amongst other things, this allowed us to cast the notion of `subject string'
and `string pattern matching' into a more general framework.
.LP
Despite the mentioned shortcomings, experience shows that \s-2SUMMER\s0 is
a convenient, easy to learn, language.
At the moment of this writing,
the language has been used for the implementation of assemblers,
compilers, preprocessors, a parser generator [Florijn81],
a system for automatic type inference and data flow analysis [VanDijk83],
a language-independent pretty-printing system [Kroeze82],
a generator for simulators for microprogrammable computer architectures
[Oostman82],
a compiler for a subset of \s-2SUMMER\s0 that generates code for
the Manchester data flow machine [Veen85]
and a type checker for an algebraic specification formalism.
.SH #{sn+}. "The \s-2SUMMER\s0 implementation"
.PP
\s-2SUMMER\s0-programs are compiled into abstract machine programs.
These are subsequently executed by an interpreter
[Klint79a, Klint79b, Klint81b].
The compiler is written in \s-2SUMMER\s0 itself [Sint80].
.PP
The \s-2SUMMER\s0 implementation is reliable, gives good error messages, but is slow.
Users tend to complain mostly about long compilation times.
The compiler is slow because it is written in \s-2SUMMER\s0 itself
(and is thus being interpreted)
and because its two constituent parts (a parser and a code generator)
communicate with each other via a common data structure
whose size depends on the size of the source program.
For large programs there is considerable overhead due to garbage collections
during compilation.
Recently, an experimental version of the compiler has been constructed
that allows separate compilation of programs [Bekius84].
.PP
In most cases, the efficiency of \s-2SUMMER\s0 programs seems to be acceptable.
Generally speaking, one can say that programs which run slowly
are those which perform low level operations and do not use the higher level
facilities offered by the language.
.SH #{sn+}. "Use of a formal definition"
.PP
The semantics of \s-2SUMMER\s0 were formally described after the language
had been completely designed.
A considerable effort was required to develop a formal description method
and to produce a formal description of the language.
This effort, though much larger than anticipated, payed off:
much insight was gained into the structure of the language and
into errors or omissions in the design.
Three lessons can be learned from this:
.IP \*(MK
Language design and formal definition should proceed hand in hand.
.IP \*(MK
The language implementation should be derived (in some automatic way)
from the formal definition.
In that way one can avoid inconsistencies or incompatibilities
between definition and implementation.
.IP \*(MK
Several language definition methods first convert the program to be defined
to an intermediate form that is more suitable to operate on.
The `parse expressions' used in the formal definition of \s-2SUMMER\s0
operate directly on the source text of the program to be defined,
thus eliminating the extra conversion step and simplifying the definition.
.LP
Recently, we have experimented with the use of algebraic specification
techniques for defining programming languages [Bergstra85].
.XP 0.5
.SH #{sn<+}. "Looking forward"
.PP
The research described in this monograph can be continued in the
direction of both
\fBexecutable language definitions\fP and \fBprogramming environments\fP.
.PP
\fBExecutable language definitions\fP are a valuable tool for the language
designer as was explained in Chapter #{FORMAL LANGUAGE DEFINITIONS}.
The method used in the \s-2SUMMER\s0 definition could be improved in several ways:
.XP 0.25
.IP \*(MK
The method is not suited to the formulation (or proof) of
properties of a given language definition.
This can be cured by eliminating some operational aspects from the method.
.IP \*(MK
The method leads to intolerably inefficient implementations.
There are two major sources of this inefficiency.
First of all, statements are parsed every time they are executed.
This can be avoided in several ways:
one can either translate the source text to an intermediate form
or maintain a `cache' of pieces of source text that have already been parsed.
Secondly, a very general and expensive technique is used
to implement environment modifications.
Special properties of a language
(for example, the property that environments can be implemented on a stack)
are not exploited.
It is a non-trivial task to extract such optimization information
from a given language definition.
.XP 0.25
.PP
A \fBprogramming environment\fP is an interactive computer system
dedicated to the development and documentation of programs.
When \s-2SUMMER\s0 was being designed the idea was, that, for the sake of portability,
its interface with the host operating system should be kept as simple as possible.
Thinking on a dedicated \s-2SUMMER\s0 environment started only after the
design of the language was complete.
It quickly turned out that the original austere file system interface
was inadequate for use in an integrated environment.
More specifically, one would like to exploit the `class' mechanism
not only locally in programs, but also at the level of external files.
Besides leading to an integration of `internal' and `external'
data types, this further suggested the use of \s-2SUMMER\s0 as a command language.
At the same time, we noted a strong similarity between the language
of the symbolic debugger in the \s-2SUMMER\s0 system and \s-2SUMMER\s0 itself.
.PP
Although the analogies were strong in both cases, it was also evident
that \s-2SUMMER\s0 could not play the role of a unified command/\%programming/\%debugging
language without extensive modification.
The advantage to be gained was clear: a highly uniform
programming environment.
But the problems involved seemed many and we therefore decided to
concentrate, not on the modification of \s-2SUMMER\s0,
but, more generally, on the basic principles underlying
\fBmonolingual\fP systems, i.e. systems in which the command language,
the programming language, and the language of the symbolic debugger
are identical.
This has resulted in [Heering81].
.PP
Even within the monolingual framework,
it remains necessary to add new application languages to a system.
It seems therefore logical to consider \fBlanguage definitions\fP
as the unifying language level in a system.
As a preparation for this line of research,
[Heering83b] investigates how a programming environment
could be based on language definitions and
[Klint83] gives
a comparison of three existing, language-independent programming environments:
Mentor [Donzeau-Gouge75, Donzeau-Gouge80],
The Synthesizer Generator [Reps82, Reps83] and Ceyx [Hullot83].
More recently, an algebraic definition has been constructed
of a simple programming language [Bergstra85]:
it defines lexical analysis, parsing, syntax tree construction,
type checking and execution of programs.
.XP 0.5
.SH #{sn+}. "References for Chapter #{EPILOGUE}"
.so refs/Bekius84
.so refs/Bergstra85
.so refs/Donzeau-Gouge75
.so refs/Donzeau-Gouge80
.so refs/Heering81
.so refs/Heering83a
.so refs/Heering83b
.so refs/Hullot83
.so refs/Klint79a
.so refs/Klint79b
.so refs/Klint81b
.so refs/Klint83
.so refs/Kroeze82
.so refs/Oostman82
.so refs/Reps82
.so refs/Reps83
.so refs/Sint80
.so refs/VanDijk83
.so refs/Veen85
#{sn<;}#{figs<;}
.EC
