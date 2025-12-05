.TH PGEN 1
.SH NAME
pgen \- generate a parser with error recovery.
.SH SYNOPSIS
pgen [ \-n ] [ \-i ] [ \-u ] [ \-sep ] file.syn
.SH DESCRIPTION
.I pgen
is a parser generator that reads a syntax description from 'file.syn'.
After checking the correctness of the given grammar, it generates a
parser written in SUMMER for the given grammar.
.PP
The filename 'file' is meant to be the basename of the used '.syn' file.
.PP
.I pgen
has four options:
.TP
.B \-i
.I pgen
will not remove the intermediate files of the generator.
.TP
.B \-n
.I pgen
inserts the file 'file.ns' in order to
enable the user to write his own lexical procedures.
By default
.I pgen
would insert 'pglib.ns', which contains the default scanner procedures.
.TP
.B \-u
.I pgen
inserts user-supplied declarations of global procedures, classes and
variables from the file 'file.ud'.
.TP
.B \-sep
.I pgen
normally generates a main program with the name of the start symbol
of the input grammar.
When the
.B \-sep
flag is set only a procedure declaration is generated for the start
symbol and all other procedures for scanning and user-supplied actions
are assumed to be made part of the program by explcit include-statements.
This flag excludes the use of either the
.B \-n
or
.B \-u
flag.
.PP
The generated parser is left on the file 'file.sm' and can be translated
by
.I sumc
.SH FILES
  file.syn            syntax definition
  file.sm             generated parser
  file.ns             user defined nextsym procedure
  file.ud             user defined declarations

  file.syn.er         error messages from the generator.
  file.syn.tb         generated tables
  file.syn.fs         generated first-sets
  file.syn.rs         generated remainder-sets
  file.syn.co         generated code
.SH AUTHORS
G.H. Florijn, G.H. Rolf (IHBO De Maere)
