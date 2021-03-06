DEFINITION MODULE Calls;

(*
 * Funktionen zum Verwenden eines eigenen, definierten Stacks
 * sowie zum Aufrufen/Bereistellen von externen, Modula-fremden,
 * Funktionen.
 *
 * Die ehemaligen Funktionen 'CallSystem' und 'CallExternal' sind
 * nicht mehr vorhanden und m�ssen ggf. durch die entsprechenden
 * Funktionen aus dem Modul SYSTEM ersetzt werden.
 *)

FROM SYSTEM IMPORT LONGWORD, ADDRESS;

FROM MOSGlobals IMPORT MemArea;

FROM SysTypes IMPORT PtrAnyType, AnyType, AnyLongType;


TYPE AddrProc = PROCEDURE ( ADDRESS );


(*$H+  >> erlaubt lokale Prozeduren bei 'CallProc' *)

PROCEDURE CallProc (procedure: AddrProc; data: ADDRESS; REF workSpace: MemArea);
  (*
   * Ruft eine Modula-Funktion mit einem eigens daf�r angelegten Stackbereich
   * auf. Der Stackbereich mu� mind. 512 Byte gro� sein.
   * Zus�tzlich kann ihr in 'data' z.B. ein Pointer auf ein Datenfeld �bergeben
   * werden.
   *
   * Beispiel:
   *
   *   TYPE dataType = RECORD a,b,c: REAL END;
   *
   *   PROCEDURE p1 ( dat0: ADDRESS );
   *     VAR a: ARRAY [1..5000] OF LONGCARD; (* belegt 20000 Bytes des Stacks *)
   *         data: POINTER TO dataType;
   *     BEGIN
   *       data:= dat0;
   *       ...
   *       data^.c:= data^.a DIV data^.b;
   *       ...
   *     END p1;
   *
   *   VAR stck: MemArea; data1, data2: dataType;
   *
   *   BEGIN
   *     stck.length := 25000;
   *     ALLOCATE ( stck.bottom, stck.length ); (* Stack-Bereich reservieren *)
   *     IF stck.bottom = NIL THEN HALT END; (* Programmstop, wenn kein Speicher *)
   *     ...
   *     data1.a:= 8.9; data1.b:= 1.144;
   *     CallProc ( p1, ADR (data1), stck );
   *     ...
   *     data2.a:= 8.9; data2.b:= 1.144;
   *     CallProc ( p1, ADR (data2), stck );
   *     ...
   *)

(*$H+  >> erlaubt lokale Prozeduren bei 'CallSupervisor' *)

PROCEDURE CallSupervisor (proc: AddrProc; data: ADDRESS; REF wsp: MemArea);
  (*
   * Wie 'CallProc', jedoch wird hier die Prozedur 'proc' im Supervisor-
   * modus aufgerufen.
   * 'wsp.length' mu� mindestens 512 sein, da Platz f�r evtl. Interrupts
   * vorhanden sein mu�.
   *)

(*$H-*)

TYPE    Registers = RECORD
          regD0, regD1, regD2, regD3, regD4, regD5, regD6, regD7: AnyLongType;
          regA0, regA1, regA2, regA3, regA4, regA5, regA6       : AnyLongType;
          parm: PtrAnyType;  (* Pointer auf evtl. Daten (SP) *)
        END;

TYPE    RegsProc = PROCEDURE ( VAR Registers );


PROCEDURE NewCaller (     m2Proc       : RegsProc;
                          enterUserMode: BOOLEAN;
                          wsp          : MemArea;
                      VAR entry        : ADDRESS );
  (*
   * Generiert eine Routine, die von externen Funktionen bei 'entry' per
   * 'JSR'-Anweisung angesprungen werden kann (nicht geeignet f�r Exceptions).
   * Sie erzeugt eine Modula-gerechte Umgebung mit Hilfe des Stackbereichs
   * 'wsp', von der dann die Modula-Funktion 'm2Proc' aufgerufen wird.
   *
   * 'm2Proc' bekommt dabei alle Informationen �ber Register und Parameter
   * �bergeben. 'parm' enth�lt den Stack-Pointer, der evtl. auf darauf
   * geladene Parameter zeigt.
   * Wenn 'm2Proc' endet, wird zur aufrufenden Funktion zur�ckgekehrt.
   *
   * 'enterUserMode' mu� FALSE sein, wenn der Aufruf aus dem Usermode erfolgt.
   * Erfolgt der Aufruf im Supervisormode (z.B, wenn die Routine auf einen
   * System- oder Exceptionvektor installiert wird), bestimmt 'enterUserMode',
   * ob die Modula-Funktion auch im Supervisormode (FALSE) oder im Usermode
   * (TRUE) ausgef�hrt werden soll.
   * In jedem Fall zeigt 'Registers.parm' auf die Stackdaten des Aufrufers.
   *
   * 'Registers.parm' darf willk�rlich ver�ndert werden, der Wert wird beim
   * R�cksprung nicht ben�tigt. Alle �brigen Werte des RECORDs werden dagegen
   * beim R�cksprung zur�ckgeladen.
   *
   * Der Stack (wsp.length) sollte mindestens 800 Byte gro� sein.
   *
   * Es mu� beachtet werden, da� bei Beendigung des Programms, das
   * 'NewCaller' aufrief, 'entry' nicht mehr angesprungen werden darf.
   *
   * Wenn nach dem Aufruf 'entry' = NIL ist, konnte die Routine nicht
   * generiert werden, da der vorhandene Speicherplatz nicht ausreichte.
   *
   * Die Hilfsroutine wird im angegebenen Stack-Bereich erzeugt, somit
   * wird kein verz�gernder ALLOCATE-Aufruf mehr get�tigt, wie in fr�heren
   * Versionen.
   *)

PROCEDURE DisposeCaller ( VAR entry: ADDRESS );
  (*
   * Ist nun �berfl�ssig. Diese Funktion ist nur zur Kompatibilit�ts-
   * wahrung noch vorhanden.
   *)

PROCEDURE SysNewCaller ( m2Proc: RegsProc; enterUserMode: BOOLEAN; wsp: MemArea; VAR entry: ADDRESS );
  (*
   * Ist nun �berfl�ssig. Diese Funktion ist nur zur Kompatibilit�ts-
   * wahrung noch vorhanden.
   *)

PROCEDURE CallExtRegs ( procAddr: ADDRESS; VAR regs: Registers );
  (*
   * Ruft eine Funktion an der Adresse 'procAddr' per JSR-Instruktion auf.
   * Alle Register k�nnen frei gew�hlt werden, nach dem Aufruf enth�lt
   * 'regs' wiederum die von der Routine gelieferten Registerwerte.
   * Es ist nicht m�glich, Daten �ber den Stack zu �bergeben.
   * Auch 'regs.parm' wird nicht benutzt!
   * Diese Funktion rettet sicherheitshalber selbst die Register D3-D7
   * und A3-A6.
   *)

END Calls.
