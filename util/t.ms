.bp
The SUMMER interactive tracer

1. Introduction
.br

     
The SUMMER interactive tracer provides an interactive debugging facility
for SUMMER programs.
It allows the setting of breakpoints in the SUMMER program,
the inspection of variables and structured values using
a subset of the SUMMER notation itself, and the
execution of system commands.
.br

     
The tracer can be activated in two ways:
.br
Give an additional "-t" parameter when the SUMMER program is executed.
.br
Interrupt the SUMMER program during its execution.
This has the effect that control will be given to the tracer at the first
possible breakpoint in the SUMMER program.
.br

     
When the tracer gains control, it identifies the place in the
program where the SUMMER program is currently executing
and gives a "*" as prompt symbol, to indicate that the tracer is ready
to accept commands.
For example:
my_proc+13 (403)
* 
means that execution stopped at the the thirteenth line of
procedure "my_proc", absolute linenumber 403, and that the
tracer is waiting for input.
2. Description of commands
.br

     
Tracer commands are now described in more detail.
.br

     
A tracer command consists of a series of commands on an input line,
separated by semicolons:
tracer-command	::= { command ';' }* newline .
There are four types of commands:
command		::= line-command | special-command |
		    system-command | expression .
.br

     
A line-command defines an interval of linenumbers in the source text,
where the tracer should gain control.
The syntax of a line-command is:
line-command	::= line-indication
		    [',' line-indication] .
line-indication ::= integer |
		    '/' [identifier] '/' [offset] .
offset		::=  ('+' | '-') integer .
A linenumber interval is defined by two line-indications.
If the second line-indication is omitted, the first line-indication
is assumed to be repeated there.
A line-indication may be either an integer, which gives the absolute linenumber,
or the name of a procedure followed by an optional offset.
If the name of the procedure is omitted, the procedure name of the
previous line-indication is used.
The optional offset is added to (or subtracted from) the linenumber
of the declaration of the named procedure. This gives the linenumber
used to control the activation of the tracer.
.br

     
Examples of line-indications are:
123,125
/my_proc/,/my_proc/+15
/my_proc/,//+15
/my_proc/
//,//+20
2023,/your_proc/+13
(NOTE: the current implementation does not allow names of field procedures,
i.e. procedures declared inside a class declaration, to occur in
line-indications)
.br

     
After a line-command, the execution of the SUMMER program will
continue until a breakpoint is encountered in the linenumber interval
as specified in the line-command.
At that breakpoint the tracer regains control.
Breakpoints are inserted by the compiler at the following syntactic
positions:
.br
At the start of procedures and before return expressions.
.br
Before tests in IF, FOR and WHILE expressions.
.br

     
A special-command provides miscellaneous facilities, and has the syntax:
special-command ::= '$s' | '$c' | '$=' [string] | '$' .
.RS
.br
prints the current run-time stack.
.br
toggles the symbolic call trace option, which may also be set
by the '-c' flag at the start of execution of the SUMMER program.
.br
remembers "string" for later input to the tracer.
.br
prints the value of the currently remembered string.
.br
feeds the string remembered by "'$=' string" as input to the tracer.
.RE
.br

     
A system command has the form:
system-command	::= '!' string .
and serves as an escape to the operating system, to execute
the system command "string".
.br

     
An expression is used to inspect values in the running SUMMER program:
expression	::= integer | string |
		    identifier (select | subscript)* .
select		::= '.' field-identifier .
subscript	::= '[' expression ']' .
The general rule is that the use of the tracer can not influence the
behaviour of the program being traced.
As a consequence, only a severely limited form of expressions is
allowed as tracer input.
Excluded are, for example, assignments, procedure calls and
selection of fields with a procedure as fetch association.
3. Errors
.br

     
Errors of various kinds can be made:
.br
Violation of command syntax.
This is indicated by a "^" symbol, printed below the tracer input line
near the place where the syntax error occurred.
.br
Unknown variable occurs in expression.
This is also indicated by a "^" symbol pointing at the end of the
unknown identifier.
.br
Semantic errors, such as illegal field selection, are indicated by
an explicit error message.
