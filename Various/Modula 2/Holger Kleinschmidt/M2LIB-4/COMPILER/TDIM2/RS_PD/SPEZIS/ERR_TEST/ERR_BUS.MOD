(*$S-,$T-,$Q+,$U+*)
MODULE Err_Bus;
(* � 1996 by RS. * 8.3.96 *)                    (* Bus kludge: No hardware.*)

FROM SYSTEM IMPORT ADDRESS;
VAR   a: ADDRESS; p: POINTER TO INTEGER; i: INTEGER;
BEGIN a := 00000; p := a; i := p^ END Err_Bus.
