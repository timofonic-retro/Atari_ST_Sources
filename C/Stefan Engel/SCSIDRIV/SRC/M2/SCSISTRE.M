IMPLEMENTATION MODULE ScsiStreamer;

(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsistre.m,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:34:50 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsistre.m,v $
 * Revision 1.1  1996/02/03  19:34:50  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)


(* Systemabh�ngiges *)
(* IMPLEMENTATION F�R  >>> H�nisch-Modula-2 <<< *)
(*                                              *)
(* Durchgef�hrt von Steffen Engel               *)
(*                                              *)
(*$S-   Stack-Checks                            *)
(*$I-   keine Variablen-Initialisierung         *)
(*$V-   keine arithmetischen Kontrollen         *)
(*$T-   kein Bereichstest                       *)
(*$Y-   keine Laufzeittests auf RETURN und CASE *)
(*                                              *)
(*----------------------------------------------*)


IMPORT SYSTEM, System;
FROM SYSTEM   (* Type  *) IMPORT BYTE, ADDRESS,
              (* Proc  *) ADR, TSIZE;

FROM Portab IMPORT UChar, Char;

(* Standard HM2-Libs *)

(* Eigene Libs *)

(* Projektlibs *)
IMPORT Scsi, ScsiIO;
FROM Scsi IMPORT Cmd6, Cmd10, Cmd12, SetCmd6, SetCmd10, SetCmd12, SetCmd,
          BlockLen, MaxDmaLen, LogicalUnit;






(***************************************************************************)
(*-                                                                       -*)
(*- Sequential Access Devices                                             -*)
(*-                                                                       -*)
(***************************************************************************)

PROCEDURE Read(TransferLen:SHORTCARD;Adr:ADDRESS; Timeout : LONGCARD) : BOOLEAN;




















PROCEDURE ReadNum(VAR TransferLen:SHORTCARD; Adr:ADDRESS; Timeout : LONGCARD) : BOOLEAN;

































PROCEDURE Write(TransferLen:SHORTCARD;Adr:ADDRESS;Timeout : LONGCARD) : BOOLEAN;





















PROCEDURE WriteNum(VAR TransferLen:SHORTCARD;Adr:ADDRESS;Timeout : LONGCARD) : BOOLEAN;































PROCEDURE Erase(TimeoutSeconds : LONGCARD) : BOOLEAN;








PROCEDURE Load(Imed, Ret, Eot, Load:BOOLEAN;

























PROCEDURE WriteFilemark(Imed : BOOLEAN; Number : SHORTCARD; Timeout : LONGCARD) : BOOLEAN;











PROCEDURE Space(Code : SHORTCARD; Count : LONGINT;

















PROCEDURE Rewind(Imed : BOOLEAN; TimeoutSeconds : LONGCARD) : BOOLEAN;











(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Quick File Access                                                     -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE SeekBlock(Imed : BOOLEAN;














PROCEDURE RequestBlockAdr(VAR BlockAdr : LONGCARD) : BOOLEAN;














PROCEDURE Locate(BlockAdresstype : BOOLEAN;

































































PROCEDURE ReadPosition(    BlockAdresstype : BOOLEAN;













































BEGIN

END ScsiStreamer.