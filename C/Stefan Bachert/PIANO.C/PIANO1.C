
/*  EXAMPLE application for ACS    */

/*  "Piano"                        */

/* Phase 1                         */

/*  14.1.92         Stefan Bachert */

/*(c) 1992 MAXON Computer GmbH     */


#include <tos.h>
#include    <acs.h>
#include    <piano1.h>

/* lay down Prototypes */

static void ton (void);
static Awindow *piano_make (void *not_used);

#include    <piano1.ah>

/* Sound generator ansteuern */
static char sound [] = {
 0x00, 0x10,    /* Set Generator A Frequency */
 0x01, 0x10,
 0x07, 0xf8,    /* Switch rush off          */
 0x0b, 0x00,    /* Tone length sleeve curve */
 0x0c, 0x30,
 0x08, 0x17,    /* Volume                   */
 0x0d, 0x00,    /* Sleeve curve fade        */
 0xff, 0x00     /* stop                     */
 };

static void ton (void)
 
 /* tone of the Frequency carried out (userp1) / 1000 sounds */


{
  AOBJECT *aob;
  long val;

  aob = (AOBJECT *) ev_object + ev_obnr + 1;
  val = 125000000L / (long) aob-> userp1; /* calculate part value */

  sound [1] = (char) val;               /* lower Byte        */
  sound [3] = (char) (val >> 8) & 0x0f; /* upper (Half) Byte */

  Dosound (sound);
}

static Awindow *piano_make (void *not_used)
    
    /*  Generate Piano Window */
     */
{
  Awindow *wi;

  wi = Awi_create (&PIANO);
  if (wi == NULL) return NULL;

  (wi-> open) (wi);                 /* open similiar */

  return wi;
}


int ACSinit (void)
    
    /*  Double click on NEW produces a new Window */

{
  Awindow *window;

  window = Awi_root ();                 /* root window */

  if (window == NULL) return FAIL;      /* set down NEW Icon */
  (window-> service) (window, AS_NEWCALL, &PIANO. create);

  window = &PIANO;
  (window-> create) (NULL);             /* Generate a Window immediately */

  return OK;
}
