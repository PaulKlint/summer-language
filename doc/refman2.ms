#{figs+>;}
.NC #{SEMI FORMAL DEFINITION=sn+} "A SEMI-FORMAL DEFINITION" "OF THE SUMMER KERNEL"
.ds LH "SEMI-FORMAL DEFINITION OF THE SUMMER KERNEL
.SH #{Declarations=sn>1}. "Declarations"
.iy I declarations
.iy I scope
.PP
Declarations introduce new names into the current environment
and generally associate a value with those names.
The effect of a declaration is limited by the \fBscope\fP in
which it occurs.
A scope is a part of a program that can be derived from one of the syntactic
notions \*<summer-program\*>, \*<procedure-declaration\*>, \*<operator-declaration\*>,
\*<class-declaration\*> or \*<block\*>.
Scopes can be nested.
All names defined in one scope must be distinct,
but names in different scopes may be the same.
In the formal definition a new scope is introduced
by the operations \*{new_inner_scope\*} and \*{new_proc_scope\*}
{#{Semantic domains}}.
.SH #{Summer program=sn>1}. "Summer program"
.SH #{sn>a}. Syntax -
.LP
.<<
.so syn/summer-program
.sp 0.5
.so syn/program-decl
.>>
.SH #{sn+}. Pragmatics -
.PP
All syntactically correct programs are derived from the non-terminal
\*<summer-program\*>,
.iy I <summer-program>
the start symbol of the grammar.
The evaluation of a
\*<summer-program\*>
proceeds in three steps:
.IP 1.
Evaluate all
\*<variable-declaration\*>s {#{Variable declarations}},
\*<constant-declaration\*>s {#{Constant declarations}},
\*<procedure-declaration\*>s {#{Procedure and operator declarations}},
\*<operator-declaration\*>s {#{Procedure and operator declarations}},
\*<class-declaration\*>s {#{Class declarations}}
and \*<operator-symbol-declaration\*>s {#{Operator symbol declarations}}
immediately contained in the
\*<summer-program\*>.
We will refer to the resulting environment as the \fBglobal environment\fP.
It is described by \*{ENVglobal\*} in the formal definition.
.IP 2.
Evaluate all non-empty
\*<variable-initialization\*>s
.iy I <variable-initialization> s
{#{Variable declarations}}
in
\*<variable-declaration\*>s
.iy I <variable-declaration> s
immediately contained in the
\*<summer-program\*>.
.iy I <summer-program> .
The text of these
\*<variable-initialization\*>s has been accumulated in the
previous step and is available as the value of \*{varinit\*}.
.iy I varinit
.IP 3.
If the \*<program-declaration\*> has a formal parameter
(it may have at most one) then obtain,
in a way left unspecified in this definition,
an array of string values that correspond to the actual parameters
of the invocation of the \*<summer-program\*> from the command level
of the operating system.
If, for example, some \*<summer-program\*> \*{P\*} with formal parameter \*{args\*}
is invoked by the operating system command line:
.DS
\*{P -x abc 1 3\*}
.DE
then \*{args\*} gets a value as if the assignment
.DS
\*{args := ['-x', 'abc', '1', '3']\*}
.DE
had been performed.
Note that the command syntax is operating system dependent.
.IP 4.
Evaluate the
\*<expression\*>
.iy I <expression>
{#{Expressions}}
part of the
\*<program-declaration\*>
.iy I <program-declaration>
in the environment established in step 1 and the state
initialized in steps 2 and 3 above.
.SH #{sn+}. Semantics -
.D{
.so sem/summer-program
.D}
.NO
.IP 1)
The list of declarations is evaluated from left to right.
.IP 2)
The environment component of all $PROCEDURE$ values in the current
environment is adjusted, in order to resolve forward references.
This is fully discussed in Section #{Procedure and operator declarations}.
.IP 3)
Regarding the treatment of signals other than $N$,
\*<variable-initialization\*>s are treated differently when they occur in
a \*<summer-program\*> (above), in an \*<identifier-or-call\*>
related to a class creation procedure {#{Identifiers and procedure calls}},
or in a \*<block\*> {#{Parenthesized expressions and blocks}}.
.IP 4)
The parse-expression `\*{{{ progdecl == PROGRAM ... }}\*}'
always succeeds.
Its only purpose is to extract components from the \*<program-declaration\*>.
.IP 5)
The function \*{get_program_arguments\*} delivers the arguments
of the program as described previously.
It is not further specified in this definition.
.SH #{Variable declarations=sn<+}. "Variable declarations"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <variable-declaration>
.iy I <variable-initialization>
.<<
.so syn/var-decl
.sp 0.5
.so syn/var-init
.>>
.SH #{sn+}. "Pragmatics" -
.PP
A
\*<variable-declaration\*>
.iy I <variable-declaration>
introduces a series of new variables, i.e. names of locations whose contents
may be inspected and/or modified, into the current environment.
The declaration may contain
\*<expression\*>s {#{Expressions}}
whose value is to be used
for the initialization of the declared variables.
If the \*<variable-declaration\*> is immediately contained in a \*<summer-program\*>,
then these initializing expressions are evaluated prior to the evaluation of
the \*<program-declaration\*> {#{Summer program}} in that \*<summer-program\*>.
If the \*<variable-declaration\*> is immediately contained in
a \*<class-declaration\*> {#{Class declarations}},
then these initializations are evaluated prior
to the evaluation of the \*{init\*}-part of that \*<class-declaration\*>
{#{Identifiers and procedure calls}}.
Otherwise, the initializing expressions are evaluated
prior to the evaluation of the \*<expression\*> part of the
\*<block\*>
.iy I <block>
{#{Parenthesized expressions and blocks}}
in which the
\*<variable-declaration\*>
.iy I <variable-declaration>
occurs.
In the formal definition this is described by appending
variable initializations to the string value of
.iy I varinit
variable \*{varinit\*} and by evaluating that value
at appropriate moments
(i.e. before the evaluation of a \*<program-declaration\*>,
the \*{init\*}-part of a \*<class-declaration\*>,
or the \*<expression\*> part of a \*<block\*>).
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/var-decl
.D}
.NO
.IP 1)
\*{varinit\*} is initialized to the empty string
before the evaluation of a \*<summer-program\*> {#{Summer program}},
of a class creation procedure {#{Identifiers and procedure calls}},
or of a block {#{Parenthesized expressions and blocks}}.
.IP 2)
The operator `\*{||\*}' denotes concatenation of strings {#{Lib/string}}.
.SH #{sn+}. "Examples" -
.IP 1)
.{{
var x;
.}}
.IP 2)
.{{
var x, y, z;
.}}
.IP 3)
.{{
var x := 3, y, z := x + 5;
.}}
.SH #{Constant declarations=sn<+}. "Constant declarations"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <constant-declaration>
.iy I <constant-initialization>
.iy I <constant-expression>
.<<
.so syn/const-decl
.sp 0.5
.so syn/const-init
.>>
.SH #{sn+}. "Pragmatics" -
.PP
A
\*<constant-declaration\*>
.iy I <constant-declaration>
introduces a series of new constants, e.g. names with which one, unalterable,
value is associated, into the current environment.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/const-decl
.D}
.NO
.IP 1)
The function
\*{require_constant_expression\*} {#{Constant expressions}}
ensures that a given \*<expression\*> only contains constants.
.IP 2)
The evaluation of
\*<constant-expression\*>s
.iy I <constant-expression> s
is defined in #{Constant expressions}
and is identical to the evaluation of `ordinary'
\*<monadic-expressions\*> {#{Monadic expressions}} and
\*<dyadic-expressions\*> {#{Dyadic expressions}}.
.SH #{sn+}. "Examples" -
.IP 1)
.{{
const a := 1;
.}}
.IP 2)
.{{
const a := 1, b := 3 * (a + 1), c := 'abc' ;
.}}
.SH #{Procedure and operator declarations=sn<+}. "Procedure and operator declarations"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <procedure-declaration>
.iy I <operator-declaration>
.<<
.so syn/proc-decl
.sp 0.5
.so syn/op-decl
.sp 0.5
.so syn/formals
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Both procedure and operator declarations associate a piece of program
with a certain name or operator symbol.
This association is made at the moment of declaration.
How this piece of program can be invoked later on is described
in sections #{Identifiers and procedure calls}, #{Monadic expressions}
and #{Dyadic expressions}.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/proc-decl
.D}
.NO
.IP 1)
An \*{a_proc\*} object with undefined environment component is created.
This environment component will be replaced by a well-defined environment in
either of two ways.
If the declared procedure is global (i.e. if its declaration is immediately
contained in the \*<summer-program\*> {#{Summer program}}),
the undefined environment component is replaced by the global environment
before the evaluation of the \*<program-declaration\*>.
In this way forward references are dealt with.
If the declared procedure is, on the other hand,
contained in a \*<class-declaration\*> {#{Class declarations}},
the undefined environment component is replaced by a well-defined
environment at the moment that an instance of the class is created
{#{Identifiers and procedure calls}}.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
proc fac(n)
.br
( if n = 0
.br
  then
.br
     return(1)
.br
  else
.br
     return(n * fac(n - 1))
.br
  fi
.br
);
.}}
.E}
.sp 0.5
{The procedure \*{fac\*} computes the factorial function.}
.IP 2)
.{{
proc positive(x) return(x > 0);
.}}
.sp 0.5
{The procedure \*{positive\*} succeeds if its argument is greater than zero
and fails otherwise.
A typical use of this procedure is:
.sp 0.5
.{{
	if positive(x) then put('x is positive') fi
.}}
.sp 0.5
}
.IP 3)
.{{
op +? (x) return(x > 0);
.}}
.sp 0.5
{The user-defined monadic operator `\*{+?\*}' has the same effect as the procedure \*{positive\*} of example 2 above.
A typical use is:
.sp 0.5
.{{
	if +? x then put('x is positive') fi
.}}
.sp 0.5
}
.SH #{Class declarations=sn<+}. "Class declarations"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <class-declaration>
.iy I <subclass-declaration>
.iy I <fetch-associations>
.iy I <store-associations>
.iy I <associations>
.iy I <association>
.iy I <field-identifier>
.<<
.so syn/class-decl
.sp 0.5
.so syn/subclass-decl
.sp 0.5
.so syn/fetch-assocs
.sp 0.5
.so syn/store-assocs
.sp 0.5
.so syn/assocs
.sp 0.5
.so syn/assoc
.sp 0.5
.so syn/field-id
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Classes form a data abstraction mechanism and provide the only
means of declaring new data types.
A
\*<class-declaration\*>
.iy I <class-declaration>
introduces a new data type or \fBclass\fP
and all operations which may be performed on
objects or \fBinstances\fP
.iy I instance
of that class.
An instance of a class may be looked upon as consisting of a number
of \fBfields\fP.
Fields may either be passive (and act as simple variables)
or be active (and act as procedures).
.PP
The
\*<class-declaration\*>
.iy I <class-declaration>
may contain declarations for variables, constants,
procedures and operators.
All entities so declared can be used freely inside the class,
but access from the outside is completely controlled by
\*<fetch-associations\*>
.iy I <fetch-associations>
and
\*<store-associations\*>,
.iy I <store-associations> ,
which determine the names that are visible outside the class.
The former specify which parts of the class instance may be
used (`fetched'), the latter
specify which components may be modified (`stored in'), i.e. may occur
on the left hand side of an assignment operator {#{Dyadic expressions}}.
Both kinds of associations allow the specification of a procedure in the
\*<class-declaration\*>
.iy I <class-declaration>
which will perform the actual access.
The process of inspecting or modifying the value of one of the fields
of a class is called \fBfield selection\fP {#{Field selection}}.
.PP
A new instance of a class is created by invoking a
\fBclass creation procedure\fP,
which is derived from the class declaration,
as described in section #{Identifiers and procedure calls}.
.PP
A new class may inherit properties from a previously declared class; this
is indicated by a
\*<subclass-declaration\*>.
.iy I <subclass-declaration> .
Roughly speaking, the declaration of a class whose name occurs in a
\*<subclass-declaration\*>
.iy I <subclass-declaration>
is literally substituted for that
\*<subclass-declaration\*>.
.iy I <subclass-declaration> .
If a
\*<class-declaration\*>
.iy I <class-declaration>
$C$ contains a non-empty
\*<subclass-declaration\*>
.iy I <subclass-declaration>
and that
\*<subclass-declaration\*>
.iy I <subclass-declaration>
contains the \*<identifier\*> $C'$, then
$C$ is said to be a \fBsubclass\fP
of $C'$, or conversely, $C'$ is said to be a \fBsuperclass\fP of $C$.
In principle, $C$ inherits all of the properties of $C'$, unless they
are explicitly redefined in $C$.
This notion of inheritance is realized by adding (parts of) the
\*<class-declaration\*>
.iy I <class-declaration>
of $C'$ to the \*<class-declaration\*> of $C$.
The procedure \*{expand_super_class\*} performs this transformation.$"" sup 1$
.FS
1) The formal definition of this procedure is not given.
.FE
Two additional names for parts of a
\*<class-declaration\*>
.iy I <class-declaration>
will be used
in the following algorithm:
\fBclass-declaration-part\fP will be used to denote all \*<variable-declaration\*>s,
\*<constant-declaration\*>s,
\*<procedure-declaration\*>s and
\*<operator-declaration\*>s contained
in the
\*<class-declaration\*>;
.iy I <class-declaration> ;
\fBclass-initialization-part\fP
will be used to denote the
\*<block\*>
immediately following the `\*{init\*}' keyword
in the
\*<class-declaration\*>.
The following steps describe the process of superclass expansion in detail:
.IP 1.
\fBFormal parameter correspondence\fP.
The formal parameters of $C$ should be an \fBextension\fP
of the formal parameters of $C'$:
if the number of formal parameters of $C$ and $C'$
is $N$ and $N'$ respectively,
then $N'~<=~N$ should hold and the names of the
first $N'$, corresponding, parameters of $C$ and $C'$ should be the same.
.IP 2.
\fBCheck compatibility of declarations\fP.
If a name $A$ is declared in the class-declaration-parts
of both $C$ and $C'$, then those declarations should be similar, i.e.
$A$ should in both cases be declared by the same kind of declaration.
This forbids, for instance, that variables are redeclared as procedures
and vice versa.
This restriction ensures that the result of step 6 (see below) is well-defined.
.IP 3.
\fBSuperclass transformation\fP.
If the declaration of $C'$ contains a non-empty
\*<subclass-declaration\*>
.iy I <subclass-declaration>
then the declaration of $C'$ should first be transformed as described in
this paragraph.
.IP 4.
\fBCombine associations\fP.
\*<fetch-associations\*>
.iy I <fetch-associations>
and
\*<store-associations\*>
.iy I <store-associations>
are inherited from $C'$,
unless they are redefined in $C$.
An
\*<association\*>
.iy I <association>
$A$ occurring in $C'$ is said to be redefined if and
only if the
\*<field-identifier\*>
.iy I <field-identifier>
contained in $A$, also occurs as
\*<field-identifier\*>
.iy I <field-identifier>
in either
\*<store-associations\*>
.iy I <store-associations>
or
\*<fetch-associations\*>
.iy I <fetch-associations>
of $C$.
All \*<associations\*> not redefined
.iy I <associations>
in the
\*<fetch-associations\*>
.iy I <fetch-associations>
of $C'$
are added to the
\*<fetch-associations\*>
.iy I <fetch-associations>
of $C$.
All \*<associations\*> not redefined
.iy I <associations>
in the
\*<store-associations\*>
.iy I <store-associations>
of $C'$
are added to the
\*<store-associations\*>
.iy I <store-associations>
of $C$.
.IP 5.
\fBCombine declaration parts\fP.
Prefix the class-declaration-part of $C$ with the
class-declaration-part of $C'$ from which all redefined declarations
have been removed.
.IP 6.
\fBCombine init parts\fP.
Prefix the class-initialization-part of $C$ with the class-initialization-part
of $C'$.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/class-decl
.D}
.NO
.IP 1)
The result of \*{expand_super_class\*} is a string that has the
form of a \*<class-declaration\*> containing an empty \*<subclass-declaration\*>.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
class complex(re, im)
.br
begin fetch re, im;
.br
      store re, im;
.br
end complex;
.}}
.E}
.sp 0.5
{Defines the class \*{complex\*} with fields \*{re\*} and \*{im\*}.
Both fields may be inspected (`fetched') and modified (`stored').
A typical use of this class is:
.sp 0.5
.{{
	c := complex(1.4, 3.7);
.br
	x := c.re
.}}
.sp 0.5
First, a new instance {#{Identifiers and procedure calls}}
of class \*{complex\*} is assigned to variable \*{c\*}.
Next, the field \*{re\*} is fetched from that instance.
The net effect is that 1.4 is assigned to variable \*{x\*}.}
.IP 2)
.E{
.{{
class stack(n)
.br
begin fetch push, pop;
.br
      var sp, space;
.br
      proc push(x)
.br
      (  if sp = n
.br
         then
.br
            freturn     # stack overflow #
.br
         else
.br
            space[sp] := x; sp := sp + 1;
.br
            return(x)
.br
         fi
.br
      );
.br
      proc pop()
.br
      (  if sp = 0
.br
         then
.br
            freturn     # stack underflow #
.br
         else
.br
            sp := sp - 1; return(space[sp])
.br
         fi
.br
      );
.br
init: sp := 0; space := array(n, undefined)
.br
end stack;
.}}
.E}
.sp 0.5
{Defines the class \*{stack\*} with operations \*{push\*} and \*{pop\*}.
Note that only these fields are accessible from the outside.
A typical use of this class is:
.sp 0.5
.{{
	s := stack(10);
.br
	s.push(1); s.push(2);
.br
	x := s.pop; y := s.pop
.}}
.sp 0.5
which assigns, ultimately, 2 to \*{x\*} and 1 to \*{y\*}.}
.IP 3)
.E{
.{{
class random_access_stack(n)
.br
begin subclass of stack;
.br
      fetch access;
.br
      proc access(i)
.br
      (  if i >= 0 & i < sp
.br
         then
.br
            return(space[i])
.br
         else
.br
            freturn      # out of range #
.br
         fi
.br
      );
.br
end random_access_stack;
.}}
.E}
.sp 0.5
{Declares the class \*{random_access_stack\*}: a kind of stack that
not only defines the operations \*{push\*} and \*{pop\*}, but also defines
the operation \*{access\*} to inspect the value of an arbitrary
element on the stack.
This declaration uses a \*<subclass-declaration\*> to extend
the class \*{stack\*} given in the previous example with
the new operation.
The above declaration is completely equivalent with the following declaration:
.sp 1.5
.E{
.{{
class random_access_stack(n)
.br
begin fetch push, pop, access;
.br
      var sp, space;
.br
      proc push(x)
.br
      (  if sp = n
.br
         then
.br
            freturn     # stack overflow #
.br
         else
.br
            space[sp] := x; sp := sp + 1;
.br
            return(x)
.br
         fi
.br
      );
.br
      proc pop()
.br
      (  if sp = 0
.br
         then
.br
            freturn     # stack underflow #
.br
         else
.br
            sp := sp - 1; return(space[sp])
.br
         fi
.br
      );
.br
      proc access(i)
.br
      (  if i >= 0 & i < sp
.br
         then
.br
            return(space[i])
.br
         else
.br
            freturn      # out of range #
.br
         fi
.br
      );
.br
init: sp := 0; space := array(n, undefined)
.br
end random_access_stack;
.}}
.E}
.sp 0.5
This second declaration of \*{random_access_stack\*} is the result
of applying \*{expand_super_class\*} to the first declaration of
\*{random_access_stack\*} given above.}
.SH #{Operator symbol declarations=sn<+}. "Operator symbol declarations"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <operator-symbol-declaration>
.iy I <operator-symbol>
.<<
.so syn/op-symbol-decl
.>>
.SH #{sn+}. "Pragmatics" -
.PP
An
\*<operator-symbol-declaration\*>
.iy I <operator-symbol-declaration>
indicates that the \*<operator-symbol\*>s contained in it
denote user-defined monadic or dyadic operators.
An \*<operator-symbol-declaration\*> is only required for
\*<operator-symbol\*>s that are used before they are declared
(in an \*<operator-declaration\*> {#{Procedure and operator declarations}}).
Since arbitrary sequences of \*<operator-symbol\*>s can follow each other without
intervening layout symbols, it is necessary to have rules for
disambiguating certain combinations of \*<operator-symbol\*>s.
For example, should
.DS
.{{
x+-y
.}}
.DE
be interpreted as
.DS
.{{
x + (-y)
.}}
.DE
with \*{+\*} dyadic and \*{-\*} monadic, or as
.DS
.{{
x +- y
.}}
.DE
with \*{+-\*} dyadic?
The following rules describe the decomposition of adjacent \*<operator-symbol\*>s.
An \*<operator-symbol\*> occurring at the syntactic position of a
\*<monadic-operator\*>
.iy I <monadic-operator>
is decomposed in one or more `monadic' \*<operator-symbol\*>s.
An \*<operator-symbol\*> occurring at the position of a
\*<dyadic-operator\*>
.iy I <dyadic-operator>
is decomposed into one `dyadic' \*<operator-symbol\*>
and zero or more `monadic' \*<operator-symbol\*>s.
These rules are sufficient because there are no postfix operators in \s-2SUMMER\s0.
.PP
The decomposition rules are now described in detail.
For each \*<operator-symbol\*> that occurs at the position of a
\*<monadic-operator\*>
.iy I <monadic-operator>
(or \*<dyadic-operator\*>)
.iy I <dyadic-operator> )
the longest initial substring $S$ of the \*<operator-symbol\*> is taken such that:
.IP 1.
$S$ is of the form \*{'_'\*} (\*<letter\*> | \*<digit\*>)+ \*{'_'\*}, or
.IP 2.
$S$ is a
\*<monadic-operator\*>
.iy I <monadic-operator>
(or
\*<dyadic-operator\*>), and either
.iy I <dyadic-operator> "), and either"
$S$ occurs as \*<operator-symbol\*> in an
\*<operator-declaration\*>
.iy I <operator-declaration>
with one (or two)
\*<formals\*>, or
.iy I <formals> ", or"
$S$ occurs as \*<operator-symbol\*> in a
\*<operator-symbol-declaration\*>
.iy I <operator-symbol-declaration>
that contains the keyword `\*{monadic\*}' (or `\*{dyadic\*}').
.LP
If no such substring exists, the original \*<operator-symbol\*> is not identified.
If $S$ is a proper substring of the \*<operator-symbol\*>, the
tail of the \*<operator-symbol\*> should be decomposable into one or more
\*<monadic-operator\*>s (in both cases).
.br
.ne 10
.SH #{sn+}. "Semantics" -
.PP
\*<operator-symbol-declaration\*>s only affect the lexical structure
of a program but have no associated semantics.
.NO
.IP 1)
An \*<operator-symbol-declaration\*> may only occur at the outermost level
of declarations, i.e. immediately contained in a \*<summer-program\*>.
.IP 2)
An \*<operator-symbol\*> may not occur in both `monadic' and `dyadic'
\*<operator-symbol-declaration\*>s.
.SH #{sn+}. "Examples" -
.IP 1)
.{{
monadic +?, **, @ ;
.}}
.sp 0.5
{Declares the three \*<operator-symbol\*>s `\*{+?\*}', `\*{**\*}' and `\*{@\*}'
as monadic operators.
After this declaration, the expression
\*{a***b\*}
will be interpreted as \*{a*(**b)\*}.}
.IP 2)
.{{
dyadic <=>, **, _matvec_ ;
.}}
.sp 0.5
{Declares the three \*<operator-symbol\*>s `\*{<=>\*}', `\*{**\*}' and `\*{_matvec_\*}'
as dyadic operators.
After this declaration, the expression
\*{a***b\*}
will be interpreted as \*{a**(*b)\*}.}
.SH #{Expressions=sn<<+}. "Expressions"
.PP
S\s-2UMMER\s0 is an expression oriented language:
most language constructs can be derived
from the syntactic notion \*<expression\*> and can deliver a value.
The main rules related to expressions are:
.sp 1
.iy I <expression>
.<<
.so syn/expr
.sp 0.5
.so syn/monadic-expr
.sp 0.5
.so syn/monadic-op
.sp 0.5
.so syn/dyadic-expr
.sp 0.5
.so syn/dyadic-op
.sp 0.5
.so syn/primary
.sp 0.5
.so syn/unit
.>>
.sp 1
Note that the rules for \*<monadic-operator\*> and \*<dyadic-operator\*>
are ambiguous, i.e. their first alternatives
are all subsumed by the last one that refers to an \*<operator-symbol\*>.
Nonetheless, this distinction has been made to stress the privileged
position of certain operators (regarding, for instance, syntactic priority).
See also Sections #{Monadic expressions} and #{Dyadic expressions}.
.PP
A more detailed description of \*<expression\*>s follows.
.SH #{Constants=sn>1}. "Constants"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <string-constant>
.iy I <integer-constant>
.iy I <real-constant>
.iy I <constant>
.<<
.so syn/constant
.>>
.SH #{sn+}. "Pragmatics" -
.PP
\*<constant\*>s provide an alternative, more convenient, notation for the
values of some built-in classes.
When a constant is encountered during evaluation, a new instance of
the corresponding class is created.
.br
.ne 7
.SH #{sn+}. "Semantics" -
.LP
The semantics of \*<integer-constant\*>s is:
.D{
.so sem/expr:integer
.D}
.br
.ne 6
.LP
The semantics of \*<string-constant\*>s is:
.D{
.so sem/expr:string
.D}
.br
.ne 4
.LP
The semantics of \*<real-constant\*>s is:
.D{
.so sem/expr:real
.D}
.NO
.IP 1)
The first and last character (i.e. the surrounding quotes)
of a \*<string-constant\*> are first deleted before
a new instance of class \*{string\*} is created.
.IP 2)
The semantics of the class \*{real\*} are not given as part of
the definition of the \s-2SUMMER\s0 kernel {#{Unspecified}}.
Here, it is only established that \*<real-constant\*>s
are denotations for instances of the class \*{real\*};
the semantics of the class \*{real\*} itself is described informally in the
next chapter {#{Lib/real}}.
.SH #{sn+}. "Examples" -
.IP 1)
\&\*{'star\twars'\*}
.IP 2)
.{{
314
.}}
.IP 3)
.{{
-3.14e+5
.}}
.SH #{Identifiers and procedure calls=sn<+}. "Identifiers and procedure calls"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <identifier-or-call>
.iy I <identifier>
.iy I <actuals>
.<<
.so syn/id-or-call
.sp 0.5
.so syn/actuals
.>>
.SH #{sn+}. "Pragmatics" -
.PP
When an
\*<identifier\*>
.iy I <identifier>
occurs in an
\*<expression\*> {#{Expressions}}, it depends on the
existence and kind of binding of that \*<identifier\*> what will be the result of
its evaluation.
If the \*<identifier\*> is bound to a value in $INSTANCE$ or $LOCATION$,
that value will be the result.
This value is \fBnot\fP dereferenced {#{Dereference}}, i.e.
if the value is a location, that location itself
and not its contents are the result.
If the \*<identifier\*> is bound to a value in $PROCEDURE$ or $CLASS$,
the \*<identifier\*> is evaluated as a procedure call (see below).
If none of the above cases applies, a field selection {#{Field selection}} from
.iy I subject
the current value of \*{subject\*} is performed {#{Scan expressions}}.
.PP
A procedure call serves the purpose of temporarily suspending the current evaluation
and starting the evaluation of the procedure associated with the \*<identifier\*>
in the
\*<identifier-or-call\*>.
The \*<identifier\*> may be followed by a (possibly empty) list of \*<actual\*>s.
The \*<expression\*>s in \*<actuals\*> are evaluated from left to right.
The dereferenced value of each
\*<expression\*>
.iy I <expression>
is passed as actual parameter to the called procedure.
Since that value may be an instance of a class that allows modification of
its instances (say, an array {#{Lib/array}}),
modifications made to that instance are visible in the calling context.
However, the contents of locations bound to local variables of the caller
can never be modified by the called procedure.
In \s-2CLU\s0 [Liskov77], this parameter passing mechanism has been named
\fBcall-by-sharing\fP.
.PP
The procedure call itself is handled by \*{eval_call\*}.
If the name of the procedure to be called is either
\*{string\*} {#{Lib/string}},
or \*{integer\*} {#{Lib/integer}}, or \*{undefined\*}
{#{Semantic considerations}}, or \*{type\*} {#{Lib/type}},
then the call is treated separately by \*{eval_standard_procedure\*}
as can be seen in the formal definition.
Otherwise, there are two cases, depending on whether the \*<identifier\*> in the
procedure call is bound to a value in $PROCEDURE$ or in $CLASS$.
.PP
In the former case,
the procedure has to be evaluated in the environment of its declaration.
To this end, the current environment is saved,
a copy of the declaration environment of the procedure is made the current
environment and the
\*<formals\*>
.iy I <formals>
in the associated
\*<procedure-declaration\*>
.iy I <procedure-declaration>
are bound from left to right to the values of the \*<actuals\*> in the call.
Next, the body of the procedure is evaluated
and the result of this evaluation is the result of the procedure call.
Finally, the previous (saved) environment is restored.
Note how in the formal definition (see below), an $FR$ signal is turned
into an $F$ signal, and how an $NR$ signal is turned into an $N$ signal;
this was already discussed in Section #{Evaluation process}.
.PP
If the \*<identifier\*> in the procedure call is bound to
a value in $CLASS$, a new instance of that class must be created.
This amounts to creating a new composite-instance that contains
an, appropriately adjusted, copy of the declaration environment of that class.
To this end, the following steps are taken.
First, the current environment is saved.
Next, a copy of the declaration environment is created and the
\*<formals\*>
.iy I <formals>
are bound to actual values as described above.
In addition to this, all declarations in the associated
\*<class-declaration\*>
.iy I <class-declaration>
are evaluated and a new instance is created, containing the name
of the class and the environment just constructed.
The new instance is bound to the identifier \*{self\*}
.iy I self
in the new environment.
If the
\*<class-declaration\*>
.iy I <class-declaration>
contains an init-part, then the
\*<block\*>
.iy I <block>
following the `\*{init\*}' keyword is evaluated in the new environment.
Finally, the original environment is restored and the instance
is returned as the result of the procedure call.
.SH #{sn+}. "Semantics" -
.LP
The semantics of an \*<identifier-or-call\*> is:
.D{
.so sem/call
.iy I subject
.D}
.LP
The definition of \*{eval_call\*} is:
.D{
.iy I "instance (creation of)"
.iy I "self"
.iy I "type"
.so sem/eval_call
.D}
.LP
The definition of \*{eval_standard_procedure\*} is:
.D{
.so sem/eval_standard_procedure
.D}
.NO
.IP 1)
The function \*{dereference\*} is described in {#{Dereference}}.
.IP 2)
The above definition realizes a call-by-sharing
parameter passing mechanism (described previously).
.IP 3)
The binding of \*{self\*} affects the environment component of the
newly created composite-instance.
.IP 4)
Regarding the treatment of signals other than $N$,
\*<variable-initialization\*>s are treated differently when they occur in
a \*<summer-program\*> {#{Summer program}}, in an \*<identifier-or-call\*>
related to a class creation procedure (see above),
or in a \*<block\*> {#{Parenthesized expressions and blocks}}.
.IP 5)
The treatment of \*<formals\*> of procedures and classes differs:
the formals of a procedure exist only temporarily during the call
of the procedure;
the formals of a class are made part of the environment component of
the new composite-instance which survives the call of the
class creation procedure.
.IP 6)
The definitions of \*{integer\*} and \*{string\*} given above are slightly
simplified versions of the definitions given in
Sections #{Lib/integer} and #{Lib/string} respectively.
.SH #{sn+}. "Examples" -
.IP 1)
.{{
x
.}}
.sp 0.5
{Has as value either the value of the (local or global)
constant or variable \*{x\*},
the value of a call to the procedure
(either a class creation procedure or an ordinary procedure)
with name \*{x\*}, or,
if none of the previous cases applies,
the value of the field selection \*{subject.x\*}
{#{Scan expressions}, #{Field selection}}.}
.iy I subject
.IP 2)
.{{
fac(5)
.}}
.sp 0.5
{Calls procedure \*{fac\*} with actual parameter 5.}
.IP 3)
.{{
integer('123')
.}}
.sp 0.5
{Calls the class creation procedure \*{integer\*}, which returns an instance of
class \*{integer\*} {#{Lib/integer}}.}
.SH #{Return expressions=sn<+}. "Return expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <return-expression>
.<<
.so syn/return-expr
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Return expressions terminate the evaluation of the current procedure
and give control back to the caller of the current procedure.
An `\*{freturn\*}' causes the call of the current procedure to fail.
A `\*{return\*}' not followed by an
\*<expression\*>, transfers control to the caller
without returning a value.
A `\*{return\*}' followed by an
\*<expression\*> first evaluates that
\*<expression\*>
and then transmits its value to the caller.
.br
.ne 10
.SH #{sn+}. Semantics -
.LP
The semantics of a \*{return\*} not followed by an \*<expression\*> is:
.D{
.so sem/return0
.D}
.LP
The semantics of a \*{return\*} followed by an \*<expression\*> is:
.D{
.so sem/return1
.D}
.LP
The semantics of an \*{freturn\*} is:
.D{
.so sem/freturn
.D}
.NO
.IP 1)
The environment of the caller is, ultimately, re-established by \*{eval_call\*}
{#{Identifiers and procedure calls}}.
.SH #{sn+}. Examples -
.IP 1)
.{{
return
.}}
.sp 0.5
{Returns from the current procedure without delivering a value.}
.IP 2)
.{{
return(x)
.}}
.sp 0.5
{Returns from the current procedure and delivers the value of \*{x\*}.}
.IP 3)
.{{
return(x > 3)
.}}
.sp 0.5
{The same as the previous example, but note that the expression `\*{x > 3\*}'
can fail. In that case the call to the current procedure also fails.}
.IP 4)
.{{
freturn
.}}
.sp 0.5
{The call to the current procedure is completed and the call
as a whole fails.}
.XP 6
.SH #{If expressions=sn<+}. "If expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <if-expression>
.iy I <test>
.<<
.so syn/if-expr
.sp 0.5
.so syn/test
.>>
.SH #{sn+}. "Pragmatics" -
.PP
An \*<if-expression\*> corresponds to the if-then-else statement found
in most programming languages.
First, the
\*<test\*>
.iy I <test>
part of the
\*<if-expression\*>
.iy I <if-expression>
is evaluated.
A
\*<test\*>
.iy I <test>
is either an
\*<expression\*>
.iy I <expression>
or an \*<expression\*> followed
by `\*{fails\*}' or `\*{succeeds\*}'. The suffix operator `\*{fails\*}'
transforms failure into success and vice versa.
The suffix operator `\*{succeeds\*}' has no affect whatsoever, but exists for
reasons of symmetry.
.PP
If evaluation of the
\*<test\*>
.iy I <test>
part of the
\*<if-expression\*>
.iy I <if-expression>
terminates successfully, the
\*<block\*>
.iy I <block>
following `\*{then\*}' is evaluated.
Otherwise, the
\*<test\*>s of successive `\*{elif\*}\|'s
are evaluated until one of them terminates successfully
(in which case the corresponding
\*<block\*>
.iy I <block>
is evaluated) or the list is exhausted.
In the latter case, the
\*<block\*>
.iy I <block>
following `\*{else\*}' (if any) is evaluated.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.LP
The semantics of a \*<test\*> is:
.D{
.so sem/test
.D}
.LP
.br
.ne 8
The semantics of an \*<if-expression\*> is:
.D{
.so sem/if-expr
.D}
.NO
.IP 1)
The case that a \*<test\*> contains neither `\*{succeeds\*}' nor `\*{fails\*}'
is already covered by the evaluation of \*<expression\*>s
{#{Monadic expressions}, #{Dyadic expressions}}.
.IP 2)
A \*<block\*> may be empty, see {#{Parenthesized expressions and blocks}}.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
if x > 0 then put('x is positive') fi
.}}
.E}
.IP 2)
.E{
.{{
if x > 0
.br
then
.br
   put('positive')
.br
else
.br
   put('negative or zero')
.br
fi
.}}
.E}
.IP 3)
.E{
.{{
if x > 0
.br
then
.br
   put('positive')
.br
elif x = 0
.br
then
.br
   put('zero')
.br
else
.br
   put('negative')
.br
fi
.}}
.E}
.IP 4)
.E{
.{{
y := if x > 0 then 1 else 0 fi
.}}
.E}
.SH #{Case expressions=sn<+}. "Case expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <case-expression>
.iy I <case-entry>
.iy I <constant-expression>
.<<
.so syn/case-expr
.sp 0.5
.so syn/case-entry
.>>
.SH #{sn+}. "Pragmatics" -
.PP
A \*<case-expression\*> provides a multi-way branch.
A
\*<case-expression\*>
.iy I <case-expression>
of the form
.sp 0.5
.RS
$bold case~e sub 0~bold of$
.br
$k sub 11~:~...~:~k sub {1 m sub 1}~:~mark e sub 1~,$
.br
$k sub 21~:~...~:~k sub {2 m sub 2}~:~lineup e sub 2~,$
.br
$~...$
.br
$k sub n1~:~...~:~k sub {n m sub n}~:~lineup e sub n$
.br
$bold default~:~ e sub {n+1}$
.br
$bold esac$
.RE
.sp 0.5
is equivalent to:
.sp 0.5
.RS
$phi~:=~e sub 0 ;$
.br
$bold "if"~~~phi~=~k sub 11~|~...~|~phi~=~k sub {1 m sub 1}~bold then~e sub 1$
.br
$bold elif~phi~=~k sub 21~|~...~|~phi~=~k sub {2 m sub 2}~bold then~e sub 2$
.br
$~...$
.br
$bold elif~phi~=~k sub n1~|~...~|~phi~=~k sub {n m sub n}~bold then~e sub n$
.br
$bold else~e sub {n+1}$
.br
$bold fi$
.RE
.sp 0.5
where $phi$ is assumed to be a name, not occurring elsewhere in the program.
All \*<case-entry\*>s must be constant expressions.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/case-expr
.D}
.NO
.IP 1)
The function \*{equal\*} is described in {#{Equal}}.
.IP 2)
The function \*{dereference\*} is described in {#{Dereference}}.
.IP 3)
The function \*{require_constant_expression\*} is described in
{#{Constant expressions}}.
.IP 4)
It is not required that the \*<constant-expression\*>s
in all \*<case-entry\*>s are distinct.
However, no nondeterminism is introduced by the multiple
occurrence of the same \*<case-entry\*>.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
case x of
.br
 'pi':     put('name of pi as string'),
