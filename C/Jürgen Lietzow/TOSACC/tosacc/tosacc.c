/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TOSACC.C									*/
/*																		*/
/*																		*/
/*		Author			:	J�rgen Lietzow f�r TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define	__TOSACC

#include "tosglob.h"
#include "tosacc.h"

#define	EXTERN	extern
#define	BYTE	char

#include "tosacc.rh"

/*
#define		DEBUG
*/


SYS		*sys = NULL;
WINDIA	mainWD;					/* WINDIA vom TOSACC-Fenster */

/*	Tool f�r Copyright Meldung */

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );

static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,
								NULL,
								HdlEvent,
							};

/*
*	Liste der Initialisierungsroutinen der Tools
*/

		TINIT	MesInit;		/* Copyright Dialog */
extern	TINIT	XdaInit;		/* Erweiterte Alert- und FormDo-Funktion */
extern	TINIT	ScInit;			/* Bildschirmschoner */
extern	TINIT	KbInit;			/* Tastaturrate */
extern	TINIT	MsInit;			/* Mausbeschleuniger */
extern	TINIT	StInit;			/* Uhr/Wecker */
extern	TINIT	RSInit;			/* RS-232 Konfiguration */
extern	TINIT	PrInit;			/* Drucker Konfiguration */
extern	TINIT	MmInit;			/* Speicher Konfiguration */
extern	TINIT	RdInit;			/* RAM-Disk Konfiguration */
extern	TINIT	SpInit;			/* Spooler Konfiguration */
extern	TINIT	DcInit;			/* Cache Konfiguration */
extern	TINIT	SkInit;			/* Statistik */

static	TOOL	*tools[] = {

			(TOOL *) MesInit,
			(TOOL *) XdaInit,
			(TOOL *) ScInit,
			(TOOL *) KbInit,
			(TOOL *) MsInit,
			(TOOL *) StInit,
			(TOOL *) RSInit,
			(TOOL *) PrInit,
			(TOOL *) MmInit,
			(TOOL *) RdInit,
			(TOOL *) SpInit,
			(TOOL *) DcInit,
			(TOOL *) SkInit

							};

static	int		curTool = 0;			/* Nummer des aktuellen Tools */
static	int		numTools;				/* Anzahl der angemeldeten Tools */
static	int		taccSwitch = 1;			/* TOSACC ein- bzw. ausgeschaltet */

#pragma warn -par		/* window */

/*
*	Redraw()
*
*	Ein Ausschnitt des TOSACC-Fensters restaurieren
*/

static	void	Redraw( const GRECT *gr, int window )
{
	ObjcDraw( TrPtr(TOSACC), 0, 8, gr );
	ObjcDraw( tools[curTool]->wd.tree, 0, 8, gr );
	CursorChg( &tools[curTool]->wd );
}

#pragma warn .par

/*
*	MoveWin()
*
*	TOSACC-Fenster verschieben
*/

static	void	MoveWin( GRECT *gr )
{
	GRECT	temp = *gr;
	OBJECT	*tr = TrPtr(TOSACC);

	MoveObjWin( &temp, &mainWD, WIN_KIND );
	objc_offset( tr, TOOLS, &tools[curTool]->wd.tree->ob_x,
							&tools[curTool]->wd.tree->ob_y );
	InitCurPos( &tools[curTool]->wd );
}

/*
*	CloseTool()
*
*	Dem Tool mitteilen, da� es nicht l�nger aktiv ist
*/

void	CloseTool( int tool )
{
	TOOL	*tl = tools[tool];

	if ( tl->mode )
		tl->mode( tl, MODE_TCLOSE );
}

/*
*	OpenTool()
*
*	Neues Tool anmelden und darstellen
*/

void	OpenTool( int tool, int mode )
{
	TOOL	*tl = tools[tool];
	int		i;
	OBJECT	*ob = tl->wd.tree;

	curTool = tool;
	tl->wd.window = mainWD.window;

	objc_offset( TrPtr(TOSACC), TOOLS, &ob->ob_x, &ob->ob_y );
	if ( tl->mode )
		tl->mode( tl, MODE_TOPEN );

	InitEdObj( &tl->wd, tl->wd.tree, tl->wd.edobj );
	if ( mode )
		RedrawWinObj( &tl->wd, 0, NULL );

	i = curTool * ( 1000 / ( numTools - 1 ) );
	if ( i < 1 )
		i = 1;
	if ( i > 1000 )
		i = 1000;
	wind_set( mainWD.window, WF_VSLIDE, i );
}

/*
*	OpenWin()
*
*	TOSACC-Fenster �ffnen
*/

