.bp
.NC #{INTERACTIVE TRACER=sn+} "THE S\s-2UMMER\s0 INTERACTIVE TRACER" " "
.SH #{sn>1}. Introduction
.PP
The S\s-2UMMER\s0 interactive tracer provides an interactive debugging facility
for S\s-2UMMER\s0 programs.
It allows the setting of breakpoints,
the inspection of variables and structured values using
a subset of the S\s-2UMMER\s0 notation itself, and the
execution of system commands.
Programs need not be recompiled to use the tracer.
.PP
The tracer can be activated in three ways:
.IP 1.
When the S\s-2UMMER\s0 program is executed with an additional "-t"
parameter, the tracer gains control at the first breakpoint in the program
and waits for commands.
.IP 2.
When the S\s-2UMMER\s0 program is interrupted during its execution,
control is given to the tracer at the first
breakpoint encountered in the S\s-2UMMER\s0 program.
.IP 3.
When a run-time error is detected, the tracer is activated,
to provide a last opportunity to inspect
the variables in the program.
The execution of the program is
.UL not
continued when interaction with the tracer is complete.
.PP
When the tracer gains control, it identifies the place
where the program is currently executing
and prompts the user with a "*".
For example:
.DS
my_proc+13 (403)
* 
.DE
means that execution stopped at the the thirteenth line of
procedure "my_proc", absolute line number 403, and that the
tracer is waiting for input.
.SH #{sn+}. "Description of commands"
.PP
A \*<tracer-command\*> consists of a series of commands on an input line,
separated by semicolons:
.DS L
.<<
<tracer-command> ::=
	{ <command> ';' }* <newline> .
.>>
.DE
There are four types of commands:
.DS L
.<<
<command> ::=
	  <line-command>
	| <special-command>
	| <system-command>
	| <expression> .
.>>
.DE
These four commands will now be described in turn.
.SH #{sn>1}. "Line commands"
.PP
A \*<line-command\*> defines a number of consecutive lines in the source text,
where the tracer should gain control.
The syntax of a \*<line-command\*> is:
.DS L
.<<
<line-command> ::=
	  <integer> [',' <integer> ]
	| '/' [ <identifier> ] [',' <integer> [',' <integer>]] '/' .
.>>
.DE
A \*<line-command\*> may either specify absolute line numbers
(the first alternative in the above syntax rule) or
relative line numbers (the second alternative).
In the first case, the program will continue execution until a breakpoint
is reached in the specified absolute line number interval.
In the second case, a name of a procedure is given which is
optionally followed by line number offsets relative to the beginning of the
named procedure.
If the name of the procedure is omitted, the procedure name of the
previous \*<line-command\*> is used.
The optional offsets are added to the line number
of the declaration of the named procedure. This gives a line number interval
used to control the activation of the tracer.
An omitted first offset implies the line number of the beginning of the procedure.
An omitted second offset implies the line number of the end of the procedure.
.PP
Examples of \*<line-command\*>s are:
.DS L
123,125			interval from 123 to 125
/my_proc,15,17/		interval from L+15 to L+17
			(where L is the source text line number of
			the declaration of "my_prog")
/my_proc,15/		interval from L+15 to M
			(where M is the source text line number of the end
			of the declaration of "my_prog")
/my_proc/		interval from L to M.
//			idem (supposing that "my_prog" was used
			in a previous \*<line-command\*>)
.DE
.PP
After a \*<line-command\*>, the execution of the program will
continue until a breakpoint is encountered in the line number interval
specified in the \*<line-command\*>.
At which point the tracer regains control.
Breakpoints are inserted by the compiler at the following syntactic
positions:
.IP -
At the start of procedures and before \*<return-expression\*>s.
.IP -
Before \*<test\*>s in \*<if-expression\*>s,
\*<for-expression\*>s and \*<while-expression\*>s.
.SH #{sn+}. "Special commands"
.PP
A \*<special-command\*> can be used to perform
miscellaneous functions, and has the syntax:
.DS L
.<<
<special-command> ::=
	  '\\*(DLwhere'
	| '\\*(DLcalls' ['all' | 'off' | <identifier>*]
	| '\\*(DL=' [<string>]
	| '\\*(DL' .
.>>
.DE
The meaning of these commands is:
.IP "\\*(DLwhere: "
prints a list of all currently entered procedures.
.IP "\\*(DLcalls: "
controls the printing of procedure calls as follows:
.RS
.IP "\\*(DLcalls all: "
the calls of all procedures will be printed.
.IP "\\*(DLcalls off: "
suppresses printing of procedure calls.
.IP "\\*(DLcalls \*<identifier\*>* "
.br
only the calls of the procedures whose name occurs in the
list of \*<identifier\*>s will be printed.
.IP  "\\*(DLcalls: "
enables the previous print condition
(i.e. either all calls are printed or only the calls of some selected procedures).
.RE
.sp 1
Invoking a S\s-2UMMER\s0 program with the '-c' flag
is equivalent with "\\*(DLcalls all" (i.e. print all procedure calls).
.IP "'\\*(DL=' \*<string\*>"
.sp 1
remembers \*<string\*> for later input to the tracer.
.IP "'\\*(DL='"
prints the value of the currently remembered string.
.IP "'\\*(DL'"
feeds the string remembered by "'\\*(DL=' \*<string\*>" as input to the tracer.
.SH #{sn+}. "System command"
.PP
A \*<system-command\*> has the form:
.DS L
.<<
<system-command> ::=
	'!' <string> .
.>>
.DE
It serves as an escape to the operating system and executes
the system command \*<string\*>.
.SH #{sn+}. "Expression"
.PP
An \*<expression\*> is used to inspect values in the running program.
It has the syntax:
.DS L
.<<
<expression> ::=
	  <integer>
	| <string>
	| <identifier> (<select> | <subscript>)* .
.sp 1
<select> ::=
	'.' <field-identifier> .
.sp 1
<subscript> ::=
	'[' <expression> ']' .
.>>
.DE
The use of the tracer is not allowed to affect the
behavior of the program being traced.
As a consequence, only a severely limited form of expressions is
allowed as tracer input.
Assignments, procedure calls and
selections of fields with a procedure as fetch association are, for example,
excluded.
.SH #{sn<+}. "Errors"
.PP
Errors of various kinds can occur:
.IP 1.
Violation of command syntax.
This is indicated by a "^" symbol, printed below the tracer input line
near the place where the syntax error occurred.
.IP 2.
Unknown variable occurs in expression.
This is also indicated by a "^" symbol pointing at the end of the
unknown identifier.
.IP 3.
Semantic errors, such as illegal field selection, are indicated by
an explicit error message.
#{sn<;}
.bp
