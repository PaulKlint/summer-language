.SH
Critical remarks
.IP -
try does not restore local variables
.IP -
The fetch/store notation is not ideal;
assignment to procedure fields is not possible.
.IP -
It is not garantueed that a store association has the same
semantics as a regular assignment, i.e.
.DS
x.a := b;
.DE
needs not deliver the value of b.
(Possible solution: make the above expression equivalent with
.DS
x.a := b; x.a
.DE
.IP -
The automatic conversion of strings to scan_string is convenient
but ugly.
.IP -
The array datatype is to restictive; should be replaced by
a "flex" like datatype.
.IP -
There are no procedure variables.
Problems are 1) notation e.g. "()" in field-selection.
2) export of field procedures.
.IP -
The type system is adequate. However using a "consistent" typing scheme
a la B, allows many (easy) optimizations in the implementation without
loosing essential expressive power.
.IP -
The next mechanism in for-loops is simple, but requires the
programmer to remember "how states of for-loops" look like.
.IP -
For loops should be generalized to allow more than one input and an
output object.
.IP -
Access rights to class instances are to restricted.
In many situations a brother instance of the same class should have
unrestricted access to the fields of another instance of that class;
In the current situation, such fields have to be made public by means
of fetch associations.
.IP -
This could even be generalized to nieces and nephews, e.g.
instances of classes which have a common ancestor via subclassing.
.IP -
A class should be allowed to be a subclass of more than one class.
.IP -
There is a problem with field procedures which have a global alias.
Inside the class definition, the global procedure is not available.
.IP -
The scan statement can be generalized to allow more than one subject
(which must have mutually exclusive fields OR some search order must
be defined)
.IP -

.IP -
Cosmetic errors in the syntax:
.br
1) "()" always required in proc decl.
.br
2) operator names of the form "_" <id> "_" are annoying.
.br
3) entries in case statements are separated by comma's.
It is a common mistake to place a comma after the last entry
(i.e. before default or esac).
.br
4) The mirrored keyword system has produces some bizar keywords
(yrt, rof, esac).
.br
5) The semicolon is treated very conservatively as statement
separator. End-of-line and semicolon could be allowed.
.IP -
Sort criterium:
rather arb choices here; better solution: apply the < operator if its
exists for the values in the array
