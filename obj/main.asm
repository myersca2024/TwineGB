;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.6 #12539 (Mac OS X x86_64)
;--------------------------------------------------------
	.module main
	.optsdcc -mgbz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _handle_input
	.globl _display_current_text
	.globl _wait_vbl_done
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;src/main.c:6: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
;src/main.c:8: display_current_text();
	call	_display_current_text
;src/main.c:10: while(1) {
00102$:
;src/main.c:12: handle_input();
	call	_handle_input
;src/main.c:14: wait_vbl_done();
	call	_wait_vbl_done
;src/main.c:16: }
	jr	00102$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
