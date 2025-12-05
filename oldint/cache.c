#
/*
 * SUMMER -- cache operations
 */

#include "summer.h"


/*
 * save_in_cache checks whether the pair (base, off) is already in
 * the current cache.
 * If not, add (base, off) and base[off] to the cache.
 * The cache entry for the (base, off) is returned.
 * Work to be done here:
 * - change second par into pointer to old value.
 * - require that old and new value are legal SUMMER objects.
 *   (this violated for file and bits objects, and in the case
 *    save_in_cache is called with "globals" as first argument.)
 */
struct cache *save_in_cache(abase, aoff)
SUMDP abase; int aoff;{
	register struct cache *c;
	register SUMDP base;
	register int off;
	extern SUMDP globals[];

	base = abase;
	off = aoff;

	for(c = curcache->cd_base; c < cachetop; c++)
		if((T_DATATYPE(c->val_base) == T_DATATYPE(abase)) && 
		   (c->val_off == off))
			return(c);
	if(cachetop == &cachemem[NCACHE])
		error("cache overflow");
	c->val_base = abase;
	c->val_off = off;
	c->val_old = (CAST(SUMDP *) T_DATATYPE(base))[off];
/*
	if(!legal(c->val_old) && (T_DATATYPE(c->val_old) != NIL)
		&& (DT(base) != DT_BITS))
		syserror("save_in_cache: old");
*/
	cachetop++;
	return(c);
}

legal(s)
SUMDP s;{
	return((DT(s) >= 0) && (DT(s) < nclasses));
}

/*
 * rest_from_cache restores all (base, off) pairs which are
 * contained in the current cache.
 * Values are restored in reverse order to catch the case that
 * a (base, off) pair occurs more than once in the cache.
 * This can happen when to caches are merged (OLDRC) and
 * duplicate pairs are not removed.
 * Reverse restoration ensures that the oldest value
 * is restored last.
 */

rest_from_cache(){
	register struct cache *c;
	extern BITS F_Bupdate();

	for(c = cachetop - 1; c >= curcache->cd_base; c--)
		if(DT(c->val_base) == DT_FILE)
			rest_file(c);
		else
		if(DT(c->val_base) == DT_BITS){
			register INTEGER intoff = newinteger(c->val_off);
			call(3, F_Bupdate, c->val_base, intoff, c->val_old);
		} else
			(CAST(SUMDP *) T_DATATYPE(c->val_base))[c->val_off] = c->val_old;
	cachetop = curcache->cd_base;
	scan_restore();
}
