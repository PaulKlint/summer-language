.SH #{sn+>1}. "Word tuples"
.SH #{sn>a}. "Overall description" -
.PP
This program reads a number of files and for each different
pair or triple of consecutive words the frequency is counted.
A word is a sequence of upper and lower case letters.
The result of the program is an alphabetically ordered frequency table.
.PP
The program illustrates:
\*<for-expression\*>s {#{For expressions}},
\*<scan-expression\*>s {#{Scan expressions}},
\*{scan_string\*} operations (\*{break\*}, \*{span\*}) {#{Lib/scan_string}},
multiple assignment {#{Dyadic expressions}}
and \*{table\*}s {#{Lib/table}}.
.br
.ne 10
.SH #{sn+}. "Source text" -
.LP
.nm 1
.nf
.so ../demo/tuples.so
.nm
.fi
.SH #{sn+}. Input -
.PP
The source text of the programs `tuples.sm' (the above program)
and `flex.sm' {#{Flexible arrays}}.
.SH #{sn+}. Output -
.DS L
.ta 30n
.so ../demo/tuples.out.so
.DE
.SH #{sn+}. "Detailed description" -
.PP
.IP 1 6
Comment
.IP 2-4 6
Constant declaration for \*{letter\*} and \*{interesting\*}.
The former is used to recognize words in the text (line 8), the latter
is used as threshold while printing the frequency table (line 34).
.IP 5-6 6
The procedure \*{combine\*} concatenates its arguments separated by
the character `/' and is used in lines 21, 23 and 26 to build
table keys consisting of two or three words.
.IP 7-9 6
The procedure \*{word\*} is the basic procedure for recognizing `words'.
It operates on the current subject (established in line 17)
and first locates the beginning of the next word by \*{break(letter)\*}
which moves the cursor to a position just before a letter.
The operation \*{span(letter)\*} spaces over the longest letter sequence
in the subject and delivers that sequence as (string) value.
This value is ultimately returned.
Note that \*{break\*} fails if there are no more letters in the subject.
In that case the procedure \*{word\*} fails and the while loop in line 20
is terminated.
.IP 10-38 6
Main program with argument \*{file_names\*}, which contains
an array of string values corresponding to the actual parameters
of program \*{tuples\*}.
If, for example, the program was called with the
two arguments \*{tuples.sm\*} and \*{flex.sm\*},
the argument \*{file_names\*} has the array \*{['tuples.sm', 'flex.sm']\*} as value.
The \*<for-expression\*> in line 12 iterates over the values in this array.
.IP 11 6
Variable declarations for \*{f\*}, \*{tuple\*} and \*{tupletab\*}.
Note how \*{tupletab\*} is initialized to an instance of class \*{table\*},
in this case of estimated size 1000 and default value 0.
It is used to keep account of the occurrence of pairs and triples.
The default value 0 is a convenient initial value for tuples that were not
encountered before.
.IP 12-31 6
The consecutive values in the array \*{file_names\*} are assigned to \*{f\*}.
.IP 13 6
Declaration for local variable \*{data\*}.
.IP 14 6
Create an instance of class \*{file\*} with the current value of \*{f\*}
as name and access type \*{'r'\*} (for read access).
If the file can be opened, an instance of class file is assigned to
variable \*{data\*}.
Otherwise the operation fails and an error message is printed (line 15).
.IP 17-28 6
Scan expression, which establishes the value of \*{data\*} (a file) as
subject.
Operations like \*{span\*} and \*{break\*} now operate on the value of \*{data\*}.
In the current context the expression \*{break(letter)\*} is equivalent
to \*{data.break(letter)\*}.
The main purpose of scan expressions is that they allow the omission
of the current subject (in this case \*{data\*}).
.IP 18 6
Declaration of \*{w1\*}, \*{w2\*}, \*{w3\*}, \*{pair\*} and \*{triple\*}
with initialization of \*{w2\*} and \*{w3\*}.
There is an implicit assumption here:
since the procedure \*{word\*} can fail (see above), the input file
should contain at least two `words'.
If not, the run-time error `Undetected failure of procedure word' will be given and the execution of the program will be terminated.
.IP 20-25 6
\*<while-expression\*> terminated by failure of \*{word\*}.
The expression in the test part of the while expression
is a multiple assignment and is equivalent to:
.sp 0.5
.{{
	w1 := w2;
.br
	w2 := w3;
.br
	w3 := word(data)
.}}
.br
.IP 21-24 6
The frequencies of the pair (w1, w2) and the triple (w1, w2, w3) are incremented.
Because \*{tupletab\*} has a default value of 0 (cf. line 11),
the frequency of pairs and triples that did not occur previously,
is set to 1 by these statements.
.IP 29 6
Terminate i/o operations on this file.
.IP 32-37 6
\*<for-expression\*> that loops over all (sorted) indices in \*{tupletab\*}.
.IP 33-35 6
The value corresponding to the current value of \*{tuple\*}
is assigned to local variable \*{freq\*}.
If it is higher than the threshold \*{interesting\*},
the value of \*{tuple\*} (left aligned in a field of width 20) is printed,
followed by the value of \*{freq\*} (right aligned in a field of width 10).
