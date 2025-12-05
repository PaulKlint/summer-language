#{figs+>;}
.NC #{IMPLEMENTATION=sn+} "IMPLEMENTATION" " "
.ds LH IMPLEMENTATION
.SH #{sn>1}. "Introduction"
.PP
The implementation of a high level programming language still requires a major effort.
Depending on the complexity of the language to be implemented and on the
requirements imposed on the final product, one is faced with a task that
may take from a few man months to several man years of labour.
If the primary purpose of a research project is language \fBdesign\fP,
one generally does not want to spend too much time on language \fBimplementation\fP
and consequently some balance has to be found between the speed with which
programs in the new language are executed and the effort needed to
achieve this.
.PP
The implementation of \s-2SUMMER\s0 which is described in this chapter evolved
over several years and required approximately two man years of effort.
This implementation allows the execution of \s-2SUMMER\s0 programs of any size and
gives appropriate messages for syntactic and semantic errors.
Apart from providing a few simple tools (for symbolic tracing and
the gathering of run-time statistics) no effort was made to assist the user
in creating, modifying or maintaining \s-2SUMMER\s0 programs.
.PP
In order to minimize implementation time without sacrificing execution time
efficiency completely, we proceeded as follows:
.IP \*(MK
S\s-2UMMER\s0 programs are translated to abstract machine programs.
The latter are subsequently executed by an interpreter.
.IP \*(MK
Existing algorithms and techniques were used whenever possible.
.IP \*(MK
A high level implementation language was used.
Assembly language was resorted to only when absolutely necessary.
.IP \*(MK
Simple but less efficient algorithms were preferred to complex but efficient ones.
.IP \*(MK
Facilities for measurements and internal consistency checking were made an integral
part of the system.
.IP \*(MK
The implementation was made as flexible as possible so as to
allow for easy experimentation
with new language features and new implementation techniques.
.IP \*(MK
Communication with the user is performed in terms of entities
that are known to the user at the source program level.
.KF
.sp 2
.DS L
Program\h'|3c'Compiler\h'|6c'Program
.sp 1
\h'(\w'Program'-\w'(\s-2SUMMER\s0)')/2'(\s-2SUMMER\s0)\h'|3c'\h'(\w'Compiler'-\w'(\s-2SUMMER\s0)')/2'(\s-2SUMMER\s0)\h'|6c'\h'(\w'Program'-\w'(\s-2SAM\s0)')/2'(\s-2SAM\s0)
.sp 4
Run-time library\h'|6c'routine 1\h'|9c'Executable
.sp 1
with C routines\h'|6c'\h'(\w'routine 1'-\w'(C)')/2'(C)\h'|9c'version of
.sp 1
including:\h'|9c'\s-2SUMMER\s0
.sp 1
\(em \s-2SAM\s0 interpreter\h'|9c'program
.sp 1
\(em garbage collector
.sp 1
\(em routines for all\h'|6c'routine N
.sp 1
\h'\w'\(em 'u'built-in operations\h'|6c'\h'(\w'routine N'-\w'(C)')/2'(C)
.sp 2
.ce 1
\s-1\fBFigure #{fig SUMMER system=figs+}\fP. Overall organization of the \s-2SUMMER\s0 system.\s0
.DE
.sp 2
.KE
.PP
The overall organization of the \s-2SUMMER\s0 system is sketched
in Figure #{fig SUMMER system}.
A compiler (written in \s-2SUMMER\s0) transforms the text
of a \s-2SUMMER\s0 program into an equivalent abstract machine program.
This abstract machine program is then combined with a library of run-time routines 
(written in C [Kernighan78])
to form a final executable version of the original \s-2SUMMER\s0 program.
The run-time library contains, amongst other things, an \fBinterpreter\fP
for abstract machine instructions.
.PP
Several aspects of the \s-2SUMMER\s0 implementation have been described elsewhere
and will not be discussed any further:
.IP \*(MK
The merits of a system organization as outlined above
and the tradeoffs between compilation and interpretation
have been described in [Klint81b].
.IP \*(MK
Various forms of abstract machine instructions
(i.e stack-oriented vs. two- and three-address instructions)
were compared in [Klint79a].
.IP \*(MK
A technique for maintaining run-time line numbers has been published in [Klint79b].
.PP
This chapter aims at giving a general impression of the \s-2SUMMER\s0 implementation.
First of all, the S\s-2UMMER\s0 Abstract Machine (\s-2SAM\s0) is described.
Next, we show how the compiler generates code for it.
Both descriptions are intentionally brief.
We have used as many conventional techniques as possible and
the reader is assumed to be familiar with implementation techniques
for high level languages.
We shall only highlight \fBnew\fP or \fBinteresting\fP techniques or algorithms.
Readers interested in more details are referred to the amply annotated listings
and (internal) documentation of the \s-2SUMMER\s0 system itself.
.SH #{sn+}. "The S\s-2UMMER\s0 Abstract Machine"
.PP
The S\s-2UMMER\s0 Abstract Machine (\s-2SAM\s0) provides a largely conventional,
stack-oriented, intermediate level architecture tailored to the
execution of \s-2SUMMER\s0 programs.
The instruction set is summarized in Table #{IMPLEMENTATION}.1.
The machine has four special purpose registers.
The \fBstack pointer\fP
($SP$) points to the top of the expression evaluation stack.
It is used implicitly by many instructions.
We shall use the notation $SP[n]$, with $n >= 0$,
to denote elements on the stack;
$SP[0]$ denotes the top element,
$SP[1]$ denotes the element below the top element, and so on.
The \fBcurrent fail label\fP
(see Section #{SAM/failure}) points to the top of the stack of fail labels
used to implement failure handling and flow of control.
The \fBcurrent cache\fP
(see Section #{SAM/cache}) points to the top of the stack of recovery caches
used to implement the \fBtry\fP-expression in \s-2SUMMER\s0.
The \fBcurrent subject\fP
points to the top of the stack of subject strings used to
implement the \fBscan\fP-expression in \s-2SUMMER\s0.
.PP
All values in a \s-2SUMMER\s0 program are represented in \s-2SAM\s0 by \fBmvalues\fP,
which have a uniform layout and occupy one or more consecutive memory cells.
The first cell of each mvalue contains a tag that identifies the
class to which it belongs.
Following cells may contain pointers to other mvalues.
A number of classes (integer, string, real, array, table) are primitive in \s-2SAM\s0 ,
i.e. they are directly supported by \s-2SAM\s0.
For operations on other classes, calls to built-in routines are generated.
Variables in a \s-2SUMMER\s0 program are represented in \s-2SAM\s0 by a pointer to an mvalue.
This level of indirection enables \s-2SUMMER\s0 variables to possess
values of varying size and type.
.PP
A \s-2SAM\s0 program consists of three parts as shown in Figure #{fig SAM general}.
The first part contains class and field declarations describing
the structure and access rights of the class declarations in the \s-2SUMMER\s0 program.
The second part consists of declarations for global variables
and procedures.
The third part consists of declarations for the string constants
occurring in the generated code.
Some examples of \s-2SUMMER\s0 expressions and their translation into
\s-2SAM\s0 instructions are shown in Figure #{fig SAM examples}.
.PP
Three groups of instructions
(for failure handling,
side-effect recovery
and
operations on classes)
are interesting and deserve a more detailed description.
This is the topic of the following three paragraphs.
.nf
.na
.br
.ne 10
.sp 2
.ta 2c 4c 6c 8c
.ce 1
SAM INSTRUCTION SUMMARY
.sp 2
.ce 1
Push simple values onto the expression evaluation stack

INT	$n$	Push integer constant $n$.
REAL	$r$	Push real constant $r$.
GLOB	$n$	Push value of $n$-th global variable.
ASGLOB	$n$	Assign $SP[0]$ to $n$-th global variable.
LOC	$n$	Push value of $n$-th local variable.
ASLOC	$n$	Assign $SP[0]$ to $n$-th local variable.
LOAD	$l$	Push the address of a constant at location $l$.
NULLSTR		Push the empty string.
UNDEF		Push the value \fIundefined\fP.
VOID		Decrement $SP$.

.ce 1
Relational and arithmetical instructions

EQ		Test whether $SP[1]~=~SP[0]$.
		On failure: jump to current fail label.
		On success: replace $SP[0]$ and $SP[1]$ by $SP[0]$,
		i.e. $SP[1]~:=~SP[0];~SP~:=~SP~-~1$.
		The following relational operators behave similarly.
NE		Test whether $SP[1]~!=~SP[0]$.
LT		Test whether $SP[1]~<~SP[0]$.
GT		Test whether $SP[1]~>~SP[0]$.
LE		Test whether $SP[1]~<=~SP[0]$.
GE		Test whether $SP[1]~>=~SP[0]$.
.br
.ne 3
ADD		Perform $SP[1]~+~SP[0]$.
		$SP[0]$ and $SP[1]$ are replaced by their sum,
		i.e. $SP[1]~:=~SP[0]~+~SP[1];~SP~:=~SP~-~1$.
SUB		Perform $SP[1]~-~SP[0]$.
MUL		Perform $SP[1]~*~SP[0]$.
DIV		Perform $SP[1]~/~SP[0]$.
IDIV		Perform $SP[1]~%~SP[0]$ (integer division).
NEG		Perform $-~SP[0]$ (unary minus).
CONC		Perform $SP[1]~||~SP[0]$ (string concatenation).

.br
.ne 5
.ce 1
Instructions related to arrays and tables

ARINIT	$n,m$	Array initialization.
		Create an array of length $n$ and initialize the first $m$
		($m<=n$) elements using the $m$ values on top of the stack.
		Push the address of the resulting array onto the stack.
.br
.ne 4
TABINIT	$n$	Table initialization.
		Create a table of length $n$ and push the result
		onto the stack.  Initialization of table entries
		is done by the instruction TABELEM below.
TABELEM	$n$	Table element assignment.
.br
.ne 4
IND		Index operation in array or table.
		$SP[0]$ is the array or table instance.
		$SP[1]$ is the value of the index.
		Both entries are replaced by the value of
		the indexed element.
.br
.ne 5
ASIND		Assign to array or table element.
		$SP[0]$ is the array or table element.
		$SP[1]$ is the value of the index.
		$SP[2]$ is the value to be assigned to the indexed element.
		Only the latter remains on the stack.
XAR	$n$	Replace the array value in $SP[0]$ by its first $n$ elements.

.br
.ne 4
.ce 1
Procedure calls

CALL	$n,m$	Call the $n$-th procedure with $m$ actual parameters.
		The actual parameters are on top of the stack.
.br
.ne 2
RETURN		Return a value from a procedure call and deallocate
		stack space for actuals and locals.
.br
.ne 3
FRETURN		Failure return from procedure call. Deallocate stack
		space for actuals and locals and simulate a GOFL
		instruction in the caller.

.br
.ne 5
.ce 1
Failure handling (see Section #{SAM/failure}) and flow of control

NEWFL	$l$	Define new fail label $l$.
OLDFL		Restore previous fail label.
GOFL		Jump to current fail label.

GO	$l$	Jump to label $l$.
.br
.ne 4
GOCASE		Case table jump.
		$SP[1]$ is the case table to be used.
		It contains (index-value, program-label) pairs.
		$SP[0]$ is the index value for the table selection.

.br
.ne 5
.ce 1
Recovery caches (see Section #{SAM/cache})

NEWRC		Install new recovery cache.
OLDRC		Discard current cache and reinstall previous one (if any).
RESRC		Restore from current cache.

.br
.ne 5
.ce 1
Instructions for manipulating the current subject string

NEWSUBJ		Install $SP[0]$ as new current subject.
OLDSUBJ		Restore previous subject.
SUBJECT		Push value of current subject.

.br
.ne 12
.ce 1
Instructions related to classes (see Section #{SAM/classes})

NEWCLASS	$name$	Create new instance of class $name$.
CLOC	$n$	Push $n$-th local of class instance.
ASCLOC	$n$	Assign to $n$-th local of class instance.
FLD	$n,name$	Fetch field $name$ from class instance $SP[n]$.
ASFLD	$n,name$	Assign to field $name$ from class instance $SP[n]$.
IFLD	$n,name$	Fetch from field ignoring associations.
IASFLD	$n,name$	Store in field ignoring associations.
SELF		Push current class instance.

.br
.ne 7
.ce 1
Declarative instructions

LAB	$l$	Declare label $l$.
DCLGLOB	$name$	Declare global variable $name$.
DCLSTR	$name,n,b sub 1~,...,~b sub n$
		Declare string constant $name$ consisting of
		$n$ characters $b sub 1~ ,..., ~ b sub n$.
PROC	$p,lnames,nf,nl,bline,eline$
		Start declaration of procedure with name $p$.
		$lnames$	the names of the local variables in $p$.
		$nf$	number of formal parameters of $p$.
		$nl$	number of local variables of $p$.
		$bline$	line number of first line of $p$'s
			declaration in source text.
		$eline$	line number of last line of $p$'s
			declaration in source text.
.br
.ne 2
PROGRAM	$p,lnames,nf,nl,bline,eline$
		Start declaration of main program.
PROCEND		End of procedure declaration.
SUBR	$p$	S\s-2UMMER\s0 program uses library routine $p$.
CLASSES		Start class description tables.
ENDCLASSES		End class description tables.
FIELDS		Start field description tables.
ENDFIELDS		End field description tables.

.ce 1
Miscellaneous instructions

HALT		Halt instruction.
NOOP		No operation.
LINE	$n$	Static line number increment.
ALINE	$n$	Absolute line number.
ERROR	$name$	Generate error message with fixed name.
		Allowed names are:
		\*{ER_case\*}:	index does not occur in case table.
		\*{ER_assert\*}:	assertion failed.
		\*{ER_ret\*}:	procedure does not return a value.
.sp 2
.ce 1
\s-1\fBTable #{IMPLEMENTATION}.1\fP. \s-2SAM\s0 instruction summary.\s0
.ad
.fi
.KF
.sp 2
.DS
.ta 20n
CLASSES
   . . .
ENDCLASSES
.sp 0.5
	Part 1: description of user-defined classes
.sp -0.5
FIELDS
   . . .
ENDFIELDS
.sp 1
DCLGLOB  v1
PROC  p1, . . .
.sp 0.5
	Part 2: declarations of variables and procedures
.sp -0.5
   . . .
PROCEND	
.sp 1
DCLSTR  s1, . . .	Part 3: declarations for string constants
.sp 2
.ce 1
\s-1\fBFigure #{fig SAM general=figs+}\fP. General form of \s-2SAM\s0 program.\s0
.DE
.sp 2
.KE
.KF
.sp 2
.DS I
.ta 6c 7.5c
\s-2SUMMER\s0 expression	\s-2SAM\s0 instructions
.sp 1
(Assume that \*{a\*} and \*{b\*} are local variables numbered 0, 1.)

\*{a := b + 2.5\*}	LOC	1
	REAL	2.5
	ADD
	ASLOC	0

\*{a[10] := x * 2\*}	GLOB	\fIx\fP
	INT	2
	MUL
	LOC	0
	INT	10
	ASIND
			
\*{q(a, 13)\*}	LOC	0
	INT	13
	CALL	\fIq\fP,2
.DE
.sp 1
.ce 1
\s-1\fBFigure #{fig SAM examples=figs+}\fP. S\s-2AM\s0 instructions generated for some \s-2SUMMER\s0 expressions.\s0
.sp 2
.KE
.SH #{SAM/failure=sn>1}. "Failure handling"
.PP
Each operation in a \s-2SUMMER\s0 program may fail;
correspondingly each \s-2SAM\s0 instruction may fail.
If failure occurs, the execution of the \s-2SAM\s0 program is continued
at a point determined by the structure of the \s-2SUMMER\s0 program;
all intermediate results that were placed on the expression stack by the
sequence of instructions containing the failing instruction must then be removed.
We use `sequence' here in the sense of a series of instructions with the
same failure continuation label.
There are three options when designing an instruction set that has to accommodate
this kind of failure handling:
.IP 1)
Include in each instruction both a failure continuation label and
the value of the stack pointer at the entry of the current instruction sequence.
.IP 2)
Introduce a dedicated (abstract machine) register for maintaining 
the current failure label and the value of the stack pointer at the entry of the
current instruction sequence.
.IP 3)
Add an instruction for encoding the tree-structure of (nested)
failure labels to the abstract machine.
Since this tree-structure is known at compile time, a fair
amount of computation can be saved in this way which is otherwise spent in
maintaining the nesting of failure labels dynamically.
.LP
The first alternative is easy to implement, but leads to a substantial
increase in the size of the generated code.
The third alternative is the most efficient one, but complicates both
compiler and abstract machine.
As a compromise, the second alternative was adopted in \s-2SAM\s0.
Account is taken of the nesting of failure labels by a stack
of (continuation label, stack-top-at-sequence-entry) pairs.
The \fBcurrent fail label\fP register points to the pair on top of
the \fBfail label stack\fP.
The instructions for manipulating the fail label stack can now be defined
precisely:
.IP "NEWFL $l$"
.br
Pushes the pair $(l,~SP)$ onto the fail label stack.
.IP "OLDFL"
.br
Removes the top of the fail label stack.
This instruction is used at the end of instruction sequences.
If the OLDFL instruction is reached, the execution of the sequence
as a whole succeeds and the previous fail label is restored.
.IP "GOFL"
.br
Go to the current fail label, i.e. pop the pair $(l,~SP')$ off the fail label stack,
adjust the expression stack by assigning $SP'$ to the stack pointer $SP$ and
jump to continuation label $l$.
.LP
Fail labels are only pushed onto the fail label stack by NEWFL instructions.
They are (implicitly) popped by:
.IP \*(MK
OLDFL (at the successful completion of the evaluation of an expression).
.IP \*(MK
GOFL (used for implementing the \s-2SUMMER\s0 operators `\*{&\*}'
and `\*{|\*}', and for implementing \fBtry\fP-expressions).
.IP \*(MK
FRETURN 
.IP \*(MK
Failing expressions
(the fail label stack is, for instance, popped if the instruction EQ
fails).
.LP
Figure #{fig SAM if and while} shows how these instructions are used
to implement \fBif\fP- and \fBwhile\fP-expressions. 
.KF
.sp 2
.DS I
.ta 6c 7.5c
\s-2SUMMER\s0 expression	\s-2SAM\s0 instructions

\*{if\*}	NEWFL	\*{F1\*}
        \*{x = b\*}	GLOB	\*{x\*}
	LOC	1
	EQ
	VOID
\*{then\*}	OLDFL
        \*{x := 3\*}	INT	3
	ASGLOB	\*{x\*}
	VOID
	GO	\*{L1\*}
\*{else\*}	LAB	\*{F1\*}
        \*{y := 4\*}	INT	4
	ASGLOB	\*{y\*}
	VOID
\*{fi\*}	LAB	\*{L1\*}
.sp 2
\*{while\*}	LAB	\*{L2\*}
	NEWFL	\*{F2\*}
        \*{x > y\*}	GLOB	\*{x\*}
	GLOB	\*{y\*}
	GT
	VOID
\*{do\*}	OLDFL
        \*{x := x - a\*}	GLOB	\*{x\*}
	LOC	0
	SUB
	ASGLOB	\*{x\*}
	VOID
\*{od\*}	GO	\*{L2\*}
	LAB	\*{F2\*}
.DE
.ce
\s-1\fBFigure #{fig SAM if and while=figs+}\fP. S\s-2AM\s0 instructions generated for \fBif\fP- and \fBwhile\fP-expression.\s0
.sp 2
.KE
.SH #{SAM/cache=sn+}. "Side-effect recovery"
.PP
Side-effect recovery, as required by the \fBtry\fP-expression in \s-2SUMMER\s0,
is realized in \s-2SAM\s0 by means of recovery caches.
Since try-expressions may occur in a nested fashion, it is necessary to
maintain a stack of active caches.
Each cache is implemented as a linear list of (address, mvalue) pairs.
All operations that modify (parts of) an mvalue must first
consult the current cache (if any) to check whether the address of the
memory location to be modified already occurs in the cache.
If it does not, the address and old contents of the
location are added to the cache.
.PP
There are three instructions for manipulating recovery caches:
.IP "NEWRC"
.br
Creates a new cache.
.IP "OLDRC"
.br
\&`Discards' {#{SUMMER/caches}} the current cache and reinstalls the previous one (if any).
.IP "RESRC"
.br
Restores from cache.
Uses the information in the cache stack to restore the program
to a previous state.
.LP
Figure #{fig SAM try} shows how these instructions are used to implement \fBtry\fP-expressions.
.KF
.sp 2
.DS I
.ta 6c 7.5c
\s-2SUMMER\s0 expression	\s-2SAM\s0 instructions

\*{try\*}	NEWRC
	NEWFL	\*{F1\*}
        \*{p()\*}	CALL	\*{p\*},0
	VOID
	GO	\*{L1\*}
        ,	LAB	\*{F1\*}
	RESRC
	NEWFL	\*{F2\*}
        \*{q()\*}	CALL	\*{q\*},0
	VOID
	GO	\*{L1\*}
	LAB	\*{F2\*}
	RESRC
	GOFL
\*{until\*}	LAB	\*{L1\*}
        \*{r()\*}	CALL	\*{r\*},0
	VOID
	OLDFL
\*{yrt\*}	OLDRC
.DE
.ce
\s-1\fBFigure #{fig SAM try=figs+}\fP. S\s-2AM\s0 instructions generated for a \fBtry\fP-expression.\s0
.sp 2
.KE
Despite the simplicity of this scheme and the (inefficient)
linear search that is used to search the cache, no appreciable
overhead due to the use of \fBtry\fP-expressions has been observed.
.SH #{SAM/classes=sn+}. "Operations on classes"
.PP
The life of a class instance can be subdivided into three distinct phases:
.IP 1)
Creation of the new instance.
This is performed by executing the instruction
.DS
NEWCLASS  \fIcname\fP
.DE
which allocates space for a new instance of class \fIcname\fP
and leaves a pointer to it on top of the expression stack.
Such an instance-pointer is used
explicitly or implicitly by all instructions related to classes (see below).
.IP 2)
Access to the instance.
Instructions for field selection (FLD, ASFLD)
expect an instance-pointer as one of their arguments.
These instructions contain an encoded \fBsymbolic\fP field name which is looked up in
the field declaration tables
(in Part 1 of the \s-2SAM\s0 program, see Figure #{fig SAM general})
in order to validate the field selection and to select the procedure
to be invoked for the actual access.
An instance-pointer is kept in a (dedicated) local variable location,
when executing instructions inside a class declaration.
In this way, certain instructions (CLOC, ASCLOC) can access and modify
fields of the instance.
.IP 3)
Death of the instance.
The lifetime of an instance is completely determined by its accessibility.
When a request to create a new instance cannot be satisfied
because memory space is exhausted,
a garbage collector removes all inaccessible instances and compacts
the memory made free.
The garbage collector is based on techniques described in [Hanson77].
.SH #{SUMMER compiler=sn<+}. "Compiler"
.PP
The tasks of the \s-2SUMMER\s0 compiler are threefold:
.IP 1)
Check that the input program satisfies the rules of the context-free syntax.
.IP 2)
Enforce context-sensitive syntax rules
(this includes the requirement that variables should be declared,
the checking of scope rules, etc.)
.IP 3)
Generate \s-2SAM\s0 instructions for the input program.
.LP
Steps 1 and 2 are performed by the \fBparser\fP
and step 3 is performed by the \fBcode generator\fP.
The organization of the compiler is shown in Figure #{fig SUMMER compiler}.
.KF
.sp 2
.DS I
\h'|5c'\h'-\w'intermediate files with'/2'intermediate files with
.br
\h'|5c'\h'-\w'parse trees and symbol tables'/2'parse trees and symbol tables
.sp 3
\s-2SUMMER\s0\h'|6c'\h'(\w'generator'-\w'code')/2'code\h'|9c'\h'(\w'program'-\w'\s-2SAM\s0')/2'\s-2SAM\s0
.br
\h'|3c'parser
.br
\h'(\w'\s-2SUMMER\s0'-\w'program')/2'program\h'|6c'generator\h'|9c'program
.sp 3
\h'|5c'\h'-\w'error messages'/2'error messages
.DE
.sp 2
.ce 1
\s-1\fBFigure #{fig SUMMER compiler=figs+}\fP. Organization of the \s-2SUMMER\s0 compiler.\s0
.DE
.sp 2
.KE
.PP
The parser uses recursive descent for the syntactic analysis of statements
and declarations and a bottom-up parsing method for analyzing expressions.
Both parsing methods use an error recovery scheme
that was first used in a \s-2PASCAL\s0 compiler
[Hartmann77, Amman78].
This scheme works extremely well for \s-2SUMMER\s0 since all language constructs
have a `closed' form and distinct closing delimiters.
It was decided to use a table-driven, bottom-up expression parser to
simplify the recognition of user-defined operators.
.PP
The parser produces a series of intermediate files which contain
a parse tree of the \s-2SUMMER\s0 program and symbol tables.
These intermediate files serve as input for the code generator.
.PP
The code generator
rearranges the information in the intermediate files
and performs a pre-order traversal of the parse tree to generate
\s-2SAM\s0 instructions.
.PP
Further details concerning the organization of the \s-2SUMMER\s0
compiler can be found in [Sint80].
.SH #{sn+}. "References for Chapter #{IMPLEMENTATION}"
.so refs/Ammann78
.so refs/Hanson77
.so refs/Hartmann77
.so refs/Kernighan78
.so refs/Klint79a
.so refs/Klint79b
.so refs/Klint81b
.so refs/Sint80
#{sn<;}#{figs<;}
.EC
