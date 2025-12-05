.SH #{sn}. PREFACE
.PP
This document defines the S\s-2UMMER\s0 programming language.
It provides a language overview, a language definition (both formal and informal)
and tutorial examples.
.PP
Chapter #{SUMMER OVERVIEW} gives an overview of the language and
discusses the goals for which it was designed.
In Chapter #{PRELIMINARIES} the techniques and notational conventions that
are used in this manual are introduced.
Much attention is paid to the method used for the formal definition of
the semantics of S\s-2UMMER\s0.
Chapter #{SEMI FORMAL DEFINITION} contains a semi-formal definition
of the S\s-2UMMER\s0 kernel.
This is a small subset of the language that allows a semantic
definition of the whole language using only primitives from that subset.
The description of each language feature consists of
its syntax, informal and formal definition of its semantics, and examples.
In Chapter #{SUMMER LIBRARY} the kernel is extended with
useful data types and associated operations,
such as reals, arrays, tables, files, bit strings, etc.
Some complete, annotated S\s-2UMMER\s0 programs are presented in Chapter
#{ANNOTATED PROGRAMS}.
The interactive debugging system of S\s-2UMMER\s0 is described in Chapter #{INTERACTIVE TRACER}.
And, finally,
a summary of the syntax is given in Chapter #{SYNTAX SUMMARY}.
.PP
Readers who are only interested in getting
a general impression of the language may confine themselves to
Chapter #{SUMMER OVERVIEW} and the
annotated examples in Chapter #{ANNOTATED PROGRAMS}.
Readers who are not interested in the formal definition of the language
may skip Chapter #{PRELIMINARIES} (except Sections #{Syntactical considerations}
and #{Lexical considerations}), and all subsections of
Chapter #{SEMI FORMAL DEFINITION} entitled "Semantics".
.PP
Several people contributed to this effort.
Design and implementation of S\s-2UMMER\s0 were done in close
cooperation with Marleen Sint.
Contributions to the design were made by Jan Heering.
I appreciate the assistance of the following
individuals who have read drafts of this manual:
L.J.M. Geurts,
J. Heering,
F.E.J. Kruseman Aretz,
L.G.L.T. Meertens,
H.J. Sint
and
A.H. Veen.
They pointed out many errors in the various drafts
and made useful suggestions for improving the style and presentation
of this document.
Needless to say, any remaining errors or omissions
are the sole responsibility of the author.
.bp
