BINARIES=squeeze.o util.o string.o subr.o prof.o scan.o file.o bits.o \
       integer.o real.o array.o table.o interval.o icname.o eval.o cache.o alloc.o collect.o osint.o print.o tracer.o
CC=cc
MACHINE=VAX
CFLAGS=-c -O -D$(MACHINE)
DESTDIR=../bin

int.a:	$(BINARIES)
	ar crv int.a $(BINARIES)
	ranlib int.a
alloc.o:	summer.h alloc.c
	$(CC) $(CFLAGS) alloc.c
array.o:	summer.h array.c
	$(CC) $(CFLAGS) array.c
bits.o:		summer.h bits.c
	$(CC) $(CFLAGS) bits.c

cache.o:	summer.h cache.c
	$(CC) $(CFLAGS) cache.c
collect.o:	summer.h collect.o
	$(CC) $(CFLAGS) collect.c
eval.o:		summer.h operator.h eval.c
	$(CC) $(CFLAGS) -S eval.c
	sed "s/IC_/_IC_/g" <eval.s >tmp
	mv tmp eval.s
	as -o eval.o eval.s
file.o:		summer.h file.c
	$(CC) $(CFLAGS) file.c
icname.o:	summer.h icname.c
	$(CC) $(CFLAGS) icname.c
integer.o:	summer.h integer.c
	$(CC) $(CFLAGS) integer.c
interval.o:	summer.h interval.c
	$(CC) $(CFLAGS) interval.c
osint.o:	summer.h osint.c
	$(CC) $(CFLAGS) osint.c
print.o:	summer.h print.c
	$(CC) $(CFLAGS) print.c
prof.o:		summer.h prof.c
	$(CC) $(CFLAGS) prof.c
real.o:		summer.h real.c
	$(CC) $(CFLAGS) real.c
scan.o:		summer.h scan.c
	$(CC) $(CFLAGS) scan.c
squeeze.o:	summer.h squeeze.c
	$(CC) $(CFLAGS) squeeze.c
string.o:	summer.h string.c
	$(CC) $(CFLAGS) string.c
subr.o:		summer.h subr.c
	$(CC) $(CFLAGS) subr.c
table.o:	summer.h table.c
	$(CC) $(CFLAGS) table.c
tracer.o:	summer.h tracer.c
	$(CC) $(CFLAGS) tracer.c
util.o:		summer.h util.c
	$(CC) $(CFLAGS) util.c

install: int.a
	mv int.a $(DESTDIR)/int.a
compare: int.a
	cmp int.a $(DESTDIR)/int.a

print:
	print summer.h operator.h *.c
lint:
	lint -D$(MACHINE) -hacun *.c
