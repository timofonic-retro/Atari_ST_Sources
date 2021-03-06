IMPLEMENTATION MODULE VDIRasters;
(*$L-, N+, Y+*)


(*  MEGAMAX MODULA 2 GEM-Library :  Die VDI Rasterfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  04.11.87
 *
 *  Version   2.2     V#0019
 *)
 
(*  04.11.87    | �bernahme aus 'GEMBase' und 'GEMExt'
 *  02.04.90    | Anpassung an public arrays
 *  20.11.91    | PixelState geht nun ('set' wurde auf Stack vergessen)
 *)


FROM    SYSTEM          IMPORT ASSEMBLER;
 
FROM    GrafBase        IMPORT Point, Rectangle, MemFormDef, PtrMemFormDef,
                               WritingMode, BitOperation;

IMPORT  GEMShare;
 
FROM    GEMEnv          IMPORT DeviceHandle;

(*$I GEMOPS.ICL *)
 
 
PROCEDURE CopyOpaque(handle:DeviceHandle; sourceMem,destMem:PtrMemFormDef;
                     sourceFrame,destFrame:Rectangle;mode:BitOperation);
                    
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.W      -(A3),pubArrays.vINTIN(A0)      ; 'mode' -> vINTIN(0)
    LEA         pubArrays.PTSIN+$10(A0),A1     ; frames -> ptsin(0)-(7)
    JSR         getCalcedFrame
    JSR         getCalcedFrame
    MOVE.L      our_cb,A0
    MOVE.L      -(A3),cb.V_CONTRL.multi3(A0)    ; ADR(destMem) -> V_CONTRL.m3
    MOVE.L      -(A3),cb.V_CONTRL.multi1(A0)    ; ADR(sourceMem) -> V_CONTRL.m1
    MOVE.W      #COPY_RASTER_OPAQUE,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END CopyOpaque;

PROCEDURE CopyTrans(handle:DeviceHandle;sourceMem,destMem:PtrMemFormDef;
                    sourceFrame,destFrame:Rectangle;mode:WritingMode;
                    setCol,unsetCol:CARDINAL);
                    
BEGIN
  ASSEMBLER
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.vINTIN+2(A0)    ; setCol, unsetCol -> vINTIN(1)+(2)
    MOVE.W      -(A3),D0
    ADDQ.W      #1,D0
    MOVE.W      D0,pubArrays.vINTIN(A0)         ; adjusted 'mode' -> vINTIN(0)
    LEA         pubArrays.PTSIN+$10(A0),A1     ; frames -> ptsin(0)-(7)
    JSR         getCalcedFrame
    JSR         getCalcedFrame
    MOVE.L      our_cb,A0
    MOVE.L      -(A3),cb.V_CONTRL.multi3(A0)    ; ADR(destMem) -> V_CONTRL.m3
    MOVE.L      -(A3),cb.V_CONTRL.multi1(A0)    ; ADR(sourceMem) -> V_CONTRL.m1
    MOVE.W      #COPY_RASTER_TRANSP,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END CopyTrans;

PROCEDURE TransformForm(handle:DeviceHandle;VAR sourceMem,destMem:MemFormDef);

BEGIN
  ASSEMBLER
    MOVE.L      our_cb,A0
    MOVE.L      -(A3),cb.V_CONTRL.multi3(A0)    ; ADR(destMem) -> V_CONTRL.m3
    MOVE.L      -(A3),cb.V_CONTRL.multi1(A0)    ; ADR(sourceMem) -> V_CONTRL.m1
    MOVE.W      #TRANSFORM_FORM,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
  END;
END TransformForm;

PROCEDURE PixelState (handle:DeviceHandle; toTest:Point;
                      VAR color:CARDINAL; VAR set:BOOLEAN);
                     
BEGIN
  ASSEMBLER
    MOVE.L      -(A3),-(A7)             ; save ADR(set)
    MOVE.L      -(A3),-(A7)             ; save ADR(color)
    MOVE.L      pubs,A0
    MOVE.L      -(A3),pubArrays.PTSIN(A0)      ; 'toTest' -> ptsin(0)+(1)
    MOVE.W      #GET_PIXEL,(A3)+
    CLR.W       (A3)+
    JSR         vdi_if
    MOVE.L      pubs,A0
    MOVE.L      (A7)+,A1                ; restore ADR(color) -> A1
    MOVE.L      (A7)+,A2                ; restore ADR(set) -> A2
    TST.W       pubArrays.vINTOUT(A0)
    SNE         D0
    ANDI        #1,D0
    MOVE        D0,(A2)                     ; intout(0) -> set (set/unset)
    MOVE.W      pubArrays.vINTOUT+2(A0),(A1) ; intout(1) -> color
  END;
END PixelState;

END VDIRasters. 
(* $FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$000004C9$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E$FFF8B68E�$00000182T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000C7D$FFEAED2A$FFEAED2A$00000CC6$FFEAED2A$FFEAED2A$FFEAED2A$FFEAED2A$FFEAED2A$FFEAED2A$FFEAED2A$00000C8F$00000CD9$FFEAED2A$00000CDD$00000182���*)
