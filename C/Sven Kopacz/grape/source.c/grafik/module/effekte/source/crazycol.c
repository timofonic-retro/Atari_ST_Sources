#include <stdlib.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "farbsatt.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);

int		global[80];

unsigned int mul77[256], mul151[256], mul28[256];

static MODULE_FN mod_fn=
{
	mod_init,
	mod_quit,
	do_function1,
	do_function2
};

static MODULEBLK mblock=
{
	"GRAPEMODULE",
	'0101',
	/* name */
	"1234567890123456789012345678901",

	/* CICONBLK */
	NULL,NULL,NULL,0,0,0,0,0,0,0,0,0,0,0,NULL,
	/* mask_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* data_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* name */
	0,0,
	/* CICON */
	0,NULL,NULL,NULL,NULL,NULL,
	/* col_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* bw_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	
	0,&mod_fn,
	
	/* Objekt-Tree+Service */
	otree,
	dservice,
	
	/* global */
	NULL,
	/* Grape-Functions */
	NULL,
	/* id */
	0
};

void main(void)
{
	appl_init();
	if(mblock.magic[0])
		form_alert(1,"[3][Ich bin ein Grape-Modul!][Abbruch]");
	appl_exit();
}

void cdecl mod_init(void)
{
	int a;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
	

	for(a=0; a < 256; ++a)
	{
		mul77[a]=a*77;
		mul151[a]=a*151;
		mul28[a]=a*28;
	}
	
	otree[GO].ob_y=(otree[0].ob_height+otree[BAR].ob_y+otree[BAR].ob_height-otree[GO].ob_height)/2;
	otree[SLIDE].ob_x=otree[BAR].ob_width/2-otree[SLIDE].ob_width/2;
	strcpy(otree[SLIDE].ob_spec.tedinfo->te_ptext, "0");
}

void cdecl mod_quit(void)
{
}

void cdecl newval(int now)
{
	itoa(now-128, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, SLIDE);
}

void setval(int val)
{
	_G_ set_slide(_ID_, SLIDE, 0, 255, val);
	itoa(val-128, otree[SLIDE].ob_spec.tedinfo->te_ptext, 10);
	_G_ d_objc_draw(_ID_, BAR);
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case LEFT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== -128)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)-1+128);
			_G_ update_preview();
		break;
		case RIGHT:
			if(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)== 127)
				break;
			setval(atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+1+128);
			_G_ update_preview();
		break;
		case SLIDE:
			_G_ slide(_ID_, SLIDE, 0, 255, atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext)+128, newval);
		break;
		case BAR:
			_G_ bar(_ID_, BAR, 0, 255, newval);
		break;
		case GO:
			_G_ do_me(_ID_);
			_G_ d_unsel(_ID_, GO);
		break;
	}
}

int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm)
{
	int w, h;
	uchar *c, *m, *y;
	
	w=l->word_width;
	h=l->height;
	
	if(mm)
	{
		c=mm->mask;
		m=y=NULL;
	}
	else
	{
		c=l->blue;
		m=l->red;
		y=l->yellow;
	}
	
	if(c||m||y)
	{
		if(!(_G_ undo_buf(area, l, mm, 1)))
				return(0);/* Undo schlug fehl */
		return(do_function2(c,m,y,w,h,area,-1));
	}
	else
		return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	#define cnst (255*77+255*151+255*28)
	register uchar *cc=c, *mm=m, *yy=y, grey;
	register int	ww=area->g_w, cb, cr, satt;
	register long ldif=(long)w-(long)area->g_w;
	register unsigned int *m77=mul77, *m151=mul151, *m28=mul28;
	long start=(long)w*(long)area->g_y+(long)area->g_x;
	register int xc,yc;

	satt=atoi(otree[SLIDE].ob_spec.tedinfo->te_ptext);

	if((!cc)||(!mm)||(!yy)) return(0);	/* Keine Farbs�ttigung f�r Single-Plane */

	cc+=start;
	mm+=start;
	yy+=start;
	
	for(yc=area->g_h; yc > 0; --yc)
	{
		for(xc=ww; xc > 0; --xc)
		{
			/* In YCbCr umrechnen */
			cb=cnst-(m77[*cc]+m151[*mm]+m28[*yy]);
			cb=cb >> 8;
			grey=(unsigned char)cb;
			
			cb=m28[((int)(255-*yy-(int)grey)<<4)];
			cr=((int)(255-*cc-(int)grey)<<4)*11;
			
			cb+=satt; if(cb < 0) cb=0; if(cb > 255) cb=255;
			cr+=satt; if(cr < 0) cr=0; if(cr > 255) cr=255;
			
			*cc++=(uchar)(255-(((cr*22)>>4)+grey));
			*yy++=(uchar)(255-(((cb*28)>>4)+grey));
			*mm++=(uchar)(255-(grey-114*(*(yy-1))/1000-299*(*(cc-1))/1000)*1000/587);

		}
		cc+=ldif;
		mm+=ldif;
		yy+=ldif;
	}

	return(1);
}

