<letter>	::= 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h' |
		    'i' | 'j' | 'k' | 'l' | 'm' | 'n' | 'o' | 'p' |
		    'q' | 'r' | 's' | 't' | 'u' | 'v' | 'w' | 'x' |
		    'y' | 'z' | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' |
		    'G' | 'H' | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' |
		    'O' | 'P' | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' |
		    'W' | 'X' | 'Y' | 'Z' .
<digit>		::= '0' | '1' | '2' | '3' | '4' |
		    '5' | '6' | '7' | '8' | '9' .
<identifier>	::= <letter> (<letter> | <digit> | '_')* .
<operator-identifier>	::= '_' (<letter> | <digit>)+ '_' |
		    ( '*' | '+' | '-' | '/' | ':' | '<' | '=' | '>' |
		      '|' | '&' | '~' | '!' | '\\\\' | '@' | '?' | '$')+ .
<integer-constant>	::= <digit>+ .
<real-constant>		::=
	['+'|'-'] <digit>* ['.' <digit>*] [ 'e' ['+'|'-'] <digit>+ ] .
<string-constant>	::= <squote> <string-item>* <squote> .

<string-item>		::= <ascii-char-except-squote> |
			    '\\\\' ('b' | 'n' | 't' | '\\\\') |
			    '\\\\' <digit> <digit> <digit> |
			    <squote> <squote> .
