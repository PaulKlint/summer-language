/*
 * Squeeze -- provide some dummy declarations.
 *
 * If the SUMMER program has been expanded with the '-S' option,
 * then most of the symbolic information, such as the names
 * of local variables is lost. All 'line' and 'aline' instructions
 * (which trigger the symbolic tracer) are also removed.
 * This module provides dummy declarations to prevent loading
 * of the real tracer routines. This module defines the
 * global symbol 'squeeze' to which the user program has an
 * unsatisfied external reference.
 * Since all symbolic is lost, the profiling option is not usefull
 * and a dummy declaration is included.
 */

int squeeze = 1;	/* forces loading of this module */

tracer(pc) char *pc;{}

tracer_mark(){}

profprint(){}
