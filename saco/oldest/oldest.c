/* This command (oldest) accepts some filenames as argument
/* and looks wich one is the oldest. The sequence number of
/* the oldest file is returned, if it couldn't determ wich file
/* the oldest one is the return value is 0.
 */


#include <sys/types.h>
#include <sys/stat.h>

#define ERROR -1
#define TRUE 1
#define FALSE 0


int main(argc,argv)
int argc;
char *argv[];
{ 
	struct
	    { 
		int number;
		time_t mtime;
	} 
	oldest;
	int i = 0;
	struct stat current_buf;
	int first_time = TRUE;

	argc--;
	while (argc-- > 0)
	{ 
		i++;
		if (stat(argv[i],&current_buf) == ERROR)
			exit(0);
		else
			if (current_buf.st_mtime < oldest.mtime || first_time)
			{ 
				oldest.number = i;
				oldest.mtime = current_buf.st_mtime;
				first_time = FALSE;
			}
	}
	exit(oldest.number);
}


