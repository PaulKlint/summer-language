# push simple values on the stack #

INT	n	# push integer constant n #
REAL	r	# push real constant r #
GLOB	n	# push value of n-th global variable #
ASGLOB	n	# assign SP[0] to n-th global variable #
LOC	n	# push value of n-th local variable #
ASLOC	n	# assign SP[0] to n-th local #
LOAD	l	# push address of arbitrary constant at location l #
NULLSTR		# push the empty string constant on the stack #
UNDEF		# push the undefined value #
VOID		# decrement SP #

# relational and arithmetical instructions #

EQ		# Perform SP[1] = SP[0] #
		# On failure: jump to current fail label #
		# On success: replace SP[0] and SP[1] by the value of SP[0] #
		# The following relational operators behave similarly #
NE		# Perform SP[1] ~= SP[0] #
LT		# Perform SP[1] < SP[0] #
GT		# Perform SP[1] > SP[0] #
LE		# Perform SP[1] <= SP[0] #
GE		# Perform SP[1] >= SP[0] #
ADD		# Perform SP[1] + SP[0] #
		# SP[0] and SP[1] are replaced by the result of the addition #
SUB		# Perform SP[1] - SP[0] #
MUL		# Perform SP[1] * SP[0] #
DIV		# Perform SP[1] / SP[0] #
IDIV		# Perform SP[1] % SP[0] (integer division) #
NEG		# Perform - SP[0] (unary minus) #
CONC		# Perform SP[1] || SP[0] #

# instructions related to arrays and tables #

ARINIT	n	# array initialization #
		# Create an array of length m with n initialized #
                # values and push the result on the stack #
TABINIT n	# table initialization #
		# Create a table of length n and push the result on the stack #
		# Initialization of table entries is done by the #
		# instruction "tabelem" below #
TABELEM	n	# table element assignment #
IND		# index operation in array or table #
		# SP[0] is the array or table instance #
		# SP[1] is the value of the index #
		# both entries are replaced by the value of indexed element #
ASIND		# assign to array or table element #
		# SP[0] is the array or table element #
		# SP[1] is the value of the index #
		# SP[2] is the value to be assigned to the indexed element #
		# Only the latter remains on the stack #
XAR	n	# replace the array value in SP[0] by its first n elements #

# procedures calls, flow of control and failure handling #

CALL	n1,n2	# call the n2-th procedure with n1 actual parameters #
		# the actual parameters are on top of the stack #
RETURN		# return a value from a procedure call #
		# and remove stack space for actuals and locals #
FRETURN		# failure return from procedure call #
		# remove stack space for actuals and locals and #
		# simulate a "gofl" instruction in caller #

NEWFL	l	# define new fail label l #
OLDFL		# restore previous fail label #
GOFL		# jump to current fail label #

GO	l	# jump to label l #
GOCASE		# case table jump #
		# SP[1] is the case table to be used #
		# It contains (index-value, program-label) pairs. #
		# SP[0] is the index value for the table selection #

# recovery caches #

NEWRC		# enter new recovery cache #
OLDRC		# leave current cache #
RESRC		# restore from current cache #

# instructions for manipulating the current subject string #

NEWSUBJ		# install SP[0] as new current subject #
OLDSUBJ		# restore previous subject #
SUBJECT		# push value of current subject #


# instructions for creation of and access to class instances #

NEWCLASS name	# create new class instance of class "name" #
CLOC	n	# push n-th local of class instance #
ASCLOC	n	# assign to n-th local of class instance #
FLD	n,name	# fetch field "name" from class instance SP[0] #
ASFLD	n,name	# assign to field "name" from class instance SP[0] #
IFLD	n,name	# fetch field ignoring associations #
IASFLD	n,name	# store in field ignoring associations #
SELF		# push current class instance #

# declarative instructions #

LAB	l	# declare label "l" #
DCLGLOB	name	# declare global variable "name" #
DCLSTR	name,n,b1,...,bn
		# declare string constant "name" consisting of "n" #
		# characters b1, ..., bn #
PROC	pname,lname,nf,nl,bline,eline
		# start declaration of procedure "pname". #
		# "lname" is a string constant which contains the names #
		# of the variables in p. #
		# "nf"		number of formal parameters of p. #
		# "nl"		number of local variables of p. #
		# "bline"	start line of declaration in source text. #
		# "eline"	end line of declaration in source text. #
PROGRAM	pname,lname,nf,nl,bline,eline
		# start the declaration of the main program #
PROCEND		# end of procedure declaration #
SUBR	pname	# SUMMER program uses library routine "pname" #
CLASSES		# start the class description tables #
ENDCLASSES	# end the class description tables #
FIELDS		# start the field description tables #
ENDFIELDS	# end the field description tables #

# miscellaneous instructions #

HALT		# halt instruction #
NOOP		# no operation #
LINE	n	# static line increment for LMC algorithm #
ALINE	n	# absolute line number #
ERROR	name	# generate error message with fixed name #
		# allowed names are: #
		# ER_case:	index does not occur in case table #
		# ER_assert:	assertion failed #
		# ER_ret:	procedure does not return a value #