.br
 '3.14':   put('value of pi as string'),
.br
 3.14:     put('value of pi as real')
.br
 default:  put('x not recognized')
.br
esac
.}}
.E}
.sp 0.5
{Note that each
\*<case-entry\*>
.iy I <case-entry>
may be of a different type.}
.IP 2)
.E{
.{{
y :=  7;
.br
x :=  case y of
.br
      1: 7: 13: spec_val
.br
      default:  general_val
.br
      esac
.}}
.E}
.sp 0.5
{Note how a
\*<case-expression\*>
.iy I <case-expression>
delivers the value of the selected case
as value. Here, the value of \*{spec_val\*} is assigned to \*{x\*}.}
.IP 3)
.E{
.{{
case type(x) of
.br
 'string':   put('x has string as value'),
.br
 'integer':  put('x has integer as value'),
.br
 'array':    put('x has array as value')
.br
 default:    put('type of value of x not recognized')
.br
esac
.}}
.E}
.sp 0.5
{Note how the combination of the procedure \*{type\*} {#{Lib/type}} and
\*<case-expression\*>s can be used for run-time type determination.}
.SH #{While expressions=sn<+}. "While expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <while-expression>
.iy I <test>
.<<
.so syn/while-expr
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Apart from the use of recursion to express iteration,
\*<while-expression\*>s
.iy I <while-expression> s
are, in principle, the only available iteration construct.
(In the next paragraph we will see that a
\*<for-expression\*>
.iy I <for-expression> s
is only a syntactic shorthand for a special form of \*<while-expression\*>.)
As long as the
\*<test\*>
.iy I <test>
part of a
\*<while-expression\*>
.iy I <while-expression>
succeeds, its
\*<block\*>
.iy I <block>
will be evaluated.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/while-expr
.D}
.NO
.IP 1)
The \*<block\*> of a \*<while-expression\*> may not fail.
If it does fail, then evaluation of the \*<while-expression\*> is terminated.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
n := 0;
.br
while n < 10 do put(n, '\n'); n := n + 1 od
.}}
.E}
.sp 0.5
{Prints the integers from 0 to 9 on consecutive lines.}
.IP 2)
.E{
.{{
while line := input.get do process(line) od
.}}
.E}
.sp 0.5
{Processes all lines of the file to which the variable \*{input\*} refers.
The operation \*{input.get\*} {#{Lib/file}} fails on end-of-file.}
.SH #{For expressions=sn<+}. "For expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <for-expression>
.<<
.so syn/for-expr
.>>
.SH #{sn+}. "Pragmatics" -
.PP
A \*<for-expression\*> provides a shorthand for a particular kind
of
\*<while-expression\*>
.iy I <while-expression>
and serves the purpose of iterating over class instances
on which the operation \*{next\*} is defined.
.iy I next
By convention$"" sup 2$,
.FS
2) All \*{next\*} operations defined on built-in classes have this
form, and a run-time error will result if a user-defined \*{next\*} operation
does not conform to it.
.FE
this operation has one parameter \*{state\*}, which keeps accounts of
the progress of the iteration.
At the start of each \*<for-expression\*>, \*{state\*} is initialized to `\*{undefined\*}\|'
At each step of the iteration \*{next\*} is called and
delivers either an array of two elements
($[v,~s]$, where \*{v\*} is the value to be used in the current step and \*{s\*}
is the state to be used in the next step),
or fails, to indicate that the
\*<for-expression\*>
.iy I <for-expression>
should terminate.
Given this behavior of \*{next\*} one can rewrite a
\*<for-expression\*>
.iy I <for-expression>
of the form
.D{
.{{
for x in y do z od
.}}
.D}
as
.D{
.{{
gen   := y;
state := undefined;
while [x,state] := gen.next(state) do z od;
.}}
.D}
.sp 0.5
where \*{gen\*} and \*{state\*} are assumed to be names not occurring elsewhere
in the program.
.SH #{sn+}. "Semantics" -
.D{
.so sem/for-expr
.D}
.NO
.IP 1)
This semantic definition is equivalent to the
textual rewriting of \*<for-expression\*>s, as shown in the previous section,
but it avoids explicit rewriting because this is alien to the style of
definition used here.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
class interval(from, to, by)
.br
begin fetch next;
.sp 1
      proc next(state)
.br
      (  var cur;
.br
         if state = undefined
.br
         then
.br
            cur := from
.br
         else
.br
            cur := state + by
.br
         fi;
.br
         if (from <= to & cur <= to) | (from > to & cur >= to)
.br
         then
.br
            return([cur, cur])
.br
         else
.br
            freturn
.br
         fi
.br
        );
.br
init:   if (from <= to & by < 0) | (from > to & by > 0) | by = 0
.br
        then
.br
           freturn
.br
        fi
.br
end interval;
.}}
.E}
.sp 0.5
{This is an example of a user-defined \*{next\*} operation.
The argument \*{state\*} is used to administer the progress of the iteration.
Initially, \*{state\*} has the value \*{undefined\*}.
An example of the use of this class is given below.
See also #{Lib/interval}.}
.IP 2)
.E{
.{{
for n in interval(0, 10, 1) do put(n, '\n') od
.}}
.E}
.sp 0.5
{Prints the values 0 to 10 on consecutive lines.}
.IP 3)
.E{
.{{
for c in 'abcd' do put(c, '\n') od
.}}
.E}
.sp 0.5
{Prints the characters `\*{a\*}', `\*{b\*}', `\*{c\*}' and `\*{d\*}\|' on consecutive lines.
See also #{Lib/string}.}
.SH #{Try expressions=sn<+}. "Try expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <try-expression>
.<<
.so syn/try-expr
.>>
.SH #{sn+}. "Pragmatics" -
.PP
A \*<try-expression\*> provides a facility for eliminating the side-effects
of the evaluation of a failing expression.
A \*{partial_state_copy\*} {#{Semantic domains}} is made before each
\*<expression\*> is evaluated.
If the evaluation of the \*<expression\*> is successful, the
\*<block\*>, if any, is evaluated.
If that evaluation is also successful, the
\*<try-expression\*>
.iy I <try-expression>
as a whole
succeeds and all side-effects are made `permanent' (see below).
If the evaluation of either the \*<expression\*> or the \*<block\*>
fails, then the original environment is restored
(except for the local variables of the current procedure, which
are not restored to their previous values, (see below))
and the next \*<expression\*> is evaluated.
This process is repeated until success is achieved or the list of
\*<expression\*>s is exhausted.
In the latter case, the original environment is restored 
(again the values of local variables are excluded)
and the \*<try-expression\*> fails.
.PP
The values of local variables of the procedure in which the
\*<try-expression\*> occurs are \fBnever\fP
restored and can hence be used to pass information
from an attempt that has failed to the next one.
Since \*<try-expression\*>s can be nested dynamically, the side-effects of
an innermost \*<try-expression\*> may be undone by an enclosing \*<try-expression\*>.
In this sense, only side-effects of an outermost \*<try-expression\*> are `permanent'.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/try-expr
.D}
.NO
.IP 1)
In the above definition, it is essential that objects can be \fBshared\fP.
Consider, for instance, the first assignment \*{ENV1 := ENV\*}.
Here, a reference to the value of \*{ENV\*} (an environment)
is assigned to \*{ENV1\*}, instead of \fBcopying\fP
the whole environment and assigning that value to \*{ENV1\*}.
This has as consequence that, for instance, all locations
which occur in the environment are shared by \*{ENV1\*} and \*{ENV\*}.
This is precisely what is needed for communicating modifications of
values in the environment to the evaluations of enclosing constructs
after successful completion of the \*<try-expression\*>.
The complementary situation (all locations are copied except the
locations of the local variables of the current procedure)
is realized by the \*{partial_state_copy\*} operation.
.IP 2)
The operation \*{partial_state_copy\*} has been defined
in such a way that the locations associated with local variables
of the current procedure are shared by the original and copied environments.
This achieves the effect that the values of these local variables are never
restored.
.IP 3)
Evaluation of a
\*<return-expression\*>
.iy I <return-expression>
{#{Return expressions}} contained in a
\*<try-expression\*>
.iy I <try-expression>
leads to premature completion of the evaluation of that \*<try-expression\*>.
For a normal return (`\*{return\*}') the environment is not restored;
for a failure return
(either an `\*{freturn\*}' or a `\*{return\*}' of a failing expression)
the environment is restored.
.IP 4)
Side-effects on files {#{Lib/file}} are also recovered.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
x := g := 0;
.br
try x := g := -1, x := g := 1 until positive(x) yrt
.}}
.E}
.sp 0.5
{Assume that \*{x\*} is a local variable and \*{g\*} is a global variable.
After the evaluation of $x~:=~g~:=~-1$, the test fails and the
previous value of $g$ (i.e. 0) is restored. $x$, being a local variable,
keeps its current value (i.e. $-1$).
Next, $x~:=~g~:=~1$ is evaluated and the test succeeds.
The evaluation of the \*<try-expression\*> is complete and $g$ keeps
its value (i.e. 1).}
.IP 2)
.E{
.{{
if try index := input_contains(search_key) yrt
.br
then
.br
   process(index)
.br
else
.br
   put('key not found')
.br
fi
.}}
.E}
.sp 0.5
{Suppose that \*{input_contains(search_key)\*} is a user-defined procedure that reads some
input from a file and succeeds or fails depending on whether that input contains
the \*{search_key\*} as literal substring.
If this procedure succeeds then the input is irrevocably consumed.
However, if it fails then all read operations are reversed and all other
side-effects are undone.
The net effect of expressions of the form `\*{if try ... yrt then ... \*}'
is to \fBprobe\fP
without disturbing the program state (apart from local modifications)
if the probe fails.}
.SH #{Scan expressions=sn<+}. "Scan expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <scan-expression>
.<<
.so syn/scan-expr
.>>
.SH #{sn+}. "Pragmatics" -
.PP
A \*<scan-expression\*> serves the purpose of introducing a new `focus of activity'
which need not be mentioned explicitly during the evaluation of
the associated \*<block\*>.
This is particularly useful in (but not restricted to) string scanning to avoid
.iy I subject
having to mention the subject string for each scanning operation.
First, the
\*<expression\*>
is evaluated.
If the result is of type \*{string\*}, it is converted to type \*{scan_string\*}
.iy I scan_string
{#{Lib/scan_string}}.
The value obtained in this way is bound to the identifier \*{subject\*}
.iy I subject
in the current environment, after saving the previous binding of \*{subject\*}.
Next the \*<block\*>
is evaluated, and finally the previous value of \*{subject\*}
.iy I subject
is restored.
.PP
Note that the rules for identifier identification {#{Identifiers and procedure calls}}
are in accordance with the semantics of
\*<scan-expression\*>s:
.iy I <scan-expression> s:
identifiers which are not bound to some $DENOTABLE$-$VALUE$
{#{Semantic domains}}
.iy I subject
are interpreted as fields to be selected from the current value of \*{subject\*}.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/scan-expr
.D}
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
scan 'aardvark,able,baker,clerk,'
.br
for
.br
    while x := break(',')
.br
    do put(x, '\n'); move(1) od
.br
rof
.}}
.E}
.sp 0.5
{\*{break\*} {#{Lib/scan_string}} assigns the string values \*{'aardvark'\*}
through \*{'clerk'\*} to the variable \*{x\*}.
These values of \*{x\*} are printed on consecutive lines.}
.IP 2)
.E{
.{{
name :=  scan  l
.br
         for
.br
               any(letter) || (span(letgit) | empty)
.br
         rof
.}}
.E}
.sp 0.5
{Assumes that the value of \*{l\*} starts with an identifier-like string
and assigns that string to \*{name\*}.}
.SH #{Assert expressions=sn<+}. "Assert expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <assert-expression>
.<<
.so syn/assert-expr
.>>
.SH #{sn+}. "Pragmatics" -
.PP
An \*<assert-expression\*> provides a means of specifying an assertion,
which should hold at the point where the assertion occurs.
The \*<expression\*> part of the
\*<assert-expression\*>
.iy I <assert-expression>
is evaluated.
It is an error if that \*<expression\*> cannot be evaluated successfully.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/assert-expr
.D}
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
assert pi > 0
.}}
.E}
.sp 0.5
{The execution of the program is terminated if the condition \*{pi > 0\*} fails.}
.XP 3
.SH #{Parenthesized expressions and blocks=sn<+}. "Parenthesized expressions and blocks"
.iy I <parenthesized-expression>
.iy I <block>
.iy I <variable-declaration>
.iy I <constant-declaration>
.SH #{sn>a}. "Syntax" -
.LP
.<<
.so syn/par-expr
.sp 0.5
.so syn/block
.>>
.SH #{sn+}. "Pragmatics" -
.PP
\*<parenthesized-expression\*>s can be used to indicate explicitly
the desired grouping in an expression or to introduce
a new \*<block\*> during the evaluation of an \*<expression\*>.
A \*<block\*> introduces a new scope for the variables and constants declared in it.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.LP
The semantics of a \*<parenthesized-expression\*> is:
.D{
.so sem/par-expr
.D}
.LP
The semantics of a \*<block\*> is:
.D{
.so sem/block
.D}
.NO
.IP 1)
The evaluation of a \*<variable-declaration\*> or \*<constant-declaration\*>
can never fail, i.e. it always returns the signal value $N$.
.IP 2)
Regarding the treatment of signals other than $N$,
\*<variable-initialization\*>s are treated differently when they occur in
a \*<summer-program\*> {#{Summer program}}, in an \*<identifier-or-call\*>
related to a class creation procedure {#{Identifiers and procedure calls}},
or in a \*<block\*> (see above).
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
(var t; t := a; a := b; b := t)
.}}
.E}
.sp 0.5
{A new local variable \*{t\*} is declared. The above expression could also be
used as a subexpression.
This is the case in
.sp 0.5
.{{
	x := (var t; t := a; a := b; b := t)
.}}
.sp 0.5
which assigns the result of $b~:=~t$ \ \(emin this case the old value of \*{a\*}\(em\ 
to \*{x\*}.}
.IP 2)
.E{
.{{
if a > 0 then var x := a * a; return((x-1) * (x+1)) fi
.}}
.E}
.sp 0.5
{Note that \*{x\*} is declared as a local variable in
the \*{then\*}-part of the \*<if-expression\*>.}
.SH #{Array expressions=sn<+}. "Array expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <array-expression>
.iy I <size-and-default>
.iy I <array-initialization>
.<<
.so syn/array-expr
.sp 0.5
.so syn/sizedef
.sp 0.5
.so syn/array-init
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Class $array$
provides a storage facility that associates integer indices with
arbitrary values.
The definition of this class is given in the next chapter {#{Lib/array}}.
Here, only \*<array-expression\*>s are defined.
These introduce an abbreviated
notation for the creation of arrays (that is, instances of class $array$).
The various forms of \*<array-expression\*>s can be rewritten as follows.
An \*<array-expression\*> of the (first) form
.sp 0.5
.RS
$array(e sub 1 ,~e sub 2 )~bold init~[~i sub 0 ~,...,~i sub {n-1}~]$
.RE
.sp 0.5
is equivalent to
.sp 0.5
.RS
$phi~:=~array(e sub 1 ,~e sub 2 );$
.br
$phi~[0]~:=~i sub 0 ;$
.br
$~...$
.br
$phi~[n-1]~:=~i sub {n-1};$
.RE
.sp 0.5
where $phi$ is assumed to be a name, not occurring elsewhere in the program.
An \*<array-expression\*> of the (second) form
.sp 0.5
.RS
$[i sub 0 ~,...,~i sub {n-1}~]$
.RE
.sp 0.5
is equivalent to
.sp 0.5
.RS
$array(n,~undefined)~bold init~[~i sub 0 ~,...,~i sub {n-1}~]$
.RE
.sp 0.5
which can be rewritten according to the previous rule.
.PP
The first \*<expression\*> in the \*<size-and-default\*> defines the length of
the array.
The second \*<expression\*> defines the default initialization value for the array
elements.
.SH #{sn+}. "Semantics" -
.LP
The semantics of an \*<array-expression\*> of the first form is:
.D{
.so sem/array1
.D}
.LP
.ne 5
The semantics of an \*<array-expression\*> of the second form is:
.D{
.so sem/array2
.D}
.LP
.ne 6
The actual creation and initialization of instances of the class \*{array\*}
is performed by \*{eval_array_init\*}, defined below:
.D{
.so sem/eval_array_init
.D}
.NO
.IP 1)
The size of an array should be greater than or equal to zero.
.IP 2)
An array denotation, i.e. an expression of the form of an \*<array-initialization\*>,
may also appear on the left hand side of
an assignment operator and then denotes
a multiple assignment {#{Dyadic expressions}}.
.IP 3)
Array-elements are initialized by means of \*{update\*}
.iy I update
operations {#{Field selection}, #{Dyadic expressions} and #{Lib/array}}.
.IP 4)
The formal definition relies on the existence of a
\*<class-declaration\*>
.iy I array
for \*{array\*} outside the kernel {#{Lib/array}}.
See Section #{Unspecified} for a more extensive explanation of this topic.
.IP 5)
The above definition is intentionally general.
Before the initialization loop is performed,
the number of initial
values could be compared with the size of the new array
to ensure that its bounds would not be exceeded during initialization.
The call of \*{eval_field_selection\*} would never fail
in those circumstances.
We have opted here for a more general formulation anticipating
additions to the language that allow initializations for other
classes than \*{array\*} and \*{table\*}.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
array(5, 0)
.}}
.E}
.sp 0.5
{Creates an instance of the class \*{array\*}, with size 5 and all elements
initialized to 0.}
.IP 2)
.E{
.{{
n := 5;
.br
i := 30;
.br
yellow := 'YELLOW ';
.br
array(3*n, 0) init [10, 20, i+5, yellow || 'bird']
.}}
.E}
.sp 0.5
{Creates an instance of class \*{array\*} of size 15.
The elements with indices 0 to 3 are initialized to
10, 20, 35 and \*`\*{YELLOW\*}\ \*{bird\*}\|\*' respectively.
All other elements are initialized to 0.}
.IP 3)
.E{
.{{
[3.5, 'sunshine', array(n, undefined)]
.}}
.E}
.sp 0.5
{Creates an array of size 3, with elements initialized to the
values 3.5, \*{'sunshine'\*} and \*{array(n, undefined)\*}.
In this way arbitrarily shaped multi-dimensional arrays may
be created.}
.XP 2
.SH #{Table expressions=sn<+}. "Table expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <table-expression>
.iy I <size-and-default>
.iy I <table-initialization>
.iy I <table-element>
.<<
.so syn/table-expr
.sp 0.5
.so syn/sizedef
.sp 0.5
.so syn/table-init
.sp 0.5
.so syn/table-elem
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Class $table$
provides an associative memory that maps keys of arbitrary type
onto values.
The definition of this class is given in the next chapter {#{Lib/table}}.
.iy I table
Here, only
\*<table-expression\*>s are defined, which introduce an abbreviated notation
for the creation of tables (that is, instances of class \*{table\*}).
The various forms of
\*<table-expression\*>s can be rewritten as follows.
A \*<table-expression\*> of the (first) form
.sp 0.5
.RS
$table(e sub 1 ,~e sub 2 )~bold init$
.br
$[~k sub 00~:~...~:~k sub {0 m sub 0}~:~i sub 0~,$
.br
$~...$
.br
$~~k sub n0~:~...~:~k sub {n m sub n}~:~i sub n~]$
.RE
.sp 0.5
is equivalent to
.sp 0.5
.RS
$phi~:=~table(e sub 1 ,~e sub 2 );$
.br
$phi~[k sub 00 ]~:=~...~:=~phi~[k sub {0 m sub 0} ]~:=~i sub 0;$
.br
$~...$
.br
$phi~[k sub n0 ]~:=~...~:=~phi~[k sub {n m sub n} ]~:=~i sub n;$
.RE
.sp 0.5
where $phi$ is assumed to be a name not occurring elsewhere
in the program.
A \*<table-expression\*> of the (second) form
.sp 0.5
.RS
$[~k sub 00~:~...~:~k sub {0 m sub 0}~:~i sub 0~,$
.br
$~...$
.br
$~~k sub n0~:~...~:~k sub {n m sub n}~:~i sub n~]$
.RE
.sp 0.5
is equivalent to
.sp 0.5
.RS
$phi~:=~table(s,~undefined);$
.br
$phi~[k sub 00 ]~:=~...~:=~phi~[k sub {0 m sub 0} ]~:=~i sub 0;$
.br
$~...$
.br
$phi~[k sub n0 ]~:=~...~:=~phi~[k sub {n m sub n} ]~:=~i sub n$
.RE
where $s$ is equal to $sum from {i=0} to m {m sub i}$.
.PP
The first \*<expression\*> in the \*<size-and-default\*> defines the estimated size of the table;
the total number of entries in the table may become larger than this estimate.
The second \*<expression\*> defines the default value to be returned when a value
is looked up which has not been previously entered in the table.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.LP
The semantics of a \*<table-expression\*> of the first form is:
.D{
.so sem/table1
.D}
.LP
.ne 5
The semantics of a \*<table-expression\*> of the second form is:
.D{
.so sem/table2
.D}
.LP
.ne 6
The actual creation and initialization of tables
is performed by \*{eval_table_init\*}:
.D{
.so sem/eval_table_init
.D}
.NO
.IP 1)
Table-elements are initialized by means of \*{update\*} operations
.iy I update
{#{Field selection}, #{Dyadic expressions} and #{Lib/table}}.
.IP 2)
The formal definition relies on the existence of a
\*<class-declaration\*>
.iy I <class-declaration>
for \*{table\*} outside the kernel {#{Lib/table}}.
See Section #{Unspecified} for a more extensive explanation of this topic.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
table(300, undefined)
.}}
.E}
.sp 0.5
{Creates a new instance of class \*{table\*}, with estimated size 300
and default value \*{undefined\*}.}
.IP 2)
.E{
.{{
table(i+50, 'symbol-not-in-table')
.}}
.E}
.sp 0.5
{Creates a new instance of class \*{table\*}, with as estimated size the
value of the expression $i~+~50$ and as default
value the string \*{'symbol-not-in-table'\*}.}
.IP 3)
.E{
.{{
t := table(100, 0) init [ 'a':'b': 3, 'p':5 ]
.}}
.E}
.sp 0.5
{Assigns to \*{t\*} a new instance of class \*{table\*} with
estimated size 100 and default value 0.
It performs the initializations
.sp 0.5
.{{
	t['a'] := t['b'] := 3;
.br
	t['p'] := 5.
.}}
.sp 0.5
The values of \*{t['a']\*}, \*{t['p']\*} and \*{t['z']\*} are now
3, 5, and 0 respectively.}
.SH #{Field selection=sn<+}. "Field selection"
.iy I <select>
.iy I "field selection"
.iy I <field-identifier>
.SH #{sn>a}. "Syntax" -
.LP
.<<
.so syn/primary
.sp 0.5
.so syn/select
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Accessing a field of a class instance is referred to as \fBfield selection\fP
{#{Class declarations}}.
We will only describe the basic mechanism of field selection here.
A complete description is postponed until {#{Dyadic expressions}}.
.PP
The following items are required for a field  selection:
.IP 1.
The \*{accesstype\*} to distinguish an assignment (`store') to the field
from any other operation (`fetch').
.IP 2.
The \*{instance\*} on which the field selection is to be performed.
.IP 3.
The \*{field\*} to be selected.
.IP 4.
Optional actual parameters.
.LP
To carry out a field selection, the environment is switched to
the environment contained in the left operand of the selection
(i.e. the instance obtained by evaluating the \*<unit\*>).
Depending on the access type, either the
\*<fetch-associations\*>
.iy I <fetch-associations>
or the
\*<store-associations\*>
.iy I <store-associations>
of the corresponding
\*<class-declaration\*>
.iy I <class-declaration>
are searched for a
\*<field-identifier\*>
.iy I <field-identifier>
equal to \*{field\*}.
Depending on the form of the association in which \*{field\*} occurs,
the value of the field is either simply modified and returned as value, or
the procedure associated with the field is called.
In the latter case
the value returned by the procedure call is the result of the field selection.
Finally, the original environment is restored.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.LP
The semantics of a \*<unit\*> followed by a \*<select\*> is:
.D{
.so sem/select
.D}
.LP
.ne 6
The actual field selection is performed by \*{eval_field_selection\*}
described below.
.D{
.so sem/eval_field_selection
.D}
.LP
The utility procedure \*{has_field\*} succeeds or fails
depending on whether a given
field selection can or cannot be performed.
It is used for operator identification {#{Monadic expressions} and #{Dyadic expressions}}.
.D{
.so sem/has_field
.D}
.NO
.IP 1)
In the formal definition
it is assumed that all \*<expression\*>s are fully parenthesized.
This implies that repeated field selections of the form
.DS
$e ~.~ f sub 1 ~.~ f sub 2 ~.~ f sub 3 ~.~.~.$
.DE
have been replaced by
.DS
$(~.~.~.~((e~.~f sub 1 )~.~f sub 2 ) ~.~ f sub 3 ~.~.~.~)$
.DE
Hence, the formal definition only has to cover the case of a single
field selection.
.IP 2)
The \*{class_decl.text\*} part of each instance
under consideration is required to have an empty \*<subclass-declaration\*>,
since this has been removed by \*{expand_super_class\*}
{#{Class declarations}}.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
n := 5;
.br
s := stack(7 * n)
.}}
.E}
.sp 0.5
{Assigns a new instance of class \*{stack\*} with actual parameter 35 to
variable \*{s\*}.
A declaration for class \*{stack\*} is given as an example
in {#{Class declarations}}.}
.sp 0.5
.{{
s.push(4)
.}}
.sp 0.5
{Next, the integer 4 is pushed onto that stack by
performing the field selection \*{push\*} with actual parameter 4.}
.IP 2)
.E{
.{{
x := s.pop
.}}
.E}
.sp 0.5
{Similar to the above, but now an element is popped from the stack by
performing the field selection \*{pop\*}.}
.SH #{Subscription=sn<+}. "Subscription"
.iy I <subscript>
.iy I subscription
.SH #{sn>a}. "Syntax" -
.LP
.<<
.so syn/primary
.sp 0.5
.so syn/subscript
.>>
.SH #{sn+}. "Pragmatics" -
.PP
Subscription is an
abbreviated notation for selection of the
.iy I retrieve
.iy I update
fields \*{retrieve\*} and \*{update\*} respectively.
These fields are, amongst others, defined for the
classes \*{array\*} {#{Lib/array}},
\*{bits\*} {#{Lib/bits}},
\*{string\*} (\*{retrieve\*} only) {#{Lib/string}}
and
\*{table\*} {#{Lib/table}},
but each class which defines these operations can use the subscript
notation.
The operation \*{update\*} is used when
subscription occurs on the left hand side of an assignment operator and
is described in {#{Dyadic expressions}};
The operation \*{retrieve\*} is used in all other cases and is described here.
.PP
Since subscription is reduced to field selection, its semantics
is defined by defining the reduction from
.DS L
	\*{e1[e2]\*}
to
	\*{e1.retrieve(e2)\*} .
.DE
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/subscript
.D}
.NO
.IP 1)
In the formal  definition it is assumed that all \*<expression\*>s
are fully parenthesized.
This implies that repeated subscriptions of the form
.DS
$e [ e sub 1 ]~[ e sub 2 ]~[ e sub 3 ] ~ ...$
.DE
have been replaced by
.DS
$(~...~((e [ e sub 1 ] ) [ e sub 2 ] ) [ e sub 3 ]~ ...~)$
.DE
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
a := array(10, 7);
.}}
.E}
.sp 0.5
{Assigns to \*{a\*} an instance of class \*{array\*},
containing 10 elements which are all initialized to 7.}
.sp 0.5
.{{
x := a[5]
.}}
.sp 0.5
{Evaluates, in the above context, the expression \*{x := a.retrieve(5)\*},
which assigns the integer 7 to variable \*{x\*}.}
.SH #{Monadic expressions=sn<+}. "Monadic expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <monadic-expression>
.iy I <monadic-operator>
.iy I <operator-symbol>
.<<
.so syn/monadic-expr
.sp 0.5
.so syn/monadic-op
.>>
.SH #{sn+}. "Pragmatics" -
.PP
All monadic operators have the same priority, which is higher than the
priority of dyadic operators.
In the formal definition it is assumed that
all \*<monadic-expression\*>s are fully parenthesized
hence only \*<monadic-expression\*>s
containing just one \*<monadic-operator\*> will be described.
.PP
The evaluation of a
\*<monadic-expression\*>
.iy I <monadic-expression>
proceeds in the following steps:
.IP 1.
Evaluate the primary.
Unless the
\*<monadic-operator\*>
.iy I <monadic-operator>
.iy I ~
is `\*{~\*}', the evaluation of the
\*<monadic-expression\*>
.iy I <monadic-expression>
fails if the evaluation of the primary fails.
.IP 2.
If the
\*<monadic-operator\*>
.iy I <monadic-operator>
is \fBnot\fP (`\*{~\*}'), turn success into failure and vice versa.
.IP 3.
Otherwise, if a field with the name of the
\*<monadic-operator\*>
.iy I <monadic-operator>
is defined
on the value obtained in step 1, then perform a field selection of that field.
.IP 4.
Otherwise, there must be a global
\*<operator-declaration\*>
.iy I <operator-declaration>
for \*<monadic-operator\*>,
i.e. an \*<operator-declaration\*> immediately contained in the \*<summer-program\*>.
In this case perform a call to the procedure declared by that
\*<operator-declaration\*>.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/monadic-expr
.D}
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
-x
.}}
.E}
.IP 2)
.E{
.{{
~ positive(x)
.}}
.E}
.IP 3)
.E{
.{{
- if a > b then x + 1 else x - 1 fi
.}}
.E}
.SH #{Dyadic expressions=sn<+}. "Dyadic expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <dyadic-expression>
.iy I <dyadic-operator>
.iy I <operator-symbol>
.<<
.so syn/dyadic-expr
.sp 0.5
.so syn/dyadic-op
.>>
.SH #{sn+}. "Pragmatics" -
.PP
The priorities of \*<monadic-operator\*>s and
\*<dyadic-operator\*>s, are in decreasing order:
.iy I "priority (of operators)"
.DS I
.ta 5cm 5cm 5cm
All monadic operators	1
\*{||\*}	2
\*{* / %\*}	3
\*{+ -\*}	4
\*{< <= > >= = ~=\*}	5
User defined operators	6
\*{:=\*}	7
\*{&\*}	8
\*{|\*}	9
.DE
In the formal definition it is assumed that all \*<dyadic-expression\*>s
are fully parenthesized in order
to establish the relative priorities of the \*<dyadic-operator\*>s.
In the sequel, only \*<dyadic-expression\*>s containing just one \*<dyadic-operator\*>
will be described.
.PP
The evaluation of a
\*<dyadic-expression\*>
.iy I <dyadic-expression>
proceeds in the following steps:
.IP 1.
If the
\*<dyadic-operator\*>
.iy I <dyadic-operator>
is not equal to `\*{:=\*}' (assignment),
.iy I :=
goto step 3, otherwise evaluate
the right-hand operand.
If it evaluates to a location, use the contents of that location as value.
.IP 2.
The \*<dyadic-operator\*> is `\*{:=\*}'.
We distinguish four cases depending on the form of the left-hand operand:
.RS
.IP 2a.
\fBField selection\fP.
.iy I "field selection"
The left operand consists of a
\*<unit\*>
.iy I <unit>
followed by a
\*<select\*>.
.iy I <select> .
Evaluate the \*<unit\*>
and perform a `storing' field selection {#{Field selection}} on the
value obtained in this way, using the given field name and with
the value obtained in step 1 as actual parameter.
The value of this field selection is the result of the evaluation
of the \*<dyadic-expression\*>.
.IP 2b.
\fBSubscription\fP.
.iy I subscription
The left operand consists of a
\*<unit\*>
.iy I <unit>
followed by a
\*<subscript\*>.
.iy I <subscript> .
Evaluate the \*<unit\*> and \*<subscript\*>.
Perform a field selection {#{Field selection}} on the value of the \*<unit\*>,
using the field name \*{update\*}, the value of the
.iy I update
\*<subscript\*>,
.iy I <subscript> ,
and the value obtained in step 1 as actual parameters.
The value of this field selection is the result of the evaluation of
the \*<dyadic-expression\*>.
.IP 2c.
\fBMultiple assignment\fP.
.iy I "multiple assignment"
The left operand consists of an
\*<array-initialization\*>.
.iy I <array-initialization> .
The expressions $e sub i$ in the
\*<array-initialization\*>
.iy I <array-initialization>
are evaluated from left to right.
The value of each $e sub i$ should be a location.
For each $e sub i$ the result of evaluating the expression
$V[i]$ is placed in the cell corresponding to location $e sub i$,
where $V$ is the value obtained in step 1.
The value of the last expression in the \*<array-initialization\*>
is the  result of the evaluation of the \*<dyadic-expression\*>.
.IP 2d.
\fBSimple assignment\fP.
.iy I assignment
Neither of the above cases applies.
The left operand of the assignment is evaluated.
The resulting value should be a location.
The value obtained in step 1 is placed in the cell associated
with that location and that value is also the result of the evaluation of
the \*<dyadic-expression\*>.
.RE
.IP 3.
The
\*<dyadic-operator\*>
.iy I <dyadic-operator>
is not `\*{:=\*}' .
Evaluate the left operand.
If it fails and the
\*<dyadic-operator\*>
.iy I <dyadic-operator>
.iy I "| (or operator)"
is not `\*{|\*}' (Boolean \fIor\fP), the evaluation of the
\*<dyadic-expression\*>
.iy I <dyadic-expression>
as a whole fails.
Evaluate the right operand: If it fails, the evaluation of the
\*<dyadic-expression\*>
.iy I <dyadic-expression>
fails.
If the
\*<dyadic-operator\*>
.iy I <dyadic-operator>
is `\*{|\*}' (Boolean \fIor\fP) or `\*{&\*}' (Boolean \fIand\fP\|),
.iy I "| (or operator)"
.iy I &
the value of the right operand becomes the value of the whole
\*<dyadic-expression\*>
.iy I <dyadic-expression>
whose evaluation is then complete.
Otherwise, the following cases exist:
.RS
.IP 3a.
The value of the left operand is an instance of some class, say $C$,
and a field with the same name as the
\*<dyadic-operator\*>
.iy I <dyadic-operator>
is defined in the
\*<class-declaration\*>
.iy I <class-declaration>
for $C$.
Perform a selection of that field;
the result of this field selection then becomes the result
of the evaluation of the \*<dyadic-expression\*>.
.IP 3b.
There exists an
\*<operator-declaration\*>
.iy I <operator-declaration>
for the \*<dyadic-operator\*>.
Perform a procedure call to the procedure declared in that \*<operator-declaration\*>;
the result of this procedure call then becomes the result
of the evaluation of the \*<dyadic-expression\*>.
.IP 3c.
The
\*<dyadic-operator\*>
.iy I <dyadic-operator>
is `\*{=\*}' or `\*{~=\*}'.
.iy I "="
.iy I "~="
Perform an (in)equality test on the values of the left and right operands.
Depending on the outcome of this test, evaluation of the \*<dyadic-expression\*>
either fails or delivers the value of the right operand.
.RE
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/dyadic-expr
.D}
.NO
.IP 1)
It is not possible to redefine the operators `\*{|\*}', `\*{&\*}', and `\*{:=\*}'.
.IP 2)
It is not even possible to define operators with a similar effect
to `\*{|\*}' and `\*{&\*}',
since these operators do not evaluate their arguments before they are applied.
This form of parameter transmission is not available in \s-2SUMMER\s0.
For similar reasons, it is not possible to define `assignment-like' operators.
.IP 3)
The operators `\*{=\*}' and `\*{~=\*}' can be redefined.
The order of steps 3b and 3c above ensures this.
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
x := 10;
.br
y := x + 1;
.}}
.E}
.sp 0.5
{Assigns 11 to y.}
.IP 2)
.E{
.{{
p := 3; q := 23; r := 29;
.br
s1 := ' A Space Odyssey';
.br
s2 := string(p * q * r) || s1;
.}}
.E}
.sp 0.5
{Assigns the value \*{'2001 A Space Odyssey'\*} to \*{s2\*}.}
.IP 3)
.E{
.{{
[x, y, z] := [1, 2, 3]
.}}
.E}
.sp 0.5
{Is equivalent to: \*{x := 1; y := 2; z := 3\*}}
.IP 4)
.E{
.{{
[x, y] := [y, x]
.}}
.E}
.sp 0.5
{Is equivalent to: \*{tmp := x; x := y; y := tmp\*}}
.IP 5)
.E{
.{{
p & q
.}}
.E}
.sp 0.5
{Succeeds if both $p$ and $q$ succeed, and fails otherwise.}
.IP 6)
.E{
.{{
p & if a > b then x > a else x > b fi
.}}
.E}
.SH #{Constant expressions=sn<+}. "Constant expressions"
.SH #{sn>a}. "Syntax" -
.LP
.iy I <constant-expression>
.iy I <simple-constant-expression>
.iy I <constant>
.iy I <constant-operator>
.iy I <constant-declaration>
.<<
.so syn/const-expr
.sp 0.5
.so syn/simple-const-expr
.sp 0.5
.so syn/const-op
.>>
.SH #{sn+}. "Pragmatics" -
.PP
\*<constant-expression\*>s occur in
\*<case-entry\*>s
.iy I <case-entry> s
{#{Case expressions}} and
\*<constant-initialization\*>s
.iy I <constant-initialization> s
{#{Constant declarations}}
and consist solely of \*<constant\*>s, \*<identifier\*>s which have been declared in a
\*<constant-declaration\*>, and a limited set of operators.
\*<constant-expression\*>s are evaluated by \*{eval\*}.
The following procedure \*{require_constant_expression\*}
ensures that all \*<identifier\*>s occurring in a
\*<constant-expression\*>
.iy I <constant-expression>
have indeed been declared in a \*<constant-declaration\*>.
.br
.ne 10
.SH #{sn+}. "Semantics" -
.D{
.so sem/req_constant_expression
.D}
.SH #{sn+}. "Examples" -
.IP 1)
.E{
.{{
pi
.}}
.E}
.sp 0.5
{Assume that the \*<constant-declaration\*>
.sp 0.5
.{{
	const pi := 3.14;
.}}
.sp 0.5
has occurred previously.}
.IP 2)
.E{
.{{
2 * pi
.}}
.E}
.IP 3)
.E{
.{{
7 + (2 * pi)
.}}
.E}
.SH #{Miscellaneous functions=sn<<+}. "Miscellaneous functions used in the formal definition"
.PP
This section is devoted to some functions which are used in the formal definition,
but have not been described in preceding sections.
.SH #{Dereference=sn>1}. "The function \*{dereference\*}"
.PP
.iy I "dereference"
S\s-2UMMER\s0 allows very complex left hand sides of assignments.
For example,
.DS
.{{
if a > b then
   if c > d then x else y fi
else
   z
fi := 3
.}}
.DE
assigns the value 3 to either \*{x\*}, \*{y\*} or \*{z\*}.
To handle such general cases, evaluation always delivers values
which are not dereferenced (see below).
If a variable is evaluated, the result is the location bound to that
variable and not the contents of that location.
Locations are not $STORABLE$-$VALUE$s however, and as a consequence
it is necessary to dereference
the result of an evaluation before certain operations
(use as actual parameter, right hand side of assignment,
or operand in expression)
can be performed.
Dereferencing converts a location to the value it contains.
This is precisely what is done by the procedure defined below.
.D{
.so sem/dereference
.D}
.SH #{Equal=sn+}. "The function \*{equal\*}"
.PP
.iy I "equal"
The procedure \*{equal\*} performs the basic equality operation between
values and is described below:
.D{
.so sem/equal
.D}
.SH #{Substring and string_equal=sn+}. "The functions \*{substring\*} \fBand\fP \*{string\*}\h'-0.2m'\v'0.4m'\(mi\v'-0.4m'\h'-0.2m'\*{equal\*}
.PP
.iy I "substring"
.iy I "string_equal"
Two auxiliary operations on strings are used in the definition.
The procedure \*{substring\*} extracts a substring of given length
which begins at a given position from a given string.
The procedure \*{string_equal\*} succeeds if two strings have the same
size and contain the same characters.
The definition of these procedures is omitted.
#{sn<<;}#{figs<;}
.EC
