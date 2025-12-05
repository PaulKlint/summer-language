/*
 * Summer -- operating system interface
 */

#include "summer.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vadvise.h>

#include <signal.h>
long cputime(){
	struct tbuffer {
		long	proc_user_time;
		long	proc_system_time;
		long	child_user_time;
		long	child_system_time;
	} buf;

	times(&buf);
	return(buf.proc_user_time);
}
/*
 * filesize: determine the length of file fp.
 */

long filesize(fp)
FILE fp;{
	struct stat statbuf;


fstat_retry:
	if(fstat(fp->fl_descr, &statbuf) < 0){
		INTERRUPT(fstat_retry);
		error("fstat fails");
	}
	return(statbuf.st_size);
}

interrupt(signo){
	signal(SIGINT, interrupt, -1);
	bpttrace = 1;
	some_trace = 1;
	inter_catched = 1;
}

enable_interrupt(){
	/*
	 * Enable interrupts only, if standard input (file descriptor 0)
	 * comes directly from a terminal.
	 */
	if(isatty(0))
		signal(SIGINT, interrupt, -1);
}
/*
 * Indicate to the system nonstandard paging behavior during
 * garbage collection.
 * (Typical to VMUNIX)
 */

vm_normal() { vadvise(VA_NORM);}

vm_anormal() { vadvise(VA_ANOM);}

