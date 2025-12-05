#
/*
 * Summer -- profiling
 */

#include	"summer.h"


double tot;
/*
 * Conversion from cputime counts to milli seconds.
 * Assuming a line frequency of 50 HZ (be aware!)
 * each count corresponds to 1/50 second
 * or 20 mseconds.
 */
#define TO_MSEC(p)	((p) * 20)


putreal(f)
double f;{
	struct string *s;
	int n;

	s = realtostr(f, 2);
	n = 8 - s->str_size;
	while(--n > 0)
		putstring(" ");
	put1(s);
	putstring(" ");
};

/*
 * The following routine prints one line in the profile.
 * It contains a bug:
 * 	If a field procedure with the same name occurs more
 *	then once, the same name is repeated several times.
 *	The should be changed by prefixing each name with
 *	the name of the class to which the field belongs.
 *	i.e.	array.size
 *		string.size
 */

profcall(proc, p, f)
SUMDP proc; int p, f;{
	double totcall, percall, perc;

	if(f == 0)
		return;
	totcall = TO_MSEC(p);
	percall = totcall / f;
	perc    = (totcall / tot) * 100;
	putreal(f+0.0);
	putreal(totcall);
	putreal(percall);
	putreal(perc);
	if(T_DATATYPE(proc) == NIL)
		putstring("COLLECT");
	else {
		if((T_PROC(proc)->proc_fld != NIL) &&
		   (T_PROC(proc)->proc_fld != CAST(struct fld *) -1)){
			put1(findclassname(proc));
			putstring(".");
		}
		put1(findname(proc));
	}
	put1(Snl);
}

profprint(){
	SUMDP *v;
	extern SUMDP globals[];
	extern SUMDP eglobals;
	extern STRING globnames[];
	int  i;
	long p;

	tot = col_time;
	for(v = globals; v < &eglobals; v++){
		if(DT(*v) == DT_PROC)
			if((p = T_PROC(*v)->proc_prof) > 0){
				tot += p;
				T_PROC(*v)->proc_prof = -p;
			}
		else
		if(DT(*v) == DT_SUBR)
			if((p = T_SUBR(*v)->subr_prof) > 0){
				tot += p;
				T_SUBR(*v)->subr_prof = -p;
			}
	}
	for(i = 0; i < nsubrs; i++)
		if((p = subrs[i]->subr_prof) > 0){
			tot += p;
			subrs[i]->subr_prof = -p;
		}

	for(i = 0; i < nfields; i++){
		struct fldentry *f;
		int j, k;

		for(j = 0; j <nclasses; j++){
			struct proc *proc;

			k = fields[i]->fld_switch[j];
			if(k < 0)
				continue;
			f = &fields[i]->fld_entries[k];
			if(((proc = f->fldent_type) != NIL) && (proc->dt.dt_val == DT_PROC))
				if((p = proc->proc_prof) > 0){
					tot += p;
					proc->proc_prof = -p;
				}
			if(((proc = f->fldent_fetch) != NIL) && (proc->dt.dt_val == DT_PROC))
				if((p = proc->proc_prof) > 0){
					tot += p;
					proc->proc_prof = -p;
				}
			if(((proc = f->fldent_store) != NIL) &&(proc->dt.dt_val == DT_PROC))
				if((p = proc->proc_prof) > 0){
					tot += p;
					proc->proc_prof = -p;
				}
		}
	}
	put1(Snl); put1(Snl);
	if(tot == 0.0){
		putstring("No time accumulated\n");
		return;
	}
        putstring(" #calls   total    call      %  proc\n");
        putstring("           (ms)    (ms)\n\n");
	tot = TO_MSEC(tot);
	for(v = globals; v <= &eglobals; v++){
		int p, f;
		if(DT(*v) == DT_PROC){
			f = T_PROC(*v)->proc_freq;
			p = T_PROC(*v)->proc_prof;
			if(p > 0)
				continue;
			else {
				T_PROC(*v)->proc_prof = -p;
				p = -p;
			}
		} else
		if(DT(*v) == DT_SUBR){
			f = T_SUBR(*v)->subr_freq;
			p = T_SUBR(*v)->subr_prof;
			if(p > 0)
				continue;
			else {
				T_SUBR(*v)->subr_prof = -p;
				p = -p;
			}
		} else
			continue;
		profcall(*v, p, f);
	}
	for(i = 0; i < nsubrs; i++){
		SUMDP w;

		if((p = subrs[i]->subr_prof) > 0)
			continue;
		else {
			subrs[i]->subr_prof = -p;
			p = -p;
		}
		T_SUBR(w) = subrs[i];
                profcall(w, p, subrs[i]->subr_freq);
	}
	for(i = 0; i < nfields; i++){
		struct fldentry *f;
		int j, k;

		for(j = 0; j < nclasses; j++){
			long p;
			struct proc *proc;
			SUMDP w;

			k = fields[i]->fld_switch[j];
			if(k < 0)
				continue;
			f = &fields[i]->fld_entries[k];
			T_PROC(w) = proc = f->fldent_type;
			if((proc != NIL) && (proc->dt.dt_val == DT_PROC) &&
			   ((p = proc->proc_prof) < 0)){
				profcall(w, -p, proc->proc_freq);
				proc->proc_prof = -p;
			}
			T_PROC(w) = proc = f->fldent_fetch;
			if((proc != NIL) && (proc->dt.dt_val == DT_PROC) &&
			   ((p = proc->proc_prof) < 0)){
				profcall(w, -p, proc->proc_freq);
				proc->proc_prof = -p;
			}
			T_PROC(w) = proc = f->fldent_store;
			if((proc != NIL) && (proc->dt.dt_val == DT_PROC) &&
			   ((p = proc->proc_prof) < 0)){
				profcall(w, -p, proc->proc_freq);
				proc->proc_prof = -p;
			}
		}
	}
	profcall(NIL, col_time, ncollect);
	put1(Snl);
	putreal(tot);
	putstring("ms execution time\n");
}
