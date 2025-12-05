.SH "PREFACE FOR PART II"
.PP
The second part of this monograph is devoted to the
definition of the \s-2SUMMER\s0 programming language.
It provides both a formal and informal language definition 
and tutorial examples.
.PP
In Chapter #{PRELIMINARIES} the techniques and notational conventions that
are used in the definition are introduced.
Much attention is paid to the method used for the formal definition of semantics.
Chapter #{SEMI FORMAL DEFINITION} contains a semi-formal definition
of the \s-2SUMMER\s0 kernel.
This is a small subset of the language on which the semantic definition
of the whole language can be based.
The description of each language feature consists of
its syntax, an informal as well as a formal definition of its semantics, and examples.
In Chapter #{SUMMER LIBRARY} the kernel is extended with
useful data types and associated operations,
such as reals, arrays, tables, files, bit strings, etc.
Some complete, annotated \s-2SUMMER\s0 programs are presented in Chapter
#{ANNOTATED PROGRAMS}.
And, finally,
a summary of the syntax is given in Chapter #{SYNTAX SUMMARY}.
.PP
Readers who are only interested in getting
a general impression of the language may confine themselves to
Chapter #{SUMMER OVERVIEW} in Part I and the
annotated examples in Chapter #{ANNOTATED PROGRAMS}.
Readers who are not interested in the formal definition of the language
may skip Chapter #{PRELIMINARIES} (except Sections #{Syntactical considerations}
and #{Lexical considerations}), and all subsections of
Chapter #{SEMI FORMAL DEFINITION} entitled `Semantics'.
. \"	.PP
.	\"	Several people contributed to this effort.
.	\"	Design and implementation of \s-2SUMMER\s0 were done in close
.	\"	cooperation with Marleen Sint.
.	\"	Some contributions to the design were made by Jan Heering.
.	\"	I appreciate the assistance of the following
.	\"	individuals who read drafts of this manual:
.	\"	(* add list *)
.	\"	F.E.J. Kruseman Aretz,
.	\"	L.J.M. Geurts,
.	\"	J. Heering,
.	\"	L.G.L.T. Meertens,
.	\"	H.J. Sint,
.	\"	A.H. Veen.
.	\"	They pointed out many errors in the various drafts
.	\"	and made useful suggestions for improving the style and presentation
.	\"	of this document.
.	\"	Needless to say, any remaining errors or omissions
.	\"	are the sole responsibility of the author.
.bp