static	int		OpenWin( void )
{
	OBJECT	*tr = TrPtr(TOSACC);
	int		i;

	if ( mainWD.window > 0 )
		return ( 0 );

	mainWD.window = CreateWin( WIN_KIND );

	if ( mainWD.window < 0 )
	{
		form_alert( 1, "[3][Zu viele Fenster][ OK ]" );
		return ( 1 );
	}

	wind_set( mainWD.window, WF_NAME, " TOS - ACCESSORY     v1.60 " );

	if ( curTool >= numTools )
		curTool = 0;

	i = 1000 / numTools;
	wind_set( mainWD.window, WF_VSLSIZE, i );
	i = curTool * ( 1000 / ( numTools - 1 ) );
	if ( i < 1 )
		i = 1;
	if ( i > 1000 )
		i = 1000;
	wind_set( mainWD.window, WF_VSLIDE, 1 + ( curTool * ( i - 1 ) ) );

	if ( !OpenObjWin( tr, WIN_KIND, mainWD.window ) )
	{
		form_alert( 1, "[3][Kann kein Fenster �ffnen][ OK ]" );
		wind_delete( mainWD.window );
		mainWD.window = -1;
		return ( 1 );
	}

	objc_offset( tr, TOOLS, &tools[curTool]->wd.tree->ob_x,
				 &tools[curTool]->wd.tree->ob_y );

	return ( 0 );
}

/*
*	CloseWin()
*
*	TOSACC-Fenster schlie�en
*/

static	void	CloseWin( void )
{
	CloseTool( curTool );
	wind_close( mainWD.window );
	wind_delete( mainWD.window );
	mainWD.window = -1;
}

/*
*	NewTool()
*
*	Aktuelles Tool wechseln
*/

void	NewTool( int tool )
{
	if ( tool < 0 || tool >= numTools || tool == curTool )
		return;

	CloseTool( curTool );
	OpenTool( tool, 1 );
}

/*
*	ArrowWin()
*
*	Message-Event 'WM_ARROWED' auswerten und evtl. neues Tool aktivieren
*/

void	ArrowWin( int pos )
{
	switch ( pos )
	{
		case	0:
		case	2:	if ( curTool )
						NewTool( curTool - 1 );
					break;
		case	1:
		case	3:	if ( curTool < numTools - 1 )
						NewTool( curTool + 1 );
		default	 :	break;
	}
}

/*
*	VSlideWin()
*
*	Message-Event 'WM_VSLID' auswerten
*	Anhand der Sliderposition ein neues Tool aktivieren
*/

void	VSlideWin( int pos )
{
	int		i = pos / ( 1000 / numTools );

	if ( i >= numTools )
		i = numTools - 1;

	NewTool( i );
}

/*
*	ToolEvent()
*
*	Ein fensterspezifisches Ereignis, das sich nicht auf das
*	TOSACC-Fenster bezieht an die angemeldeten Tools weitergeben
*/

void	ToolEvent( EVENT *ev, int evtype, int window )
{
	TOOL	**tl = tools;
	int		i;

	for ( i = numTools + 1; --i; tl++ )
		if ( tl[0]->wd.window == window )
		{
			if ( tl[0]->event )
				tl[0]->event( tl[0], evtype, ev, window );
			break;
		}
}

/*
*	CallTimers()
*
*	An alle Tools eine Timer-Message schicken (jede Sekunde)
*/

void	CallTimers( int type )
{
	int		i;
	TOOL	**tl = tools;

	for ( i = 0; i < numTools; i++, tl++ )
		if ( (*tl)->mode )
			if ( curTool == i )
			{
				if ( (*tl)->mode( *tl, type | MODE_TACTIV ) )
					FormDial( FMD_FINISH, NULL, NULL );
			}
			else
				(*tl)->mode( *tl, type );
}

/*
*	HandleMessage()
*
*	Das Message-Event auswerten
*/

