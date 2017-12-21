; ALLOWS ONE TO START THE APPLICATION WITH RUN
; SYS 2064
*=$0801 
         BYTE $0C, $8, $0A, $00, $9E, $20, $32, $30, $36, $34, $00, $00, $00, $00, $00

; MEMORY POINTERS
IRQFLAG    = $D019
IRQCTRL    = $D01A
IRQADDRMSB = $0314
IRQADDRLSB = $0315
IRQRASTER  = $D012
CIA1IRQ    = $DC0D
RASTERREG  = $D011

SPR_ENABLE      = $D015 ; FLAGS FOR SPRITE ENABLING
SPR_MSBX        = $D010 ; FLAGS TO REPRESENT X VALUES LARGER THAN 255
SPR_COLORMODE   = $D01C ; FLAGS TO SET COLOR MODES (0 = HIGH RES/2-COLOR, 1 = MULTICOLOR/4-COLOR)
SPR_COLOR0      = $D025 ; SHARED SPRITE COLOR 0
SPR_COLOR1      = $D026 ; SHARED SPRITE COLOR 1

SPR0_PTR        = $07F8 ; SPRITE 0 DATA POINTER
SPR0_ADDR       = #$0D  ; SPRITE 0 POINTER VALUE
SPR0_DATA       = $0340 ; SPRITE 0 DATA ADDRESS (POINTER VALUE * $40)
SPR0_X          = $D000 ; SPRITE 0 X COORDINATE
SPR0_Y          = $D001 ; SPRITE 0 Y COORDINATE
SPR0_COLOR      = $D027 ; SPRITE 0 COLOR

; KERNAL ROUTINES
IRQCONTINUE     = $EA81
IRQFINISH       = $EA31


; TODO HERE BE SPRITES
; SCREEN WILL BE DIVIDED 3 VERTICAL PORTIONS, AND EACH OF THEM WILL DISPLAY SPRITES

INIT    
        LDA #%01111111 ; SWITCH OFF CIA-1 INTERRUPTS
        STA CIA1IRQ

        AND $D011 ; CLEAR VIC RASTER REGISTER
        STA RASTERREG

        LDA #0 ; START WITH IRQ0 AT RASTER LINE 0
        STA IRQRASTER
        LDA #<IRQ0
        STA IRQADDRMSB
        LDA #>IRQ0
        STA IRQADDRLSB

        ; SPRITES

        ; ENABLE SPRITES
        LDA #%11111111
        STA SPR_ENABLE

        ; SET COLOR MODES
        LDA #%11111111
        STA SPR_COLORMODE
        
        ; SET SPRITE SHARED COLORS
        LDA #0
        STA SPR_COLOR0
   
        ; SET SPRITE X
        LDX #%11110000
        STX SPR_MSBX
        LDX #0
        STX $D000
        LDX #64
        STX $D002
        LDX #128
        STX $D004
        LDX #192
        STX $D006
        LDX #0
        STX $D008
        LDX #64
        STX $D00A
        LDX #128
        STX $D00C
        LDX #192
        STX $D00E
        
        ; SET SPRITE POINTERS
        LDA #$F8
        STA $FA
        LDA #$07
        STA $FB
        LDA SPR0_ADDR
        LDY #0
SETPTRS STA ($FA),Y
        INY
        CPY #16
        BNE SETPTRS

        ; LOAD SPRITE DATA
        LDX #0
LDSPR1  LDA SPRDATA,X
        STA SPR0_DATA,X
        INX
        CPX #64
        BNE LDSPR1

        LDA #%00000001 ; ENABLE RASTER INTERRUPTS ONLY AFTER SETUP
        STA IRQCTRL

MAIN    
        JMP MAIN

IRQ0    
        ; SET Y COORDINATES
        LDA #$01
        STA $FA
        LDA #$D0
        STA $FB
        LDY #0
        LDA #80
SETY1   STA ($FA),Y
        INY
        INY
        CPY #16
        BNE SETY1

        ; SET COLORS
        LDA #$27
        STA $FA
        LDA #$D0
        STA $FB
        LDY #0
        LDA #5
        STA $FC
