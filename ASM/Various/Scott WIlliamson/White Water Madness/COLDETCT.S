; WWM SHIP COLISION DETECTION ROUTINES                  7/25

;       ***** SHIP COLLISION DETECTION *****
COLDETCT:
        LEA     MAP,A0          ; COLLISION DETECTION
        MOVE    SHIPX,D0        ; ((SHIPX+8)/16)*2
        ADD     #8,D0
        AND     #$FFF0,D0
        LSR     #3,D0
        ADD     D0,A0
        MOVE    SHIPY,D0        ; ((SHIPY+8)/16)*MAPW*2
        ADD     #8,D0
        LSR     #4,D0
        MULU    #MAPW*2,D0
        ADD.L   D0,A0           ; A0 POINTS TO CHR NEEDED

        MOVE    (A0),D0         ; FETCH CHR
        MOVE.B  D0,SCORE        ; DISP CHR IN SCORE BOX

        CMP     #$17A,D0         ; WARP?
        BEQ     WARP
        CMP     #237,D0         ; SHORE HIT!
        BLT     NOTX3
        SUBQ    #4,LIFE
        CLR     SNDDMAC         ; YES - FIRE!
        MOVE    #1,SNDDMAC
; PUT SHIP BACK IN WATER
        CMP     #237,(MAPW*2)(A0)       ; DOWN
        BGE     NOWATER0
        ADDQ    #IMPACT,SHIPY
        BRA     DONECOLLISION
NOWATER0:
        CMP     #237,(-2)(A0)           ; LEFT
        BGE     NOWATER1
        SUBQ    #IMPACT,SHIPX
        BRA     DONECOLLISION
NOWATER1:
        CMP     #237,(2)(A0)            ; RIGHT
        BGE     NOWATER2
        ADDQ    #IMPACT,SHIPX
        BRA     DONECOLLISION
NOWATER2:
        CMP     #237,(-MAPW*2)(A0)      ; UP
        BGE     NOWATER3
        SUBQ    #IMPACT,SHIPY
        BRA     DONECOLLISION
NOWATER3:
        CMP     #237,(MAPW*2-2)(A0)     ; DOWN LEFT
        BGE     NOWATER4
        SUBQ    #IMPACT,SHIPX
        ADDQ    #IMPACT,SHIPY
        BRA     DONECOLLISION
NOWATER4:
        CMP     #237,(MAPW*2+2)(A0)     ; DOWN RIGHT
        BGE     NOWATER5
        ADDQ    #IMPACT,SHIPX
        ADDQ    #IMPACT,SHIPY
        BRA     DONECOLLISION
NOWATER5:
        CMP     #237,(-MAPW*2-2)(A0)    ; UP LEFT
        BGE     NOWATER6
        SUBQ    #IMPACT,SHIPX
        SUBQ    #IMPACT,SHIPY
        BRA     DONECOLLISION
NOWATER6:
        ADDQ    #IMPACT,SHIPX   ; PUSH UP RIGHT
        SUBQ    #IMPACT,SHIPY
        BRA     DONECOLLISION

NOTX3:
        CMP     #230,D0
        BLT     NOTX2
        SUBQ    #3,LIFE
        CLR     SNDDMAC         ; YES - FIRE!
        MOVE    #1,SNDDMAC
        BRA     DONECOLLISION
NOTX2:
        CMP     #207,D0
        BLT     NOTX1
        SUBQ    #2,LIFE
        CLR     SNDDMAC         ; YES - FIRE!
        MOVE    #1,SNDDMAC
        BRA     DONECOLLISION
NOTX1:
        CMP     #186,D0
        BLT     NOTX0
        SUBQ    #1,LIFE
        CLR     SNDDMAC         ; YES - FIRE!
        MOVE    #1,SNDDMAC
        BRA     DONECOLLISION
NOTX0:

        CMP     #157,D0
        BLT     NOTLEFT
        SUBQ    #RAPIDSP,WINDX
        SUBQ    #RAPIDSP,SHIPX
NOTLEFT:
        CMP     #178,D0
        BGT     NOTDOWN
        CMP     #63,D0
        BLT     NOTDOWN
        ADDQ    #RAPIDSP,WINDY
        ADDQ    #RAPIDSP,SHIPY
NOTDOWN:
        CMP     #86,D0
        BGT     NOTRIGHT
        CMP     #29,D0
        BLT     NOTRIGHT
        ADDQ    #RAPIDSP,WINDX
        ADDQ    #RAPIDSP,SHIPX
NOTRIGHT:
        CMP     #181,D0
        BGT     CURRENTUP
        CMP     #32,D0
        BGT     NOTUP
        CMP     #26,D0
        BLT     NOTUP
CURRENTUP:
        SUBQ    #RAPIDSP,WINDY
        SUBQ    #RAPIDSP,SHIPY
NOTUP:
DONECOLLISION:
        RTS
        END
 