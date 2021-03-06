DEFINITION MODULE RealCtrl;

(*
 * Dies Modul dient zur Verwaltung, Unterscheidung und Auswertung
 * der beiden bei Megamax Modula-2 verwendeten Real-Formaten.
 *
 * Beachte:
 *   Das IEEE-Format hat eine gr��ere Genauigkeit durch eine gr��ere
 *   Mantisse, das Megamax-Format �berdeckt einen gr��eren Bereich
 *   durch einen gr��eren Exponenten.
 *)

TYPE AnyRealFormat = (MM2Real, IEEEReal, unspecReal);
     RealFormat    = [MM2Real..IEEEReal];

     AnyReal = RECORD
                 value: LONGREAL;
                 format: RealFormat;
               END;

VAR UsedFormat: AnyRealFormat;
  (*
   * Zeigt an, welches Darstellungsformat z.Zt. f�r Real-Werte
   * verwendet wird. Solange kein Modul resident ist, das Reals
   * benutzt, ist das Format unbestimmt (unspecReal). Ist es
   * einmal bestimmt, weist der Loader Module, die Real-Konstanten
   * im anderen Format enthalten, zur�ck.
   *
   * Keinesfalls darf diese Variable von Anwenderprogrammen, auch nicht
   * kurzzeitig, ver�ndert werden!
   *)

PROCEDURE SmallREAL     (format: RealFormat): LONGREAL;
PROCEDURE LargeREAL     (format: RealFormat): LONGREAL;
PROCEDURE SmallLONGREAL (format: RealFormat): LONGREAL;
PROCEDURE LargeLONGREAL (format: RealFormat): LONGREAL;
  (*
   * Liefern (ungef�hr) gr��te und kleinste positive darstellbare
   * REAL-Werte des angegebenen Formats im selben Format.
   * F�r das aktuelle Format ist 'UsedFormat' anzugeben.
   *
   * Beispiel:
   *   LargeREAL (IEEEReal) liefert die gr��te REAL-Zahl
   * bei IEEE-Darstellung eben in IEEE-Darstellung.
   *)

CONST InfiniteIEEE = 7FF0000000000000R;
      NullIEEE     = 0R;

PROCEDURE Conv (in: AnyReal; out: RealFormat): LONGREAL;
  (*
   * Der Wert 'in' wird ins Format 'out' gewandelt.
   * F�r das aktuelle Format ist 'UsedFormat' anzugeben.
   *
   * Beim Wandeln von IEEE nach MM2 gehen u.U. die untersten Bits
   * der Mantisse verloren, soda� der Wert ungenauer wird.
   * Beim Wandeln von MM2 nach IEEE werden Werte nahe bei Null
   * (Exponent kleiner als -308) zu Null, bei zu gro�en Werten
   * wird die IEEE-Zahl "infinity" (positiv bzw. negativ) geliefert,
   * welche durch Vergleich mit der Konstante 'InfiniteIEEE' (s.o.)
   * erkannt werden kann (Vorzeichen beachten!).
   *
   * Beispiel, um einen Wert immer im IEEE-Format zu erhalten:
   *   ieeeZahl:= Conv (AnyReal {realZahl, UsedFormat}, IEEEForm)
   *)

END RealCtrl.
