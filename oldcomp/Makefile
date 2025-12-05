DESTDIR=/grp/ai/paulk/summer/bin
MACHINE=VAX
CC=cc
DESTDIR=/grp/ai/paulk/summer/bin
S=

comp:	parser codgen prefix

parser:	parser.ns parser.ud parser.syn prefix
	rm parser.sm
	pgen -n -u parser.syn
	(PREFIX=prefix sumc $S parser)
	mv a.out parser
	mv parser.o boot$(MACHINE)/parser.o
	mv parser.s boot$(MACHINE)/parser.s

codgen:	codgen.sm prefix
	(PREFIX=prefix sumc $S .o .s codgen)
	mv a.out codgen
	mv codgen.o boot$(MACHINE)/codgen.o
	mv codgen.s boot$(MACHINE)/codgen.s

prefix: ../int/summer.h ../int/operator.h
	sumc mkpref
	mv a.out mkpref
	mkpref  $(MACHINE)
	cp prefix boot$(MACHINE)/prefix

sumc:	sumc.sh
	sed "/SUMMERBIN=/s!=.*!=$(DESTDIR)!;/CC=/s/=.*/=$(CC)/" <sumc.sh >sumc
	chmod 0755 sumc
	echo "mv summer/comp/sumc to directory with executable programs"

install: parser codgen prefix sumc
	mv parser $(DESTDIR)/parser
	mv codgen $(DESTDIR)/codgen
	cp prefix $(DESTDIR)/prefix

compare: parser codgen prefix
	cmp parser $(DESTDIR)/parser
	cmp codgen $(DESTDIR)/codgen
	cmp sumc $(DESTDIR)/sumc
	cmp prefix $(DESTDIR)/prefix
regen:	parser codgen
	(PARSER=parser CODGEN=codgen sumc .o .s parser)
	cmp parser.s boot$(MACHINE)/parser.s
	(PARSER=parser CODGEN=codgen sumc .o .s codgen)
	cmp codgen.s boot$(MACHINE)/codgen.s
