# Makefile for LHArc UNIX
#	Copyright(C) MCMLXXXIX  Yooichi.Tagawa
# V0.01  Alpha Version				1989.05.28  Y.Tagawa
# V0.02  Alpha Version R2			1989.05.29  Y.Tagawa
# V0.03  Release #3  Beta Version		1989.07.02  Y.Tagawa

#-----------------------------------------------------------------------
# DIRECTORY ACCESS DEPENDENDS...
#  The default (no need swtich) is your machine has
#  opendir(),readdir(),closedir() library and 'direct' structure used.
#  If your machine has no opendir (), readdir (), closedir ()
#	-DNONSYSTEM_DIR_LIBRARY
#  and add lhdir.o into OBJS macro (see bellow)
#  If your machine are 'dirent' (not 'direct') structure used,
#	-DSYSV_SYSTEM_DIR
#  Otherwise "Give up!"
#	-DNODIRECTORY
#
#-----------------------------------------------------------------------
# MEMORY ACCESS STUFF
#  Your machine has no BSTRING library (bcmp,bcopy,bzero).
#	-DNOBSTRING
#
#-----------------------------------------------------------------------
# TIME STUFF
#  Your include file '<sys/time.h>' has no 'struct tm',  define this.
#	-DSYSTIME_HAS_NO_TM
#

# most of 4.[23]BSD
#	- vax 4.[23]BSD, SONY NEWS 4.[23]BSD etc.
#SWITCHIES	= -O -fcombine-regs -pg	
#OBJS		= lharc.o lzhuf.o lhio.o

# brain damaged 4.[23]BSD clones (shit like uglix, hpux and other brain death)
#		(dont try -O3 or -O4 on mips-uglix, it blows up the compiler)
#SWITCHIES	= -O -Dultrix
#OBJS		= lharc.o lzhuf.o lhio.o

# sample of System-V
#	- NEC EWS4800
#SWITCHIES	= -DNONSYSTEM_DIR_LIBRARY -DSYSTIME_HAS_NO_TM
#OBJS		= lharc.o lzhuf.o lhio.o lhdir.o

# Atari ST TOS
SWITCHIES	= -DSYSV_SYSTEM_DIR -O -mshort -D__ASM__INSDEL__ \
-fomit-frame-pointer -fforce-mem -fstrength-reduce -fcombine-regs
OBJS		= lharc.o lzhuf.o lhio.o atari.o dirent.o

#
#CC		= gcc
#CFLAGS		= -g -O $(SWITCHIES)
##CC		= cc
##CFLAGS	= -g -p $(SWITCHIES)
##LDFLAGS	= -p
CC		= gcc
CFLAGS		=  $(SWITCHIES)
LDFLAGS		= -mshort -s

TAPEFILES	= READ.ME Makefile lharc.doc \
		  lharc.c lzhuf.c lhdir.c lhdir.h lhio.c lhio.h
DESTDIR		= /usr/new
# DESTDIR		= /usr/local


#	Xlharc is test binary.  Please rename to lharc at install.
#	(see install target)
#all:	xlharc
all:	xlharc.ttp

xlharc.ttp	: $(OBJS)
		$(CC) $(LDFLAGS) -o $@ $(OBJS)

#xlharc	: $(OBJS)
#	$(CC) $(LDFLAGS) -o $@ $(OBJS)

#	For Debugging LzHuff module.
lzhuf	: lzhuf.c
	$(CC) $(CFLAGS) -DSELFMAIN -o $* $*.c

lharc.o lhdir.o	: lhdir.h
lzhuf.o	lhio.o	: lhio.h


clean:
	rm -f core lharc.o lzhuf.o lhdir.o lhio.o lharc.tar lharc.tar.Z

moreclean:
	rm -f core *.o lharc.tar lharc.tar.Z *~ #*

install:
	install -s xlharc $(DESTDIR)/lharc

dist:	lharc.tar.Z

lharc.tar: $(TAPEFILES)
	mkdir dist.lharc
	ln $(TAPEFILES) dist.lharc
	tar cf lharc.tar dist.lharc
	rm -rf dist.lharc

lharc.tar.Z: lharc.tar
	compress <lharc.tar >lharc.tar.Z

distlzh:
	mkdir dist.lharc
	ln $(TAPEFILES) dist.lharc
	lharc c lharc.lzh dist.lharc
	rm -rf dist.lharc

fixstamp:
	touch $(TAPEFILES)
