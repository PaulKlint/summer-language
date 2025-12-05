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
