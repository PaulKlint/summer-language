.SH #{Flexible arrays=sn<+}. "Flexible arrays"
.SH #{sn>a}. "Overall description" -
.PP
This program shows the declaration of class \*{flexible_array\*},
a rather flexible kind of array on which the following operations are defined:
.IP a)
\*{update\*} and \*{retrieve\*} operations similar to the corresponding operations
defined on arrays.
.IP b)
\*{append\*} and \*{delete\*} operations to add an element at the end of the flexible
array or to delete a number of elements from the end.
.IP c)
A \*{size\*} operation, which can both be used to inspect the current size and
to reset the size.
.IP d)
Operations \*{next\*} and \*{index\*} similar to those for normal arrays.
.PP
This program illustrates \*<class-declaration\*>s {#{Class declarations}},
\*<for-expression\*>s {#{For expressions}} (cooperating with user-defined
fields \*{next\*} and \*{index\*}) and \*<assert-expression\*>s {#{Assert expressions}}.
.PP
Note that the built-in arrays in \s-2SUMMER\s0 are already quite `flexible':
operations similar to \*{append\*}, \*{delete\*} and \*{top\*}
are defined on them.
The purpose of the following example is to show how such a data type
could be defined in a user program.
.br
.ne 10
.SH #{sn+}. "Source text" -
.LP
.nf
.nm 1
.so ../demo/flex.so
.fi
.nm
.SH #{sn+}. Input -
.PP
None
.SH #{sn+}. Output -
.LP
.nf
.ta 2c
.so ../demo/flex.out.so
.fi
.SH #{sn+}. "Detailed description" -
.IP "2-54, 55, 56-85 " 6
Declarations of class \*{flexible_array\*}, procedure \*{p4\*} and program \*{demo_flex\*}.
.IP 3-5 6
Declarations of fields that may be accessed from outside the class.
The fields listed in lines 3-4 may be fetched.
Assignments to the field \*{size\*} are allowed and are carried
out by the procedure \*{change_size\*}.
.IP 7-11 6
Procedure \*{extend\*} is used only inside the class declaration
and extends array \*{mem\*}: a new array \*{m1\*} is created,
all values in \*{mem\*} are copied to it,
and, finally, the new array is assigned to \*{mem\*}.
.IP 12-13 6
Procedure \*{retrieve\*} ensures that \*{i\*} lies in the interval $0~<=~i~<~"size"$
and then returns the $i$-th element of \*{mem\*}.
If, for example, \*{f\*} is an instance of class \*{flexible_array\*}, then
.sp 0.5
.{{
	x := f[5];
.}}
.sp 0.5
is equivalent to
.sp 0.5
.{{
	x := f.retrieve(5)
.}}
.IP 14-15 6
Procedure \*{update\*} changes the value of the $i$-th element into \*{v\*}
provided that $0~<=~i~<~"size"$.
If, again, \*{f\*} is a \*{flexible_array\*},
.sp 0.5
.{{
	f[5] := 7
.}}
.sp 0.5
is equivalent to
.sp 0.5
.{{
	f.update(5, 7)
.}}
.IP 16-21 6
Procedure \*{append\*} adds the value \*{v\*} at the end of the \*{flexible_array\*}.
If necessary, \*{mem\*} is extended first.
.IP 22-23 6
Procedure \*{delete\*} deletes the rightmost \*{n\*} elements by
calling \*{change_size\*} (see below).
.IP 24-38 6
Procedure \*{change_size\*} implements assignments to the field \*{size\*} and is
called to evaluate expressions like
.sp 0.5
.{{
	f.size := 3 .
.}}
.sp 0.5
The seeming complexity of \*{change_size\*} is due to the fact that
the invariant
.sp 0.5
	$"size"~<=~i~<~mem."size"~->~mem[i]~=~undefined$
.sp 0.5
is maintained to ensure that elements `added' to the array
are properly set to \*{undefined\*}.
.IP 39-47 6
A user-defined \*{next\*} procedure. Its operation is explained in conjunction with
the \*<for-expression\*> in lines 75-79.
.IP 48-49 6
A user-defined \*{index\*} procedure, which delivers an \*{interval\*} of the
legal indices in this \*{flexible_array\*}.
.IP 50-51 6
Procedure \*{top\*} delivers the rightmost element of the \*{flexible_array\*}.
.IP 52-53 6
Initialization code.
Assigns an array value to \*{mem\*} and sets \*{size\*} to zero.
.IP 55 6
Procedure \*{p4\*} prints its argument \*{v\*} right aligned in a field of width 4.
.IP 59 6
An instance of \*{flexible_array\*} is assigned to \*{f\*}.
.IP 61-64 6
Fill the \*{flexible_array\*} with squares.
Note how the \*<assert-expression\*> checks that the operations have been
performed properly.
If the \*<assert-expression\*> fails, execution of the whole program
is aborted.
.IP 67-71 6
Loop using the \*{index\*} operation.
The variable \*{i\*} is used to maintain a `shadow' administration
of the index values; this is used by the <assert-expression in line 72.
.IP 75-79 6
Loop using the \*{next\*} operation.
The expression
.sp 0.5
.{{
	for k in f do ... od
.}}
.sp 0.5
is equivalent to
.sp 0.5
.{{
	phi := f;
.br
	sigma := undefined;
.br
	while [k, sigma] := phi.next(sigma) do ... od
.}}
.sp 0.5
As we see in line 40, \*{next\*} sets its argument \*{state\*}
to 0 when its value is \*{undefined\*}.
On subsequent calls, the value of \*{state\*} is compared with the value of \*{size\*}
(line 41).
If the former is less than the latter, an array
with value-for-this-iteration and new-state is returned.
Note how the multiple assignment
.sp 0.5
.{{
	[k, sigma] := phi.next(sigma)
.}}
.sp 0.5
assigns the value-for-this-iteration to \*{k\*} and the new-state to \*{sigma\*}.
The next operation fails if there are no more elements in the \*{flexible_array\*}.
.IP 81-82 6
Delete the last two elements and make sure that the size of \*{f\*} has
been reduced accordingly.
.IP 83-84 6
Assign to the \*{size\*} field and check resulting size.
#{sn<<<;}#{figs<;}
.EC
