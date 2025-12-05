DESTDIR=/summer/paulk/sys/bin
MACHINE=VAX
CC=cc
S=

parser:	parser.sm parser.ns parser.ud parser.syn
	rm parser.sm
	pgen -n -u parser.syn
	sumc  parser
	mv parser o.parser
	mv a.out parser
	mv parser.o boot$(MACHINE)/parser.o
	mv parser.s boot$(MACHINE)/parser.s

sumc:	sumc.sh
	sed "/SUMMERBIN=/s!=.*!=$(DESTDIR)!;/CC=/s/=.*/=$(CC)/" <sumc.sh >sumc
	chmod 0755 sumc
	echo "mv summer/comp/sumc to directory with executable programs"

install: parser  sumc
	mv parser $(DESTDIR)/parser

compare: parser
	cmp parser $(DESTDIR)/parser
	cmp sumc $(DESTDIR)/sumc
regen:	parser
	(PARSER=parser sumc .o .s parser)
	cmp parser.s boot$(MACHINE)/parser.s
