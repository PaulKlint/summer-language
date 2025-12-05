. Ib -- Index begin
.de Ib
.ds @x
.ds @y
.nf
.in +8n
..
. In -- Index entry
. $1 = index name
. $2 = item name
. $3 = page number
. $4 = - for begin of chapter
.de In
.ie 'C'\\$1' \{\
.	\"	.tc .
.nf
.	\"	.ta \\n(.l-\\w'\\$3'u-1
.	\"	\\$2 \t \\$3
.ie '\\$4'-' \{\
.sp 1
.ne 4
.in -8n
\\$2   \\fB\\$3\\fP
.in +8n
.sp 1 \}
.el \\$2   \\fI\\$3\\fP
.br
.fi \}
.el .ie '\\*(@x'\\$2' .as @y ", \\$3
.el \{\
.na
.in 4
.ti -4
\\*(@x \\*(@y
.br
.ds @y \\$3
.ds @x "\\$2
.ad
. none\}
..
. Ie -- Index end
.de Ie
.na
.in 4
.ti -4
\\*(@x \\*(@y
.br
.ad
..
