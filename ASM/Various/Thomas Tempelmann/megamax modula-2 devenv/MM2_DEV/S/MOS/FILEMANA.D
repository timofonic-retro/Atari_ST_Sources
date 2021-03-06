DEFINITION MODULE FileManagement;
(*$H+*)

(*  System              : Megamax Modula-2 (MOS 2.0)
 *  Author & Copyright  : Manuel Chakravarty
 *  Vertrieb            : Application Systems Heidelberg
 *  Version             : 1.0                   V#0018
 *)


(*  Dieses Modul stellt Routinen f�r die Dateiverwaltung zur Verf�gung.
 *
 *  In allen auftretenden Listen m�ssen die Listenelemente null-
 *  terminierte Zeichenketten sein, die einen Pfad-/Dateinamen enthalten.
 *
 *  Alle an die Parameter zu �bergebenden Prozeduren d�rfen auch lokal sein!
 *)


FROM Lists      IMPORT List;
FROM Directory  IMPORT DirEntry;
FROM MOSGlobals IMPORT drvA, drvB;


TYPE    (*  Meldet dem Klienten den aktuellen Status (normalerweise die
         *  Anzahl der Dateien, die noch bearbeitet werden m�ssen) und
         *  erlaubt ihm durch zur�ckliefern von 'stop = TRUE' den Vorgang
         *  abzubrechen.
         *)
        FileOpStatusProc    = PROCEDURE (    (*status: *) CARDINAL,
                                         VAR (*stop  : *) BOOLEAN );

        (*  Dient zum Anzeigen einer der in 'MOSGlobals' definierten
         *  Dateifehler.
         *)
        FileErrorAlertProc  = PROCEDURE ( (*errNo: *) INTEGER);


PROCEDURE CountFilesAndDirs (REF path: ARRAY OF CHAR;
                                 l   : List;
                             VAR no  : CARDINAL);

        (*  Ermittelt die Anzahl der Ordner und Dateien, die durch eine
         *  Liste aus Dateinamen bestimmt werden.
         *
         *  Dabei wird vor jeden Namen in der Liste 'l' noch der Pfad
         *  'path' geh�ngt.
         *)

PROCEDURE DeleteFiles (REF path        : ARRAY OF CHAR;
                           files       : List;
                           noFiles     : CARDINAL;
                           showStatus  : FileOpStatusProc;
                           fileErrAlert: FileErrorAlertProc);

        (*  L�sche Dateien und Ordner.
         *
         *  Es werden alle in 'files' angegebenen Dateien und Ordner ge-
         *  l�scht. Soll ein Ordner gel�scht werden, so werden vorher alle
         *  darin enthaltenen Dateien und Ordner gel�scht. Vor jeden Pfad-
         *  namen in 'files' wird noch der Pfad 'path' geh�ngt. Default-Lauf-
         *  werk und Pfad werden nicht ber�cksichtigt.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *    'path'         -- Pfad mit dem alle Dateien beginnen, die
         *                      gel�scht werden sollen. Path mu� mit
         *                      einem Laufwerk beginnen.
         *    'files'        -- Liste aller zu l�schenden Ordner und Da-
         *                      eien. Jedem Listenelement wird noch 'path'
         *                      vorangestellt.
         *    'noFiles'      -- Anzahl der zu l�schenden Ordner und Da-
         *                      teien (kann mit 'CountFilesAndDirs be-
         *                      stimmt werden) oder '0'.
         *    'showStatus'   -- Diese Prozedur wird nach jedem L�schvor-
         *                      gang mit der Anzahl der noch zu l�schen-
         *                      den Dateien aufgerufen und kann den L�sch-
         *                      vorgang durch zur�ckliefern von 'stop =
         *                      TRUE' abbrechen. Damit die Anzahl richtig
         *                      ermittelt werden kann darf 'noFiles' nicht
         *                      mit '0' aufgerufen werden.
         *    'fileErrAlert' -- Diese Prozedur wird beim Auftretten eines
         *                      Dateifehlers mit der entsprechenden Fehler-
         *                      nummer aufgerufen.
         *)


TYPE    (*  Dient dazu dem Klienten zu melden, da� eine Datei gleichen
         *  Namens schon existiert.
         *  Es kann nun in 'name' ein anderer Name geliefert werden oder
         *  das Kopieren dieser einen Datei durch R�ckgabe von 'FALSE'
         *  unterbunden werden.
         *)
        FileExistsAlertProc = PROCEDURE (VAR (*name: *) ARRAY OF CHAR): BOOLEAN;
        
