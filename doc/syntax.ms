.NC #{SYNTAX SUMMARY=sn+} "SUMMARY OF SUMMER SYNTAX" " "
.ds RH "SUMMARY OF SUMMER SYNTAX
.sp 1
.LP
.nf
.<<
<summer-program> ::=
        (  <variable-declaration> | <constant-declaration> |
           <procedure-declaration> | <operator-declaration> |
           <class-declaration> | <operator-symbol-declaration>
        )*
        <program-declaration> .
.>>
.sp 0.5
.<<
<program-declaration> ::=
        PROGRAM <identifier> '(' [<identifier>] ')' [<expression>] .
.>>
.sp 0.5
.<<
<operator-symbol-declaration> ::=
        (MONADIC | DYADIC) { <operator-symbol> ',' }+ ';' .
.>>
.sp 0.5
.<<
<class-declaration> ::=
        CLASS <identifier> <formals>
        BEGIN <subclass-declaration>
              <fetch-associations> <store-associations>
              (  <variable-declaration> | <constant-declaration> |
                 <procedure-declaration> | <operator-declaration>
              )*
              [ INIT ':' <block> ]
        END <identifier> ';' .
.>>
.sp 0.5
.<<
<subclass-declaration> ::= [ SUBCLASS OF <identifier> ';' ] .
.>>
.sp 0.5
.<<
<fetch-associations> ::= [ FETCH <associations> ';' ] .
.>>
.sp 0.5
.<<
<store-associations> ::= [ STORE <associations> ';' ] .
.>>
.sp 0.5
.<<
<associations> ::= { <association> ',' }+ .
.>>
.sp 0.5
.<<
<association> ::= <field-identifier> [ ':' <identifier> ] .
.>>
.sp 0.5
.<<
<field-identifier> ::= <identifier> | <operator-symbol> .
.>>
.sp 0.5
.<<
<procedure-declaration> ::=
        PROC <identifier> <formals> [ <expression> ] ';' .
.>>
.sp 0.5
.<<
<operator-declaration> ::=
        OP <operator-symbol> <formals> [ <expression> ] ';' .
.>>
.sp 0.5
.<<
<variable-declaration> ::= VAR { <variable-initialization> ',' }+ ';' .
.>>
.sp 0.5
.<<
<variable-initialization> ::= <identifier> [ ':=' <expression> ] .
.>>
.sp 0.5
.<<
<constant-declaration> ::= CONST { <constant-initialization> ',' }+ ';' .
.>>
.sp 0.5
.<<
<constant-initialization> ::= <identifier> ':=' <constant-expression> .
.>>
.sp 0.5
.<<
<formals> ::= '(' { <identifier> ',' }* ')' .
.>>
.sp 0.5
.<<
<constant> ::= <string-constant> | <integer-constant> | <real-constant> .
.>>
.sp 0.5
.<<
<constant-operator> ::= '+' | '-' | '*' | '/' | '%' | '||' .
.>>
.sp 0.5
.<<
<constant-expression> ::=
        <simple-constant-expression>
        (<constant-operator> <constant-expression>)* .
.>>
.sp 0.5
.<<
<simple-constant-expression> ::=
        <constant> | <identifier> | '(' <constant-expression> ')' |
        '-' <simple-constant-expression> .
.>>
.sp 0.5
.<<
<expression> ::= <dyadic-expression> .
.>>
.sp 0.5
.<<
<monadic-expression> ::= (<monadic-operator>)* <primary> .
.>>
.sp 0.5
.<<
<monadic-operator> ::= '~' | '-' | <operator-symbol> .
.>>
.sp 0.5
.<<
<dyadic-operator> ::=
        '+'  | '-'   | '*'   | '/'  | '%'  | '||' | '<' | '<=' | '>'  | '>=' |
        '='  | '~='  | ':='  | '&'  | '|'  | <operator-symbol> .
.>>
.sp 0.5
.<<
<dyadic-expression> ::=
        <monadic-expression> (<dyadic-operator> <monadic-expression>)* .
.>>
.sp 0.5
.<<
<primary> ::= <unit> ( <subscript> | <select> )* .
.>>
.sp 0.5
.<<
<unit> ::= 
        <constant> | <identifier-or-call> | <return-expression> |
        <if-expression> | <case-expression> | <while-expression> |
        <for-expression> | <scan-expression> | <try-expression> |
        <assert-expression> | <parenthesized-expression> |
        <array-expression> | <table-expression> .
.>>
.sp 0.5
.<<
<identifier-or-call> ::= <identifier> [ <actuals> ] .
.>>
.sp 0.5
.<<
<actuals> ::= '(' { <expression> ',' }* ')' .
.>>
.sp 0.5
.<<
<subscript> ::= '[' <expression> ']' .
.>>
.sp 0.5
.<<
<select> ::= '.' <identifier> [ <actuals> ] .
.>>
.sp 0.5
.<<
<return-expression> ::= FRETURN | RETURN [ '(' <expression> ')' ] .
.>>
.sp 0.5
.<<
<while-expression> ::= WHILE <test> DO <block> OD .
.>>
.sp 0.5
.<<
<try-expression> ::= TRY { <expression> ',' }+ [UNTIL <block>] YRT .
.>>
.sp 0.5
.<<
<scan-expression> ::= SCAN <expression> FOR <block> ROF .
.>>
.sp 0.5
.<<
<for-expression> ::= FOR <identifier> IN <expression> DO <block> OD .
.>>
.sp 0.5
.<<
<case-expression> ::=
        CASE <expression> OF { <case-entry> ',' }* [ DEFAULT ':' <block>] ESAC .
.>>
.sp 0.5
.<<
<case-entry> ::= { <constant-expression> ':' }+ <block> .
.>>
.sp 0.5
.<<
<assert-expression> ::= ASSERT <expression> .
.>>
.sp 0.5
.<<
<if-expression> ::=
        IF <test> THEN <block>
        ( ELIF <test> THEN <block> )*
        [ELSE <block>] FI .
.>>
.sp 0.5
.<<
<test> ::= <expression> [ FAILS | SUCCEEDS ] .
.>>
.sp 0.5
.<<
<parenthesized-expression> ::= '(' <block> ')' .
.>>
.sp 0.5
.<<
<block> ::=
        (<variable-declaration>|<constant-declaration>)* {[<expression>] ';'}* .
.>>
.sp 0.5
.<<
<array-expression> ::=
        ARRAY <size-and-default> [ INIT <array-initialization> ]  |
        <array-initialization> .
.>>
.sp 0.5
.<<
<size-and-default> ::= '(' <expression> ',' <expression> ')' .
.>>
.sp 0.5
.<<
<array-initialization> ::= '[' { <expression> ',' }* ']' .
.>>
.sp 0.5
.<<
<table-expression> ::=
        TABLE <size-and-default> [ INIT <table-initialization> ] |
        <table-initialization> .
.>>
.sp 0.5
.<<
<table-initialization> ::= '[' { <table-element> ',' }* ']' .
.>>
.sp 0.5
.<<
<table-element> ::= {<expression> ':'}+ ':' <expression> .
.>>
.sp 0.5
