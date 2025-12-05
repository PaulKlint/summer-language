pat-ic:	pat-ic.sm
	sumc pat-ic.sm
	mv a.out pat-ic
pat-ic.sm:	pat-ic.syn pat-ic1.def pat-ic2.def match1.def match2.def
	(echo ".{{"; cat match1.def; echo ".}}") | Boldkw >match1.so
	cat match[12].def pat-ic[12].def >@.def
	(echo ".{{"; cat pat-ic1.def; echo ".}}") |\
	sed "s/enter.*//;s/fret;//;s/\?//" | Boldkw >pat-ic1.so
	cat pat-ic.syn exp.syn >@.syn
	../parsgen ../lex.sm @.syn @.def >pat-ic.sm
pat-rc:	pat-rc.sm
	sumc pat-rc.sm
	mv a.out pat-rc
pat-rc.sm:	pat-rc.syn pat-rc1.def pat-rc2.def match1.def match2.def
	(echo ".{{"; cat match1.def; echo ".}}") | Boldkw >match1.so
	cat match[12].def pat-rc[12].def >@.def
	(echo ".{{"; cat pat-rc1.def; echo ".}}") |\
	sed "s/enter.*//;s/fret;//;s/\?//" | Boldkw >pat-rc1.so
	cat pat-rc.syn exp.syn >@.syn
	../parsgen ../lex.sm @.syn @.def >pat-rc.sm
print: 
	print exp.syn match1.def pat-ic.syn pat-ic[12].def pat-ic.out  \
	      pat-rc.syn pat-rc[12].def pat-rc.out match2.def
