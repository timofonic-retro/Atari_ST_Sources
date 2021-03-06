# pml compatible lib for the atari sfp004
#
# Michael Ritzert, Oktober 1990
# ritzert@dfg.dbp.de
#
# FUNCTION:	ASIN(X)
#
# base =	0xfffa50
#      the fpu addresses are taken relative to "base":
comm =	 -6
resp =	-16
zahl =	  0

.text
#LC0:
#	.ascii "asin: DOMAIN error\12\15\0"
	.even
.globl _asin
_asin:
	lea	0xfffa50,a0
	movew	#0x540c,a0@(comm)	| specify function
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@		| load arg_hi
	movel	a7@(8),a0@		| load arg_low
	movew	#0x7400,a0@(comm)	| result to d0
# wait
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	rts