static	int		HandleMessage( EVENT *ev )
{
	int		*buf = ev->ev_mmgpbuf;

	if ( !taccSwitch )
	{
		if ( buf[4] == gemv.menuId  && buf[0] == AC_OPEN )
			form_alert( 1, "[1][TOS-Accessory ist au�er|"
						   "Dienst !][ OK ]" );
		return( 0 );
	}
	switch ( buf[0] )
	{
		case WM_REDRAW :	if ( buf[3] == mainWD.window )
								RedrawWin( (const GRECT *) &buf[4],
										   mainWD.window, Redraw );
							else
								ToolEvent( ev, MU_MESAG, buf[3] );
							break;
		case WM_TOPPED :	wind_set( buf[3], WF_TOP );
							CallTimers( MODE_TOPPED );
							break;
		case WM_CLOSED :	if ( buf[3] == mainWD.window )
							{
								CloseWin();
								return ( 1 );
							}
							else
								ToolEvent( ev, MU_MESAG, buf[3] );
							break;
		case WM_ARROWED :	if ( buf[3] == mainWD.window )
								ArrowWin( buf[4] );
							else
								ToolEvent( ev, MU_MESAG, buf[3] );
							break;
		case WM_VSLID :		if ( buf[3] == mainWD.window )
								VSlideWin( buf[4] );
							else
								ToolEvent( ev, MU_MESAG, buf[3] );
							break;
		case WM_MOVED :		if ( buf[3] == mainWD.window )
								MoveWin( (GRECT *) &buf[4] );
							else
								ToolEvent( ev, MU_MESAG, buf[3] );
							break;
		case AC_OPEN :		if ( buf[4] == gemv.menuId  )
								if ( mainWD.window >= 0 )
								{
									wind_set( mainWD.window, WF_TOP );
									break;
								}
								else
								{
									if ( OpenWin() )
										return( 0 );
									OpenTool( curTool, 0 );
								}
							break;
		case AC_CLOSE :		if ( buf[3] == gemv.menuId )
							{
								if ( mainWD.window >= 0 )
									CloseTool( curTool );
								mainWD.window = -1;
								CallTimers( MODE_ACCCLOSE );
							}
							return( 0 );
		default:			ToolEvent( ev, MU_MESAG, buf[3] );
							break;
	}
	return ( 0 );
}


/*
*	SaveAll()
*
*	Konfiguration sichern (auch die der Tools)
*/

void	SaveAll( void )
{
	FILE	*fp;
	TOOL	**tl = tools;
	int		i;
	DTA		*dta_sav, dta;

	dta_sav = Fgetdta();
	Fsetdta( &dta );
	
	Select( ObPtr(TOSACC,SAVE) );
	RedrawWinObj( &mainWD, SAVE, NULL );

	fp = fopen( sys->saveFile, "wb" );

	if ( !fp )
	{
		form_alert( 1, "[1][Datei Schreibfehler][ OK ]" );
		Fsetdta( dta_sav );
		Deselect( ObPtr(TOSACC,SAVE) );
		RedrawWinObj( &mainWD, SAVE, NULL );
		return;
	}

	if ( fwrite( &(sys->tai), sizeof (TACC_INF), 1L, fp ) != 1L )
	{
		fclose( fp );
		fp = NULL;
	}
	for ( i = numTools + 1; --i; tl++ )
	{
		if ( tl[0]->save )
			tl[0]->save( tl[0], fp );
		if ( errno )
			break;
	}
	
	if ( fp )
		fclose( fp );

	Deselect( ObPtr(TOSACC,SAVE) );
	RedrawWinObj( &mainWD, SAVE, NULL );
	Fsetdta( dta_sav );
}

/*
*	EventLoop()
*
*	Event-Behandlungsroutine
*	egal ob das TOSACC-Fenster ge�ffnet oder geschlossen ist
*/

void	EventLoop( void )
{
	static	EVENT	ev = {	MU_MESAG | MU_TIMER | MU_KEYBD | MU_BUTTON,
							2, 0x1, 1,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							1000, 0,
							0, 0, 0, 0, 0, 0,
							{ 0 }
						 };
	int		evtype;
	int		key;
	int		top;

	if ( _app )
	{
		if ( OpenWin() )
			return;
		OpenTool( curTool, 0 );
	}

	do
	{
		evtype = EventMulti( &ev );
		wind_update( BEG_UPDATE );
		wind_get( 0, WF_TOP, &top );

		if ( evtype & MU_KEYBD )
		{
			if ( taccSwitch )
				if ( top == mainWD.window )
				{
					key = ev.ev_mkreturn;
					if ( ev.ev_mmokstate == CONTROL )
					{
						if ( key == CNTRL_S )
							SaveAll();
						else if ( key == CNTRL_U )
						{
							CloseWin();
							if ( _app )
								break;
						}
						else if ( (key & 0xff00) == (C_UP & 0xff00) )
							NewTool( curTool - 1 );
						else if ( (key & 0xff00) == (C_DOWN & 0xff00) )
							NewTool( curTool + 1 );
					}
					else
						tools[curTool]->event( tools[curTool], MU_KEYBD,
												&ev, top );
				}
				else
					ToolEvent( &ev, MU_KEYBD, top );
		}
		if ( evtype & MU_BUTTON )
		{
			if ( taccSwitch )
				if ( top == mainWD.window )
				{
					key = objc_find( TrPtr(TOSACC), 0, 8, ev.ev_mmox, ev.ev_mmoy );
					switch ( key )
					{
						case TOOLS:
							tools[curTool]->event( tools[curTool], MU_BUTTON,
													&ev, top );
									break;
						case SAVE:	SaveAll();
									break;
						default:	Bell();
									break;
					}
				}
				else
					ToolEvent( &ev, MU_KEYBD, top );
		}
		if ( evtype & MU_TIMER )
		{
			if ( taccSwitch )
				CallTimers( MODE_TIMER );
		}
		if ( evtype & MU_MESAG )
			if ( HandleMessage( &ev ) && _app )
				break;
		if ( taccSwitch && ( evtype &= ~(MU_MESAG|MU_TIMER|MU_KEYBD|MU_BUTTON) ) )
			ToolEvent( &ev, evtype, top );

		wind_update( END_UPDATE );

	} while ( 1 );
	wind_update( END_UPDATE );
}