SETCLR1 LDA $FC
        STA ($FA),Y
        INY
        INC $FC
        CPY #8
        BNE SETCLR1

        ; MOVE SPRITES
        DEC $D000
        LDX $D000
        CPX #255
        BNE NEXT0
        LDA #%00000001
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT0
        DEC $D002
        LDX $D002
        CPX #255
        BNE NEXT1
        LDA #%00000010
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT1
        DEC $D004
        LDX $D004
        CPX #255
        BNE NEXT2
        LDA #%00000100
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT2
        DEC $D006
        LDX $D006
        CPX #255
        BNE NEXT3
        LDA #%00001000
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT3
        DEC $D008
        LDX $D008
        CPX #255
        BNE NEXT4
        LDA #%00010000
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT4
        DEC $D00A
        LDX $D00A
        CPX #255
        BNE NEXT5
        LDA #%00100000
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT5
        DEC $D00C
        LDX $D00C
        CPX #255
        BNE NEXT6
        LDA #%01000000
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT6
        DEC $D00E
        LDX $D00E
        CPX #255
        BNE NEXT7
        LDA #%10000000
        EOR SPR_MSBX
        STA SPR_MSBX
NEXT7

        LDA #116 ; NEXT DO IRQ1 AT RASTER LINE 116
        STA IRQRASTER
        LDA #<IRQ1
        STA IRQADDRMSB
        LDA #>IRQ1
        STA IRQADDRLSB

        ASL IRQFLAG ; RESET IRQ FLAG

        JMP IRQCONTINUE ; CONTINUE WITH IRQS

IRQ1    
        ; SET Y COORDINATES
        LDA #$01
        STA $FA
        LDA #$D0
        STA $FB
        LDY #0
        LDA #140
SETY2   STA ($FA),Y
        INY
        INY
        CPY #16
        BNE SETY2
        
        ; SET COLORS
        LDA #$27
        STA $FA
        LDA #$D0
        STA $FB
        LDY #0
        LDA #2
        STA $FC
SETCLR2 LDA $FC
        STA ($FA),Y
        INY
        INC $FC
        CPY #8
        BNE SETCLR2

        LDA #182 ; NEXT TO IRQ2 AT RASTER LINE 182
        STA IRQRASTER
        LDA #<IRQ2
        STA IRQADDRMSB
        LDA #>IRQ2
        STA IRQADDRLSB

        ASL IRQFLAG

        JMP IRQCONTINUE

IRQ2    
        ; SET Y COORDINATES
        LDA #$01
        STA $FA
        LDA #$D0
        STA $FB
        LDY #0
        LDA #200
SETY3   STA ($FA),Y
        INY
        INY
        CPY #16
        BNE SETY3

        ; SET COLORS
        LDA #$27
        STA $FA
        LDA #$D0
        STA $FB
        LDY #0
        LDA #8
        STA $FC
SETCLR3 LDA $FC
        STA ($FA),Y
        INY
        INC $FC
        CPY #8
        BNE SETCLR3

        LDA #0 ; START AGAIN WITH IRQ0
        STA IRQRASTER
        LDA #<IRQ0
        STA IRQADDRMSB
        LDA #>IRQ0
        STA IRQADDRLSB

        ASL IRQFLAG

        JMP IRQFINISH ; LET MACHINE HANDLE OTHER IRQS

SPRDATA BYTE $00,$00,$00
        BYTE $00,$00,$00
        BYTE $00,$00,$00
        BYTE $00,$15,$40
        BYTE $00,$7E,$91
        BYTE $00,$7E,$91
        BYTE $01,$FE,$A5
        BYTE $15,$FE,$A4
        BYTE $5A,$AA,$A9
        BYTE $6A,$AA,$A9
        BYTE $6A,$AA,$A9
        BYTE $69,$AA,$99
        BYTE $65,$6A,$55
        BYTE $17,$55,$74
        BYTE $05,$40,$54
        BYTE $01,$00,$10
        BYTE $00,$00,$00
        BYTE $00,$00,$00
        BYTE $00,$00,$00
        BYTE $00,$00,$00
        BYTE $00,$00,$00
        BYTE $00
