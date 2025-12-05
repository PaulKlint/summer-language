
.	\" definitions for font switching:
.	\" syntactic notions:
.	\" 	in text:	\*< and \*>
.	\" 	in display:	.<< and .>>
.	\" (parts of) programs
.	\"	in text:	\*{ and \*}
.	\"	in display	.{{ and .}}
.	\" quoted text:		\*` and \*'
.	\"
.ds < \\s-2<\\s0
.ds > \\s-2>\\s0
.de <<
.in +\\n(PIu
.ft R
.ne 4
.ta 12n 24n 36n 48n
.nf
.na
.{{
..
.de >>
.fi
.ad
.in -\\n(PIu
.}}
..
.ds { \\fI
.ds } \\fP
.de {{
.	\".nr PS -1p
.	\".nr VS -1p
.	\".ps \\n(PSp
.	\".vs \\n(VSp
..
.de }}
.	\".nr PS +1p
.	\".nr VS +1p
.	\".ps \\n(PSp
.	\".vs \\n(VSp
..
.de D{
.LP
.nf
.na
.in +\\n(PIu
.ne 6
.{{
..
.de D}
.in -\\n(PIu
.}}
.fi
.ad
..
.de E{
.na
.nf
.sp -1v
..
.de E}
.fi
.ad
..
.de XP
.sp \\$1
..
.ds ` \(fm
.ds ' \(fm
.	\" miscellaneous characters:
.	\" sc : sequence concatenation
.	\" an : logical and
.	\" el : element of
.ds sc \z\(ci\(pl
.	\" logical and
.ds an &
.	\" element of
.ds el \\s-2\(mo\\s0
.	\" prototype arithmetical op
.ds o1 \z\(ci\(pl
.	\" prototype relational op
.ds o2 \z\(ci\h'0.1m'=
.ds MK "\ \ \s-2\(sq\s0
.	\" ix -- put item in index.
.	\" $1=index name
.	\" $2=item name
.	\" $3=optional layout symbol
.	\" 
.	\" typical usage: .ix C item ,
.	\" which puts "item" in index C, and adds "item," to the text stream.
.de ix
.tm .In \\$1 "\\$2" \\n%
\\$2\\$3
..
.	\" iy -- put item in index, but do not print it
.de iy
.tm .In \\$1 "\\$2" \\n%
..
.rn SH @S
.de SH
.if !'\\$3'-' .ds RH "\\$1  \\$2
.br
.ne 5
.@S
\\fB\\$1  \\$2\\fP
.iy C "\\$1 \\$2"
..
.	\" Redefined "ms" page-title macro
.	\" @C= 0	previous chapter has ended
.	\" @C= 1	at page 1 of new chapter
.	\" @C= 2	at page >1 of new chapter
.	\" @C= 3	at last page of new chapter
.de PT
.lt \\n(LLu
.pc %
.if \\n(@C=2 .if \\n% .if e .tl '%'\\*(LH''
.if \\n(@C=2 .if \\n% .if o .tl ''\\*(RH'%'  
.lt \\n(.lu
..
.de BT
.lt \\n(LLu
.pc %
.if \\n(@C=3 \{\
.nr @C 0 \}
.if \\n(@C=1 \{\
.nr @C 2 \}
.lt \\n(.lu
..
.nr @C 0
.de NC
.LP
.ps +20
.sp 0.5i
.ce 1
\\fB\\$1
.sp 0.5i
.ps -12
.ce 1
\\$2
.sp 0.5i
.ce 1
\\$3\\fP
.sp 0.5i
.ps -8
.iy C  "\\$1 \\$2 \\$3"
.nr @C 1
..
.de EC
.rm LH
.rm RH
.nr @C 3
.bp
..
.rm CH
.	\" NOte macro for refman2.ms
.de NO
.br
.ne 5
.LP
\\fBNotes\\fP
..
.	\" macros for SUMMER library
.de PC 
.br
.ne 6
.sp 0.5
.IP Proc: 10
\\fI\\$2\\$3\\fP
.iy I \\$2
.IP Action: 10
..
.de EX
.br
.ne 5
.IP "Examples:" 10
.ta 6c 6c 6c 6c
..
.de NT
.br
.ne 4
.IP "Notes:" 10
..
.de OP
.br
.ne 6
.sp 1
.IP "Operator:" 10
\\$2\\fI\\$3\\fP
.iy I \\$2
.IP Action: 10
..
.de OB
.br
.ne 8
.sp 1
.IP "Operator:" 10
\\$2\\h'2m-\\w'\\$2'u'\\fI\\$3\\fP
.iy I \\$2
.br
..
.de OM
\\$2\\h'2m-\\w'\\$2'u'\\fI\\$3\\fP
.iy I \\$2
.br
..
.de OE
\\$2\\h'2m-\\w'\\$2'u'\\fI\\$3\\fP
.iy I \\$2
.IP Action: 10
..
.de NX
..
.ds _ \h'-0.2m'\v'0.4m'\(mi\v'-0.4m'\h'-0.2m'
.ds # \s-2#\s0
.	\" initialize eqn
.	\" (redefine $ as DL to avoid clashes
.ds DL \\\$
.EQ
delim $$
gsize 9
.EN