static	void	Exit( void )
{
	int		i;
	TOOL	**tl = tools;

	if ( taccSwitch )
	{
		for ( i = numTools + 1; --i; tl++ )
		{
			if ( tl[0]->exit )
				tl[0]->exit( tl[0] );
		}
	}
}	

/*
*	InitFirst()
*
*	�berpr�ft, ob >>AUTOTACC<< installiert ist, und ob es
*	�berhaupt Sinn macht, das Accessory anzumelden
*/

static	int	InitFirst( void )
{
	long	*cok;

	if ( ( cok = GetCookie( (long) 'TAcc' ) ) != NULL )
	{
		sys = (SYS *) cok[1];
		if ( strcmp( VERSION, sys->tai.version) )
		{
			form_alert( 1, "[1][Falsche Version|von AUTOTACC.PRG][OK]" );
			return ( 1 );
		}
	}
	else
	{
		form_alert( 1, "[1][AUTOTACC.PRG ist nicht|installiert !][OK]" );
		return ( 1 );
	}
	if ( ( MaxX + 1 ) / _Cw < 40 || ( MaxY + 1 ) / _Ch < 25 )
	{
		form_alert( 1, "[1][TOS-Accessory-Konfiguration|"
					   "in dieser Aufl�sung nicht|"
					   "m�glich][OK]" );
		return ( 1 );
	}

	return ( 0 );
}

/*
*	Init()
*
*	Installation der Tools
*	wird nur einmal bei Programmstart aufgerufen
*/

static	void	Init( void )
{
	int		i;
	TOOL	**tl = tools;
	FILE	*fp;
	OBJECT	*tr;
	int		num;
	char	vers[sizeof(VERSION)];

	if ( ( fp = fopen( sys->saveFile, "rb" ) ) != NULL )
	{
		if ( fread( vers, sizeof (VERSION), 1L, fp ) != 1L
			 || strcmp( vers, VERSION ) )
		{
			fclose( fp );
			remove( sys->saveFile );
			fp = NULL;
		}
		if ( fp && fseek( fp, sizeof (TACC_INF), SEEK_SET ) )
		{
			fclose( fp );
			fp = NULL;
		}
	}
	
	numTools = (int) (sizeof(tools) / sizeof(TOOL *));

	tr = TrPtr(TOSACC);
	tr->ob_x = 0;
	mainWD.window = -1;
	InitEdObj( &mainWD, TrPtr(TOSACC), -1 );

	errno = 0;
	num = 0;
	
	if ( taccSwitch )
	{
		for ( i = 0; i < numTools; i++ )
		{
			tl[num] = ((TINIT *)tl[i])( fp, num );
			if ( tl[num] )
				num++;
			if ( errno )
			{
				errno = 0;
				if ( fp )
				{
					fclose ( fp );
					fp = NULL;
				}
			}
		}
		numTools = num;
	}
	sys->confActiv = 1;
	if ( fp )
		fclose( fp );
}

/*
*	main()
*
*	Applikation anmelden
*	Men�eintrag f�r Accessory
*	Tools installieren
*/

int		main( void )
{
	if ( !OpenGEM() )
	{
		if ( rsrc_load( RESOURCE_FILE ) )
		{
			if ( !InitFirst() )
			{
				if ( !_app )
					gemv.menuId = menu_register( gemv.applId, "  TOS ACCESSORY  " );
				OpenXGEM();
				FixImages( TrPtr(0), NUM_OBS );
	
				if ( _app || gemv.menuId != -1 )
				{
					Init();
					EventLoop();
					Exit();
				}
				else
					form_alert( 1, "[1][Keine freien|"
								"Accessory-Eintr�ge][ OK ]" );
			}
			rsrc_free();
		}
		else
			form_alert( 1,	"[1][Resource-Datei|nicht gefunden]"
							"[ OK ]" );
		CloseGEM();
	}
	else
		fprintf( stderr, "Es konnte keine Applikation"
						 "angemeldet werden\n" );
	return ( 0 );
}

/*
*	Funktionen des ersten Tools (Copyright-Meldung)
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	return ( 0 );
}


TOOL	*MesInit( FILE *fp, int handle )
{
	InitEdObj( &ourTool.wd, TrPtr(MESSAGE), -1 );
	return ( &ourTool );
}

#pragma warn .par
