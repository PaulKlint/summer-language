.hy
.bp 3
#{figs+>;}
.NC #{INTRODUCTION=sn+} "INTRODUCTION" " "
.ds LH INTRODUCTION
.SH #{subject monograph=sn>1}. "Subject of this monograph"
.PP
Written text is an essential element in our culture and
various technical means have been invented to aid in its production.
Paper and pencil, the typewriter and the typesetter are examples
of such inventions.
.PP
Continuing this same line of development, computers are nowadays
being used to alleviate the writing task.
Computerized text processing systems
(ranging from word processors for writing and editing simple texts to
fully automated newspaper and book printing systems)
are rapidly penetrating
into all areas of human activity where written text is the primary
means of communication.
.PP
Historically, the impetus behind the development of computers
has always been primarily numerical in nature.
This is reflected in the design of most computers and programming languages.
However, the increasing use of computers for text processing and for
other non-numeric tasks makes the purely arithmetic design obsolete.
.PP
This monograph concentrates on the programming language aspects of
computerized text handling
and, to be more precise, on the design and implementation of
\fBstring processing languages\fP.
The term `string processing' refers to the process of inspecting, modifying
and transforming texts, i.e. sequences of symbols.
It comprises such seemingly disparate activities as text editing,
transforming a text with embedded formatting directives into
a final layout, and compiling a source program into a string
of machine instructions.
.PP
In motivating the study of string processing languages
we shall first consider three typical applications
for which a string processing language would be a prime choice
as implementation language.
At the same time, we shall try to fit the problems and language requirements
that are typical for string processing applications into a general scheme.
It is not our intention to contend that the solutions proposed and
the techniques used are the only ways to solve these problems.
There are indeed many programs that solve them without relying
on higher level concepts in their implementation language.
In such programs the method of procedural extension is used to realize
higher level concepts.
What we do contend, however, is that the concepts proposed here follow
in a natural way from the various applications.
.PP
\fBTypical application 1\fP:
count the frequency of occurrence of all
words in a text and print an alphabetically sorted list of the results.
This is a prototype of many simple editing
and text processing problems.
A program to perform this task will presumably consist of the modules:
\fBRead word\fP, \fBTally\fP and \fBSort and Print\fP.
.PP
\fBRead word\fP
isolates the next `word' from the input and fails if no more words are available.
This requires a simple lexical recognition capability to distinguish
letters, digits and punctuation marks.
\fBTally\fP compares the word just read with the words in a table
containing all previously read words.
If the word occurred before, its frequency is incremented in the table,
otherwise a new table entry is created with frequency set to one.
This requires table lookup and automatic storage allocation.
Note that neither the maximum length of a word nor the maximum number
of different words is known in advance.
\fBSort and Print\fP
sorts the table and prints it.
This requires a sorting facility and simple string synmonograph functions
to produce output in tabular form.
.PP
\fBTypical application 2\fP:
format a text containing embedded formatting directives.
A text formatting program might contain the modules:
\fBRead input\fP, \fBManage text streams\fP, \fBAdjust\fP an \fBHyphenate\fP.
.PP
\fBRead input\fP reads input text and
recognizes embedded formatting directives.
In a simple system, this requires recognition power at the lexical level.
More sophisticated systems might support input specifications for the
formatting of mathematical formulas, tables, block diagrams, etc.
In that case more complex patterns must be recognized in the input text.
\fBManage text streams\fP supervises the output stream.
Various areas in the `current' output page
(like headers, text columns and footnotes) are usually filled independently.
This is implemented most naturally by storing the information related to them
in separate data structures.
This requires data structures allowing their components to grow dynamically.
\fBAdjust\fP distributes the spaces embedded in a text line
so as to obtain right adjusted margins.
This can be done in several ways and it depends on the particular
implementation which language features are needed.
One implementation might, for example, represent a line
as a linked list of words with
each word containing a relative distance to the previous word.
If the amount of blank space in a line becomes too large, Adjust calls
\fBHyphenate\fP.
The latter subdivides words into syllables.
Hyphenation is used when a given word fits the current output line only partially.
This requires table lookup in tables with hyphenation prefixes and suffixes
or in tables containing words with exceptional hyphenation points.
.PP
\fBTypical application 3\fP:
compile a source program in some programming language
into machine code.
The modules
\fBLexical analyzer\fP, \fBSyntax analyzer\fP and \fBCode generator\fP
can be found in most traditional compilers.
.PP
A
\fBLexical analyzer\fP
reads the input stream character by character and constructs from these
characters the basic symbols (such as integers, identifiers and keywords)
of the programming language.
This requires lexical level recognition power.
The \fBSyntax analyzer\fP
performs the syntactic analysis of the stream of symbols
produced by the lexical analyzer.
For each type of context-free grammar there exists an associated recognizer and
the precise form and efficiency of such a recognizer depends on the kind of grammar.
Each recognition function should be able
to handle the case that its input string is \fBnot\fP
recognized, i.e. that the recognition fails.
The output of the syntax analyzer is the
parse tree that corresponds to the source program.
The construction of parse trees requires dynamically allocated data structures.
The \fBCode generator\fP transforms parse trees into executable machine code.
The requirements depend in this case
on the particular implementation method chosen.
.PP
Before embarking on yet another effort to design a programming language
it is worthwhile to answer the question as to how well existing languages satisfy
the typical requirements of string processing or, if they are inadequate in
this respect, in what way they can be extended so as to meet them in a more
satisfactory manner.
This is done in Section #{sp languages special?} below.
As a preparation for this the reader is first,
in Section #{basic operations},
familiarized with some basic notions
that are used frequently in subsequent chapters.
Problems in existing string processing languages
are illustrated in Section #{problems sp languages} by means of some \s-2SNOBOL\s04 programs.
Section #{checklist} contains a list of questions that can serve as a basis
for the evaluation of string processing languages,
while at the same time suggesting the direction of future developments.
.PP
This monograph gives an
account of attempts to solve some of the problems in string processing languages.
It consists of two parts.
.PP
Part I is devoted to string processing languages in general.
Chapter #{INTRODUCTION} is introductory and gives the necessary
motivation and background for the study of string processing languages.
.PP
Chapter #{DESIGN CONSIDERATIONS} is devoted to general design considerations
for string processing languages and compares
the semantics of various pattern matching models.
Attention is paid to different forms of side-effects during a pattern match.
This is done by giving an operational, formal definition of the semantics
of the various models.
As a result of this, a new pattern matching model, based on side-effect recovery,
is developed.
.PP
Chapter #{SUMMER OVERVIEW} gives an overview of the language \s-2SUMMER\s0
an attempt to design a string processing language.
S\s-2UMMER\s0 may be characterized as a \fBsmall\fP
language, i.e. it consists of a relatively small set of primitive operations
together with a modest extension mechanism.
.PP
Chapter #{FORMAL LANGUAGE DEFINITIONS} concentrates on the problem of finding a
method for formal language definition that is suitable for the designer
as well as the implementors and users of a language.
An improved method for the operational definition of programming language
semantics is developed and the result of applying this method to
S\s-2UMMER\s0 is illustrated.
.PP
Chapter #{EPILOGUE} concludes the first part of this monograph
by evaluating the research described in it and by outlining several
areas for further research.
.PP
Part II contains a complete definition of the \s-2SUMMER\s0 programming language.
It consists of a definition of the language
(both formal and informal), gives examples
of the various language constructs and discusses some annotated programs.
.PP
In this monograph we are not concerned with the social implications
of text processing and office automation.
The interested reader is referred to the
literature for a discussion of this issue.
[Mowshowitz81] discusses the different approaches to the study
of social issues in computing.
[Weizenbaum76] analyzes the influence of technology
(and in particular computer science) on our society and
exposes (mis)conceptions among computer scientists regarding the tasks
that can ultimately be delegated to computers.
.SH #{basic operations=sn+}. "Basic operations on strings"
.PP
Agreement is necessary on what we shall mean by \fBstrings\fP and \fBstring processing\fP
before a characterization of string processing languages is possible.
A \fBstring\fP is defined as a sequence of
\fBstring-items\fP (to be defined below), such that:
.IP \*(MK
The sequence is linearly ordered and of arbitrary (finite) size.
.IP \*(MK
Individual string-items in the sequence can be selected by means of indexing.
For a sequence of length $N$, the items in the sequence have
indices $0~ ,..., ~N-1$ respectively.
.IP  \*(MK
An equality relation is defined on the set of string-items.
This relation extends in a natural way to the set of strings.
.LP
This definition is deliberately general and does not use any particular
property of string-items, apart from the assumption that an equality
relation is defined on the set of string-items.
It allows, for instance, strings of integers, strings of reals,
strings of strings of integers, and so on.
Most of the time, however, we shall
be dealing with strings consisting of \fBcharacters\fP,
i.e. entities corresponding to letters, digits and other symbols which can
be displayed on a printing device.
Unless otherwise stated,  all strings are assumed to consist of characters
and in the examples literal character strings will be enclosed in
single quotes (like \*{'metaphysics'\*}).
.PP
\fBString processing\fP will be understood to encompass the totality of 
operations to synthesize and analyze (parse, recognize) strings.
.PP
The most primitive operations on strings are \fBconcatenation\fP and
\fBsubstring selection\fP.
A dyadic operator denoted by `\*{||\*}' will be used for string concatenation;
it `glues' two strings together.
For example,
.DS
\&\*{'meta' || 'physics'\*}
.DE
has the new string \*{'metaphysics'\*} as value.
.PP
Substring selection extracts a substring from a given string.
For example,
.DS
\*{substring('metaphysics', 7, 3)\*}
.DE
produces the new string \*{'sic'\*} by
extracting a substring of size 3 starting at position 7 from \*{'metaphysics'\*}.
Remember that the characters in a string have indices $0~,~1 ~,..., ~N-1$,
where $N$ is the number of characters in the string.
.PP
Less primitive recognition operations,
as can be found in \s-2SNOBOL\s04,
operate on a single common string (`the subject string')
starting at a certain index in that string
(`the cursor position').
These recognition operations appear in two varieties.
The first variety consists of operations and predicates which depend only on the
current value of the cursor.
Typical examples are:
.IP \*(MK
Increment the cursor by 7.
This operation fails if the resulting cursor
is not a legal index in the current subject string.
.IP \*(MK
Is the current value of the cursor equal to 3?
.PP
The second variety consists of operations and predicates which depend both on the
current value of the cursor and on the characters in the subject string.
Examples are:
.IP \*(MK
Does \*{'metaphysics'\*} occur as substring in the subject string, starting at the
current cursor position?
.IP \*(MK
Can the cursor be moved to the right in such a way that it is only moved
past letters?
And if so, which letters?
.LP
These operations can either \fBsucceed\fP if their predicate is true
(and perhaps change the value of the cursor or deliver a value or both)
or \fBfail\fP if the predicate is false.
These examples show the need for failure handling
in string processing languages (see #{failure handling}).
.PP
After these preparations, a list of recognition operations
follows for reference purposes.
These operations are presented in a more or less abstract form, without
commitment to specific syntactic or semantic details.
More detailed descriptions of these operations will appear in subsequent chapters.
.LP
$LEN(n)$
increments the cursor by $n$ (see Figure #{fig len})
and fails if the new cursor falls outside the subject string.
.KS
.sp 1
.na
.nf
.in +8
$LEN(2)$: \(fm\fIr\jaoute 66.\fP\(fm \(-> \(fm\fIrou\jbte 66.\fP\(fm
\h'|\nau'\(ua\h'|\nbu'\(ua
\h'|\nau'1\h'|\nbu'3
.in -8
.sp 1
.ce 1
\s-1\fBFigure #{fig len=figs+}\fP. Example of $LEN$.\s0
.sp 1
.ad
.fi
.KE
.LP
$TAB(n)$
moves the cursor to index $n$
and fails if that new index falls outside the subject string
(see Figure #{fig tab}).
Note, that this operation depends on the specific index convention chosen.
.KS
.sp 1
.na
.nf
.in +8
$TAB(7)$: \(fm\fIr\jaoute 66.\fP\(fm \(-> \(fm\fIroute 6\jb6.\fP\(fm
\h'|\nau'\(ua\h'|\nbu'\(ua
\h'|\nau'1\h'|\nbu'7
.in -8
.sp 1
.ce 1
\s-1\fBFigure #{fig tab=figs+}\fP. Example of $TAB$.\s0
.sp 1
.ad
.fi
.KE
.LP
$RTAB(n)$
moves the cursor to position $length(subject)~-~n~-~1$,
where $length(subject)$ gives the number of characters in the subject string
(see Figure #{fig rtab}).
The operation fails if the desired cursor position falls outside
the subject string.
.KS
.sp 1
.na
.nf
.in +8
$RTAB(5)$: \(fm\fIr\jaoute 66.\fP\(fm \(-> \(fm\fIrou\jbte 66.\fP\(fm
\h'|\nau'\(ua\h'|\nbu'\(ua
\h'|\nau'1\h'|\nbu'3
.in -8
.sp 1
.ce 1
\s-1\fBFigure #{fig rtab=figs+}\fP. Example of $RTAB$.\s0
.sp 1
.ad
.fi
.KE
.LP
$POS(n)$
succeeds if the value of the cursor is equal to $n$ and fails otherwise (see Figure #{fig pos}).
.KS
.sp 1
.na
.nf
.in +8
$POS(1)$: \(fm\fIr\jaoute 66.\fP\(fm \(-> \(fm\fIr\jboute 66.\fP\(fm
\h'|\nau'\(ua\h'|\nbu'\(ua
\h'|\nau'1\h'|\nbu'1
.in -8
.sp 1
.ce 1
\s-1\fBFigure #{fig pos=figs+}\fP. Example of $POS$.\s0
.sp 1
.ad
.fi
.KE
.LP
$RPOS(n)$
succeeds if the value of the cursor is equal to $length(subject)~-~n~-~1$,
and fails otherwise.
.LP
$SPAN(S)$
moves the cursor past the largest number of characters (but at least one),
all of which must occur in $S$
(see Figure #{fig span}) and fails otherwise.
Note that functions $SPAN$ and $BREAK$ (see below) use
their argument string $S$ as a \fBset\fP of acceptable characters.
.KS
.sp 1
.na
.nf
.in +8
$SPAN($\(fm0123456789\(fm): \(fm\fIroute \ja66.\fP\(fm \(-> \(fm\fIr\jboute 66\jb.\fP\(fm
\h'|\nau'\(ua\h'|\nbu'\(ua
\h'|\nau'6\h'|\nbu'8
.in -8
.sp 1
.ce 1
\s-1\fBFigure #{fig span=figs+}\fP. Example of $SPAN$.\s0
.sp 1
.fi
.ad
.KE
.LP
$BREAK(S)$
moves the cursor (zero or more positions)
to the right until it points to the first character that occurs in $S$
(see Figure #{fig break}), and fails otherwise.
.KS
.sp 1
.na
.nf
.in +8
$BREAK($\(fm86420\(fm): \(fm\fIr\jaoute 66.\fP\(fm \(-> \(fm\fIr\jboute \jb66.\fP\(fm
\h'|\nau'\(ua\h'|\nbu'\(ua
\h'|\nau'1\h'|\nbu'6
.in -8
.sp 1
.ce 1
\s-1\fBFigure #{fig break=figs+}\fP. Example of $BREAK$.\s0
.ad
.fi
.sp 1
.KE
.SH #{sp languages special?=sn+}. "Why are string processing languages special?"
.PP
We shall now consider
three major aspects of string processing languages in more detail:
.IP \*(MK
\fBBookkeeping\fP.
How can a record be kept of the progress of the recognition process?
.IP \*(MK
\fBRecognition strategies\fP.
What is the best method to determine the structure of a given string?
.IP \*(MK
\fBFailure handling\fP.
What should be done if a string cannot be recognized?
.SH #{bookkeeping=sn>1}. "Bookkeeping"
.PP
A general way to formulate many parsing problems
is to divide the problem into a number of \fBrecognition steps\fP of the form
.DS
$S~->~S'$
.DE
in which $S$ (the string to be recognized) is mapped on a new string $S'$
on which the next step operates.
In other words, each step delivers a new string value
for the next step to work on, and each step begins 
its recognition task by looking at the leftmost character of its input string.
An important special case occurs if successive steps operate
strictly from left to right.
In that case, all recognition steps operate on substrings
of the original input string and each step delivers a tail of its input as
result to the next step.
In both the general and the special case, a completely \fBfunctional\fP
(e.g. \s-2LISP\s0-like)
formulation of the recognition process can be achieved.
This approach is attractive, but has several disadvantages, to wit:
.IP \*(MK
The need to explicitly mention the string on which each
step operates has an adverse effect on the size of programs.
.IP \*(MK
If one attempts to exploit the special case,
only strict left-to-right scanning can be formulated,
since the characters in the initial string
that occur left of the start of each substring are lost.
.IP \*(MK
It is not easy to implement the functional model efficiently.
.PP
Another way of looking at the recognition process is to
assume that there is one common string on which all operations work
starting at different cursor positions.
The form of a recognition step then becomes
.DS
$< S,~C sub 1 >~->~<S,~C sub 2 >$
.DE
where $S$ stands for the fixed string to be recognized and
$C sub 1$ and $C sub 2$ stand for the cursor position
before and after the step.
This can be expressed by introducing the notion of a \fBcurrent subject\fP
consisting of a string $S$ and a cursor position $C$ in $S$.
All recognition steps operate on the string $S$
starting at cursor position $C$.
This approach has the advantage of obviating the need to mention the subject
string explicitly each time a new step is performed as well as of providing
cursor management.
In other words, the notation is made more concise at the expense
of introducing a global entity, which
acts as `current focus of activity'.
.PP
In order to limit the field of discussion,
we will only pursue the second approach in this monograph.
Some consequences of the functional approach can be found in [Morris80].
As to the choice made, it is interesting to note that
it is hard to find a notion of a `current focus of activity'
in any existing general purpose programming language.
.SH #{recognition strategy=sn+}. "Recognition strategy"
.PP
Parsing a string amounts to recognizing some given structure in it.
A natural way of expressing such structures is by means of a \fBgrammar\fP.
There exist many kinds of grammar with varying descriptive power
(see for example [Aho72]).
In practice, most grammars have an associated algorithm to
recognize strings belonging to it.
In the design of a string processing language, a decision
must be made regarding the descriptive power and recognition strategy
that will be supported by the language.
One can either restrict the class of admissible grammars to those
having an efficient recognition algorithm, or one can allow arbitrary
context-free grammars and use a general, but less efficient parsing method.
The latter will be done in this monograph, since the problems involved are
interesting and have only been partially explored.
Having chosen a recognition method,
the conciseness of recognition algorithms is, in general, enhanced
by providing a shorthand notation for it.
In this way, the details of the algorithm
(like shifting to a new state or reading the next input symbol)
can be omitted for each recognition step.
.PP
\fBBacktracking\fP
will be used as the recognition method for arbitrary context-free grammars.
Backtracking [Golomb65] is a programming technique for organizing search processes that
are based on trial-and-error.
It amounts to imposing a tree-structure on the search space and traversing
the tree in a predetermined order.
Backtracking can be applied to parsing as follows.
Initially, it is \fBassumed\fP
that a given input sentence can be derived from the grammar rule
.DS
\*<s\*> ::= \*<r\*> .
.DE
where \*<s\*> is the start symbol of the grammar and \*<r\*> is
the right hand side of the grammar rule for \*<s\*>.
This assumption can either be verified in a trivial way
(if \*<r\*> is simple, e.g. a terminal symbol of the grammar)
or the recognition process must prepare itself for the verification
of a more complex assumption.
To this end, new assumptions are made that correspond to the constituents of \*<r\*>.
If all these assumptions turn out to be true, the initial assumption was true.
If an assumption turns out to be false, there are two cases:
.IP \*(MK
There exists an alternative for it.
In this case an attempt is made to verify the alternative.
For example, the assumption that an \*<addition-operator\*> will occur
in the input sentence may turn out to be true if either a `$+$' or `$-$' symbol
is encountered.
.IP \*(MK
There exist no alternatives for the current assumption.
In this case, the `parent' assumption was false, but it may in its turn have
alternatives.
.PP
Several subsidiary questions must be answered when
the particular backtracking method chosen is to be specified completely.
A first question that arises concerns the \fBorder\fP in which alternatives are attempted.
A method is said to be \fBdeterministic\fP
if the order in which alternatives are attempted is reproducible.
In \fBnondeterministic\fP
methods alternatives are attempted in an arbitrary order.
Again, in order to narrow the field of discussion,
we shall restrict our attention entirely to deterministic methods.
A second question to be answered has to do with the \fBmoment\fP
at which the search space is established.
Is it fixed statically at the start of the search process or can
it be modified dynamically during the search?
We shall consider both possibilities.
A final question concerns the precise \fBstructure\fP of the search space.
Does it have the structure of a tree, a directed acyclic graph or perhaps
even an arbitrary graph?
We shall mostly encounter tree-like structures.
.PP
Further aspects of backtracking
(as used in \s-2SNOBOL\s04) are discussed in Section #{problems sp languages}.
.SH #{failure handling=sn+}. "Failure handling"
.PP
The outcome of the entire recognition process is dependent on the
outcome of each individual recognition step.
Since each step may discover the subject string to have an unexpected
form, failure handling is an important issue.
For each step there are two possibilities:
.IP \*(MK
The step succeeds and this fact together with more detailed information
(the recognized part of the subject string, the new cursor value)
have to be made available to subsequent steps.
.IP \*(MK
The step fails and the kind of failure has to be indicated.
.LP
How the success or failure of an individual step affects the
overall recognition process, depends on the particular recognition strategy chosen.
.PP
A short remark on failure handling is appropriate
in anticipation of discussions on this topic
in Chapters #{DESIGN CONSIDERATIONS} and #{SUMMER OVERVIEW}.
When considering the combinations of language features dealing
with failure handling and flow of control,
one has the following choices:
.IP "\ \ 1)"
Include `Boolean' values in the language, which
can be used to remember the outcome of logical operations,
and let the flow of control constructs be dependent on these Boolean values.
All recognition functions should then be Boolean functions;
success or failure of each function is delivered as the result of
its invocation and
subsidiary results (such as the new cursor value)
can then be delivered using call-by-reference parameters.
.IP "\ \ 2)"
Let all `values' in the language consist of (value, signal)-pairs;
the flow of control constructs use the signal-part of each value
and all other constructs use the value-part.
The signal-part of a value can thus be inspected at any moment after the
value has been computed.
Since it may be desirable for the evaluation of an expression to terminate
as soon as one of its subexpressions fails,
all operations in the language should be defined in such a way that
they immediately terminate when one of their arguments is a value containing
a signal-part indicating previous failure.
.IP "\ \ 3)"
All operations generate a `failure signal', which is used to
drive the flow of control constructs.
In contrast to the previous case,
where failure signals can be remembered for later use,
in this case they are transient entities:
failure signals are not part of a value and should be immediately intercepted
when they are generated.
.IP "\ \ 4)"
Include both Boolean values and a general exception handling
mechanism in the language.
The flow of control constructs can then operate on Boolean
values and all other `abnormal' conditions can be taken care of
by the exception handling mechanism.
.LP
Alternative 1) is the obvious choice if recognition functions have
to be embedded in a conventional programming language.
It has the disadvantage that many additional if-statements are
required to test the outcome of each recognition function.
Alternative 2) is interesting since it allows differentiation between
sources of failure (by specifying different values in the signal-part)
without introducing complicated flow of control primitives
needed for general exception handling.
Alternative 3) is a compromise between expressive power and simplicity:
it incorporates exception handling for one kind of exception
(failure signals) but does not require complicated flow of control
primitives in the language.
This alternative will play an important role in our studies.
Alternative 4) is the most general, but at the same time the most
complicated form of expression evaluation.
It will not be considered here to avoid the many unsolved problems
associated with general exception handling.
See, for instance, [Goodenough75] or [Luckham80] for a discussion of this issue.
.SH #{existing languages=sn+}. "Existing languages and string processing"
.PP
By combining the language requirements encountered in Section #{subject monograph} with
the more detailed characteristics of string processing given above, we arrive
at the following list of language requirements for string processing:
.IP R1.
Recognition power at the syntactic level.
If recognition of arbitrary context-free grammars is desired, then
some form of backtracking should be available in the language.
The notion of a `subject string' should be available.
.IP R2.
Failure handling, i.e. language constructs for
(restricted) exception handling.
.IP R3.
Data structures that can be allocated dynamically and that may grow dynamically.
.LP
Other obvious requirements that apply to \fBall\fP
kinds of programming languages, such as modularity and adequate control structures,
are taken for granted and
will not be considered here.
.PP
Two general observations will place these requirements in perspective.
First of all, it should be noted that \fBall\fP envisaged applications
\fBcould\fP be implemented using \s-2FORTRAN\s0, assembly language, etc.
However, the introduction of special language features for string processing
can result in a programming language that is much more suited to
string processing applications than other languages that are
not `optimized' for this particular application.
.PP
Secondly, one should bear in mind that we have chosen to investigate
problems related to backtracking.
Backtracking is just another programming technique,
but manifests itself differently when integrated with
other constructs in a programming language.
This becomes particularly clear if side-effects are taken into account.
The incorporation of backtracking facilities into a programming language
makes it possible to
define explicitly the interaction between backtracking and the operations
that may cause side-effects (e.g. assignment statements).
This cannot be achieved if backtracking is added on top of
an existing programming language by, for example, procedural extension.
.PP
There are also more specific reasons for designing a new language instead
of choosing an existing one.
Only the chief shortcomings of \s-2PASCAL\s0 [Wirth71] and \s-2ALGOL\s068
[VanWijngaarden76] will be discussed here;
a discussion of \s-2SNOBOL\s04 is postponed to Section #{problems sp languages}.
.PP
There are five major obstacles to using \s-2PASCAL\s0 for string processing.
First, the size of \s-2PASCAL\s0 data structures is fixed statically and this
conflicts with requirement R3.
Secondly, the programmer has to be aware of the life-time of some data structures;
these must allocated and de-allocated explicitly.
Thirdly, the size of strings is part of their type, i.e.
two strings of different length have different type and cannot, for example,
be assigned to the same variable.
Several attempts (see for instance [Sale79])
have been made to eliminate this problem, but none seems successful.
Fourthly, it is not easy to incorporate any form of failure or
exception handling into the language.
Finally, backtracking and more specifically the control of side-effects
during backtracking are difficult, if not impossible, to implement in \s-2PASCAL\s0.
.PP
There are three major obstacles if one tries to use
\s-2ALGOL\s068 for string processing.
First, the programmer is responsible for the allocation of objects
on the heap.
This is a nuisance since, typically, procedures deliver objects that
have a longer life-time than the procedure itself and such objects must
therefore be explicitly allocated on the heap.
The other two obstacles are the same as the ones mentioned for \s-2PASCAL\s0:
the difficulty of implementing failure handling and backtracking.
.SH #{problems sp languages=sn<+}. "Problems in string processing languages"
.PP
There are several problems in existing string processing languages
and most of them are a consequence of side-effects
occurring during the recognition process.
These problems will now be illustrated by introducing an absolute minimum
of \s-2SNOBOL\s04 [Griswold71]
(being the best known string processing language)
and by giving some \s-2SNOBOL\s04 examples that exhibit these problems.
.SH #{Snobol4 introduction=sn>1}. "A short introduction to \s-2SNOBOL\s04"
.PP
In \s-2SNOBOL\s04 the recognition steps are described by a \fBpattern\fP
and the recognition process is called \fBpattern matching\fP.
A pattern defines a set of acceptable strings and acts as a predicate that
succeeds or fails when it is presented with a string that is or is not
in the set of acceptable strings.
A pattern may also perform arbitrary computations while deciding
whether a given string is acceptable or not.
The general form of a \s-2SNOBOL\s04 statement is:
.DS
\*<label\*> \*<subject\*> \*<pattern\*> \*{'='\*} \*<replacement\*> \*<goto\*>
.DE
A \*<label\*> identifies a statement and allows other statements to `jump'
to that statement.
A \*<subject\*> followed by a \*<pattern\*> indicates the beginning of a pattern match
to determine whether the subject string contains a substring
that is in the set of acceptable strings defined by the pattern.
If so, the matched substring is replaced by
the \*<replacement\*> string and execution proceeds at the statement
associated with success.
Otherwise, no replacement takes place and
execution proceeds at the statement associated with failure.
The labels of the successor statements for success and failure are given in
the \*<goto\*> field.
Most parts of a \s-2SNOBOL\s04 statement are optional.
Apart from the two examples that follow, we shall only consider
statements in which all fields
except the subject and pattern field are empty.
.DS
Example 1:

\*{ L  X  SPAN('0123456789')  :S(P)F(Q)\*}
.DE
.LP
Here, \*{L\*} is the \*<label\*>,
\*{X\*} is the \*<subject\*>,
\*{SPAN('0123456789')\*} is the \*<pattern\*> and
\*{:S(P)F(Q)\*} is the \*<goto\*>.
The result of executing the above statement is a
jump to label \*{P\*} if the subject string \*{X\*} contains a span of digits
or a jump to label \*{Q\*} otherwise.
.DS
Example 2:

\*{L  PACT  'multi-lateral' = 'impossible'\*}
.DE
.LP
Replaces the first occurrence of the string \*{'multi-lateral'\*} in \*{PACT\*} by
the string \*{'impossible'\*}.
Does nothing if the pattern fails, since no `failure' label was given in the \*<goto\*> field.
.PP
All these pattern matches are \fBunanchored,\fP
i.e. the pattern as a whole is attempted at all cursor positions in the subject string.
.SH #{Compound patterns=sn+}. "Compound patterns"
.PP
Compound patterns are constructed from primitive ones
(i.e. the literal string, \*{SPAN\*}, \*{BREAK\*}, etc.)
by means of \fBpattern concatenation\fP and \fBpattern alternation\fP.
The construction of compound patterns is performed
\fBbefore\fP the pattern match is started.
This leads to two evaluation moments:
\fBpattern construction time\fP and \fBpattern matching time\fP.
.PP
The concatenation of two patterns $P sub 1$ and $P sub 2$ is written as
.DS
$P sub 1~~P sub 2$
.DE
(i.e. $P sub 1$ followed by $P sub 2$ separated by one or more space characters)
This constructs a new pattern that will apply
$P sub 1$ followed by $P sub 2$.
For example,
.DS
\*{YEAR  'AD' SPAN('0123456789')\*}
.DE
succeeds if \*{YEAR\*} contains the string \*{'AD'\*} followed by digits.
.PP
The alternation of two patterns $P sub 1$ and $P sub 2$ is written as
.DS
$P sub 1~|~P sub 2$
.DE
and constructs a new pattern that will succeed
if either $P sub 1$ succeeds, or
$P sub 1$ fails but $P sub 2$ succeeds.
For example,
.DS
\*{YEAR  'UNKNOWN' | SPAN('0123456789')\*}
.DE
succeeds if \*{YEAR\*} contains \fBeither\fP the string \*{'UNKNOWN'\*} \fBor\fP
a span of digits and
.DS
\*{X  ('d' | 'b') 'ea' ('n' | 'r' | 'd')\*}
.DE
will succeed if \*{X\*} contains \*{'dean'\*}, \*{'dear'\*},
\&\*{'dead'\*}, \*{'bean'\*}, \*{'bear'\*}, or \*{'bead'\*}
as substring.
.PP
In fact, compound patterns represent \fBand/or goal-trees\fP
(see [Nilsson71]) and a pattern match
succeeds if (part of) the tree has been `traversed successfully'.
Figure #{fig and/or} shows the and/or tree corresponding to the last example.
.KF
.PS
.nf
AND:	circle "and"

OR1:	circle "or" at AND - (1i, 1i)

EA:	"\(fm\fIea\(fm\fP" at AND - (0, 1i)

OR2:	circle "or" at AND + (1i, -1i)


FIG:	line from AND.sw to OR1.n

# children of OR1
	B1: "\(fm\fId\(fm\fP" at OR1 - (0.75i, 1i)
	B2: "\(fm\fIb\(fm\fP" at OR1 + (0.75i, -1i)
	line from OR1 to B1 chop
	line from OR1 to B2 chop

# child EA

	line from AND.s to EA.n

# OR2
	line from AND.se to OR2.n

	B3: "\(fm\fIn\(fm\fP" at OR2 - (0.75i, 1i)
	B4: "\(fm\fIr\(fm\fP" at OR2 - (0, 1i)
	B5: "\(fm\fId\(fm\fP" at OR2 + (0.75i, -1i)
	line from OR2 to B3 chop
	line from OR2 to B4 chop
	line from OR2 to B5 chop
.fi
.PE
.sp 1
.ce
\s-1\fBFigure #{fig and/or=figs+}\fP. And/or goal tree.\s0
.sp 1
.KE
.PP
If the root of the tree is an `and' node (representing pattern concatenation),
\fBall\fP immediate subtrees of the root must have been traversed successfully
before the pattern match succeeds.
If the root of the tree is an `or' node (representing pattern alternation), only
\fBone\fP
immediate subtree of the root must have been traversed successfully before
the pattern match succeeds.
In the last case the pattern may have untried alternatives,
i.e. unattempted immediate subtrees of the root.
All subtrees of an alternative node are always attempted starting at the same
cursor position.
.PP
The tree is traversed by means of \fBbacktracking\fP;
this is a structured form of trial-and-error (see #{recognition strategy}).
When one attempt to traverse a subtree fails,
the aforementioned untried alternatives may lead to a different,
but successful traversal of the tree.
.SH #{side effects=sn+}. "Side-effects during pattern matching"
.PP
The \s-2SNOBOL\s04 patterns introduced so far cannot
have side-effects:
the values of variables in the program cannot be modified during the traversal
of the tree if only pattern concatenation and pattern alternation are used.
However, several other operations are available in \s-2SNOBOL\s04
and these can have side-effects.
Three of them are:
\fBimmediate value assignment\fP, \fBconditional value assignment\fP
and
\fBunevaluated expressions\fP.
.br
.ne 4
.PP
\fBImmediate value assignment\fP
is written as
.DS
$P~roman "$"~V$
.DE
and constructs a new pattern that will assign to variable $V$
the part of the subject string that is recognized by pattern $P$.
This assignment is performed immediately, i.e. at the moment that the
immediate value assignment operation is encountered in the pattern tree.
For example
.DS
\&\*{'AD 1984'  SPAN('0123456789')\*} $roman "$"$ \*{YEAR\*}
.DE
assigns the string \*{'1984'\*} to the variable \*{YEAR\*}, and
.DS
\&\*{'1984 BC'  (SPAN('0123456789')\*} $roman "$"$ \*{YEAR) ' AC'\*}
.DE
fails, but also assigns \*{'1984'\*} to \*{YEAR\*}.
.PP
\fBConditional value assignment\fP is written as
.DS
$P~.~V$
.DE
and constructs a new pattern that will assign to variable $V$
the part of the subject string that is recognized by pattern $P$.
Assignment is \fBonly\fP performed at the end of a successful pattern match.
For example,
.DS
\&\*{'1984'  SPAN('0123456789') . YEAR\*}
.DE
assigns \*{'1984'\*} to \*{YEAR\*}, but
.DS
\&\*{'1984  BC' (SPAN('0123456789') . YEAR) 'AC'\*}
.DE
fails and does \fBnot\fP assign a new value to \*{YEAR\*}.
.PP
Finally, let $E$ be an arbitrary \s-2SNOBOL\s04 expression.
\fBUnevaluated expressions\fP,
written as
.DS
\*{*E\*}
.DE
construct a new pattern that will evaluate
the expression $E$ at the moment
the new pattern is encountered during the match.
The value of $E$ is then used as the pattern to be recognized.
For example,
.DS
\*{X  (SPAN('0123456789')\*} $roman "$"$ \*{Y) 'AA' *Y\*}
.DE
succeeds if \*{X\*} contains two identical spans of digits separated by the
string \*{'AA'\*}.
Note that, in this example, side-effects are used that were the result of
previous operations in the pattern match, namely the immediate value
assignment to the variable \*{Y\*}.
In general, the evaluation of an unevaluated expression may itself cause
side-effects.
.PP
With the introduction of these operations,
the program state can be influenced during a pattern match by:
.IP \*(MK
immediate value assignments
.IP \*(MK
cursor movements caused by recognition operations
.IP \*(MK
side-effects caused by the evaluation of unevaluated expressions.
.LP
Note that conditional value assignment can only affect the state
at the completion of a successful pattern match.
.SH #{Snobol4 problems=sn+}. "Problems with the \s-2SNOBOL\s04 approach"
.PP
A more elaborate example will give the reader some feeling for the
complexity that can result from the application of
\s-2SNOBOL\s04 pattern matching operations.
Let \*{P\*} be the pattern defined by
.DS
\*{((LEN(2)\*} $roman "$"$ \*{X) ('CD' | 'EF') . Y *X *Y) | (LEN(3) . Y)\*}
.DE
and assume that the variables \*{X\*} and \*{Y\*}
both have initial value \*{'ZZZ'\*}.
Considering the pattern match
.DS
\&\*{'ABCDABZZZ'  P\*}  ,
.DE
which values will be assigned to \*{X\*} and \*{Y\*} after execution it?
The following intermediate steps provide the answer.
.IP \ \ 1)
\*{LEN(2)\*} immediately assigns \*{'AB'\*} to \*{X\*}.
.IP \ \ 2)
\*{('CD' | 'EF')\*} conditionally assigns \*{'CD'\*} to \*{Y\*},
i.e. assignment is not performed but remembered.
.IP \ \ 3)
\*{*X\*} evaluates to \*{'AB'\*}, and this pattern succeeds.
.IP \ \ 4)
\*{*Y\*} evaluates to \*{'ZZZ'\*} (the initial value of \*{Y\*}!), and this pattern succeeds.
.IP \ \ 5)
The pattern match succeeds and the conditional value assignment to \*{Y\*}
(which was remembered in step 2, above) is performed.
.IP \ \ 6)
At the completion of the pattern match,
\*{X\*} has value \*{'AB'\*} and \*{Y\*} has value \*{'CD'\*}.
.LP
The problems with the \s-2SNOBOL\s04 approach can now be summarized as follows:
.IP \*(MK
Side-effects during the pattern match in combination with
immediate/conditional value assignment lead to opaque programs in which
left-to-right textual order
of the program source text need not correspond to the actual order of evaluation.
.IP \*(MK
Backtracking is completely automatic and cannot be controlled by the
programmer.
This may either lead to gross inefficiencies or to undesired or unexpected
behavior of programs.
.IP \*(MK
There are two different vocabularies in the language.
One for expression evaluation and another for pattern matching
(see [Griswold80]).
.SH #{checklist=sn<+}. "A checklist for string processing languages"
.PP
After this inventory of string processing operations and associated problems
in string processing languages one can compose a list
of questions that can serve as a basis for the characterization of
string processing languages.
As with any questionnaire, the questions asked largely determine the answers
one gets.
The list of questions given here is based on a particular view of the way in
which string processing languages should develop.
This point of view will be explained in more detail in Chapter #{DESIGN CONSIDERATIONS}.
.SH #{checklist:treatment subject=sn>1}. "Treatment of the subject"
.IP \*(MK
Can the subject be defined explicitly?
.IP \*(MK
What is the scope of the subject?
Is it the whole program, one procedure or one statement?
.IP \*(MK
Can more than one subject be defined?
And if so, are subjects defined consecutively
or simultaneously?
.IP \*(MK
Which data types can the subject have?
Possibilities are character string, character file, integer array
and perhaps others.
.SH #{checklist:recognition strategy=sn+}. "Recognition strategy"
.PP
One can distinguish several recognition strategies, such as
the ones used for the recognition of regular expressions and
LL(k) or LR(k) languages,
and the techniques used for
recursive descent and backtrack parsing.
Only recursive descent parsing and backtrack parsing will be considered
in this monograph.
There are two reasons for making this restriction.
The first reason is historical, since initially \s-2SNOBOL\s04 was taken
as a starting point and backtrack parsing is the only recognition
strategy available in that language.
The second reason is that backtrack parsing allows the recognition
of a wider class of languages than is possible with, for example,
LR(1) parsers.
In general, it might be a better idea to
make the recognition strategy invisible at the programming language level
and to let the implementation choose the best
strategy for a given problem.
This line of development is interesting but falls outside the scope
of the current work.
.PP
With respect to backtrack parsers, the following questions can be asked:
.IP \*(MK
Are side-effects possible during the recognition process?
.IP \*(MK
How are side-effects treated in case of failure?
See the last point below.
.IP \*(MK
How is flow of control backtracking organized, i.e.
how is the next alternative selected?
One can distinguish between \fIad hoc\fP and systematic flow of control backtracking.
In the former case, the programmer has to indicate each alternative explicitly
while in the latter case, alternatives are determined in some systematic, implicit
manner.
Systematic backtracking may either be completely automatic or the
programmer may have the possibility
of exercising more detailed control over the backtracking process.
.IP \*(MK
How is data backtracking organized, i.e.
how is determined which values program variables should have
after an attempt failed?
Here one can distinguish \fIad hoc\fP and systematic backtracking in the same
way as above.
.SH #{sn<+}. "References for Chapter #{INTRODUCTION}"
.so refs/Aho72
.so refs/Golomb65
.so refs/Goodenough75
.so refs/Griswold80
.so refs/Griswold71
.so refs/Luckham80
.so refs/Morris80
.so refs/Mowshowitz81
.so refs/Nilsson71
.so refs/Sale79
.so refs/VanWijngaarden76
.so refs/Weizenbaum76
.so refs/Wirth71
#{sn<;}#{figs<;}
.EC
