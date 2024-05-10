.feature string_escapes
.import _consolemain, _copy_data_to_ram, _nmi
.import callptr4
.import __SOFTSTACK_START__, __SOFTSTACK_SIZE__
.importzp sp, tmp4
.export _trampoline, _selbank;

.define MAPPER_NUMBER 2
.define VERTICAL_MIRRORING 00h
.define HORIZONTAL_MIRRORING 01h
.define HAS_BATTERY 02h
.define TRAINER 04h
.define ALT_NAMETABLE 08h

.segment "ines2header"
header: .byte "NES\x1A"
prg_rom_size: .byte 10h
chr_rom_size: .byte 00h
flags6: .byte ((MAPPER_NUMBER&0fh)<<4)|HORIZONTAL_MIRRORING
flags7: .byte (MAPPER_NUMBER&0f0h)

.segment "cpuvectors"
.addr nmi
.addr startfunc
.addr isr

.segment "ZEROPAGE"
_selbank: .res 1
bsa:     .res 1

.segment "CODE"

startfunc:
    sei
    cld

    ; init hardware stack
    ldx #$ff
    txs

    ; init cc65 soft stack
    lda #.hibyte(__SOFTSTACK_START__+__SOFTSTACK_SIZE__-1)
    sta sp+1
    lda #.lobyte(__SOFTSTACK_START__+__SOFTSTACK_SIZE__-1)
    sta sp

    ; select bank #0
    lda #80
    sta $c000
    sta _selbank

    ; init data segment
    jsr _copy_data_to_ram

    ; jump to C code
    jsr _consolemain

    ; loop forever
program_end: jmp program_end

; NOOP interrupt handler
isr:
    rti

nmi:
    jsr _nmi
    rti

; cross-bank call trampoline
.proc _trampoline
    ; store accumulator temporarily
    sta bsa

    ; load current bank and push it on hard stack
    lda _selbank
    pha

    ; load the target bank from tmp4 and select it
    lda tmp4
    ora #80;
    sta $C000

    ; store the target bank
    sta _selbank

    ; recover the accumulator value
    lda bsa

    ; call the target function
    jsr callptr4

    ; store accumulator temporarily
    sta bsa

    ; recover the previous bank from stack and select it
    pla
    ora #80;
    sta $C000

    ; store the previous bank
    sta _selbank

    ; recover the accumulator value and return
    lda bsa
    rts
.endproc