PROCEDURE CopyFiles (REF path        : ARRAY OF CHAR;
                         fileList    : List;
                         noFiles     : CARDINAL;
                     REF newPath     : ARRAY OF CHAR;
                         deleteOld,
                         useAllMem   : BOOLEAN;
                         feAlert     : FileExistsAlertProc;
                         showStatus  : FileOpStatusProc;
                         fileErrAlert: FileErrorAlertProc);

        (*  Kopiere Dateien und Ordner.
         *
         *  Es werden alle in 'files' angegebenen Dateien und Ordner ko-
         *  piert. Wird ein Ordner kopiert, so auch alle darin enthaltenen
         *  Dateien und Ordner. Vor jeden Pfadnamen in 'files' wird noch
         *  der Pfad 'path' geh�ngt. Default-Laufwerk und Pfad werden nicht
         *  ber�cksichtigt.
         *
         *  Eingabeparameter
         *  ----------------
         *
         *    'path'         -- Pfad mit dem alle Dateien beginnen, die
         *                      kopiert werden sollen. Path mu� mit ei-
         *                      nem Laufwerk beginnen.
         *    'fileList'     -- Liste aller zu kopierenden Ordner und Da-
         *                      eien. Jedem Listenelement wird noch 'path'
         *                      vorangestellt.
         *    'noFiles'      -- Anzahl der zu kopierenden Ordner und Da-
         *                      teien (kann mit 'CountFilesAndDirs be-
         *                      stimmt werden) oder '0'.
         *    'newPath'      -- Gibt das Ziel des Kopiervorgangs an.
         *    'deleteOld'    -- Wird in der aktuellen Implementation
         *                      noch nicht ber�cksichtigt. Es sollte
         *                      'FALSE' �bergeben werden.
         *    'useAllMem'    -- Gibt an ob der gesamte freie Speicher als
         *                      Kopierpuffer verwendet werden soll oder
         *                      ob nur rund 2/5 genutzt werden (n�tzlich
         *                      z.B. beim Kopieren in die FlexDisk im
         *                      AUTO-Modus).
         *    'feAlert'      -- Diese Prozedur wird Aufgerufen, sobald
         *                      beim Kopieren eine bereits existierende
         *                      Datei �berschrieben werden w�rde.
         *    'showStatus'   -- Diese Prozedur wird nach jedem vollst�ndi-
         *                      gen Kopieren einer Datei oder eines Ordners
         *                      mit der Anzahl der noch zu kopierenden Da-
         *                      teien aufgerufen und kann den Kopiervor-
         *                      gang durch zur�ckliefern von 'stop = TRUE'
         *                      abbrechen. Damit die Anzahl richtig ermit-
         *                      telt werden kann darf 'noFiles' nicht mit
         *                      '0' aufgerufen werden.
         *    'fileErrAlert' -- Diese Prozedur wird beim Auftreten eines
         *                      Dateifehlers mit der entsprechenden Fehler-
         *                      nummer aufgerufen.
         *
         *  HINWEIS: Wenn viele Dateien mit einem gro�en Kopierpuffer ko-
         *           piert werden kann es eine Zeit dauern, bis 'showStatus'
         *           das erste Mal aufgerufen wird, da dann zuerst sehr
         *           viele Dateien gelesen werden und 'showStatus' erst
         *           nach erfolgreichem Schreiben aufgerufen wird.
         *)

TYPE    FileInfoProc    = PROCEDURE (VAR (*entry: *) DirEntry);

PROCEDURE FileInformation (REF name        : ARRAY OF CHAR;
                               showFileInfo: FileInfoProc;
                               fileErrorAlt: FileErrorAlertProc);

        (*  Ruft die Prozedur 'showFileInfo' mit dem zu 'name' geh�renden
         *  Directory-Eintrag auf. Beim Zur�ckkehren werden alle Ver�nderungen
         *  im Namen und den Attributen aktualisiert.
         *)
         

TYPE    FormatDrive         = [drvA..drvB];
        FormatResult        = (okFR, markedBadFR, failedFR);

PROCEDURE FormatDisk (    drive          : FormatDrive;
                          sides,
                          tracks,
                          sectorsPerTrack,
                          interleave     : CARDINAL;
                      REF name           : ARRAY OF CHAR;
                          showStatus     : FileOpStatusProc;
                      VAR result         : FormatResult);

        (*  Formatiert eine komplette Diskette in Laufwerk A oder B.
         *  Nach dem Formatieren einer jeden Spur wird 'showStatus'
         *  mit einem Wert (0..'tracks') aufgerufen, der angibt wieviel
         *  Spuren der Diskette (auf jeder Seite) noch formatiert wer-
         *  den m�ssen. 'result' liefert das Ergebnis der Operation.
         *
         *  Parameter:
         *      'drive'          - Laufwerk auf dem formatiert werden soll
         *                         (nur A: und B: sind erlaubt)
         *      'sides'          - Zu formatierende Seiten (1..2)
         *      'tracks'         - Anzahl der Spuren auf der Diskette
         *                         (Sinnvoll 80..82)
         *      'sectorsPerTrack'- Anzahl der Sektoren pro Spur (9..11)
         *      'interleave'     - Interleave-Faktor (normalerweise 1)
         *      'name'           - Name der Diskette (bis zu 11 Zeichen
         *                         ohne Punkt)
         *
         *  Da die aktuelle Version keine schadhaften Sektoren makiert,
         *  tritt das Ergebnis 'markedBadFR' nicht auf. Es wird statt-
         *  dessen 'failedFR' geliefert um anzuzeigen, da� die Diskette
         *  nicht benutzt werden sollte.
         *
         *  Anmerkung: Diese Routine formatiert eine Diskette ab Spur
         *             'tracks - 1' (norm. 79) abw�rts. Bricht man den
         *             Vorgang schnell genug ab, so stehen die Chancen
         *             daf�r, da� die wichtigen Daten noch erhalten ge-
         *             blieben sind, gut (Thanks J�rg).
         *
         *  ACHTUNG: Die aktuelle Implementation unterst�tzt nur das
         *           formatieren von ein- oder zweiseitigen Disketten
         *           mit 9 Sektoren und 80 Spuren.
         *)


END FileManagement.
