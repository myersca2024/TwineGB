;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.1.6 #12539 (Mac OS X x86_64)
;--------------------------------------------------------
	.module story_controller
	.optsdcc -mgbz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _handle_transition_input
	.globl _handle_page_input
	.globl _handle_title_input
	.globl _previous_section
	.globl _next_section
	.globl _transition_to_page
	.globl _move_cursor_down
	.globl _move_cursor_up
	.globl _move_cursor
	.globl _display_transition_options
	.globl _display_page_section
	.globl _display_title
	.globl _clear_screen
	.globl _is_end_card
	.globl _get_transition_destination
	.globl _get_num_transitions
	.globl _get_num_sections
	.globl _get_page_transition
	.globl _get_page_section
	.globl _get_title_text
	.globl _strlen
	.globl _cls
	.globl _gotoxy
	.globl _printf
	.globl _waitpadup
	.globl _joypad
	.globl _transition_phase
	.globl _page_phase
	.globl _title_phase
	.globl _current_transition
	.globl _current_section
	.globl _current_page
	.globl _display_current_text
	.globl _handle_input
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
_current_page::
	.ds 1
_current_section::
	.ds 1
_current_transition::
	.ds 1
_title_phase::
	.ds 1
_page_phase::
	.ds 1
_transition_phase::
	.ds 1
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
;src/story_controller.c:11: void clear_screen() {
;	---------------------------------
; Function clear_screen
; ---------------------------------
_clear_screen::
;src/story_controller.c:12: cls();
	call	_cls
;src/story_controller.c:13: gotoxy(0, 0);
	xor	a, a
	rrca
	push	af
	call	_gotoxy
	pop	hl
;src/story_controller.c:14: }
	ret
;src/story_controller.c:16: void display_title() {
;	---------------------------------
; Function display_title
; ---------------------------------
_display_title::
;src/story_controller.c:17: gotoxy(0, 8);
	ld	hl, #0x800
	push	hl
	call	_gotoxy
	pop	hl
;src/story_controller.c:18: printf(get_title_text());
	call	_get_title_text
	push	de
	call	_printf
	pop	hl
;src/story_controller.c:19: }
	ret
;src/story_controller.c:21: void display_page_section() {
;	---------------------------------
; Function display_page_section
; ---------------------------------
_display_page_section::
;src/story_controller.c:22: printf(get_page_section(current_page, current_section));
	ld	a, (#_current_section)
	ld	h, a
	ld	a, (#_current_page)
	ld	l, a
	push	hl
	call	_get_page_section
	pop	hl
	push	de
	call	_printf
	pop	hl
;src/story_controller.c:23: }
	ret
;src/story_controller.c:25: void display_transition_options() {
;	---------------------------------
; Function display_transition_options
; ---------------------------------
_display_transition_options::
;src/story_controller.c:26: uint8_t y_level = 1;
;src/story_controller.c:27: for (uint8_t i = 0; i < get_num_transitions(current_page); ++i) {
	ld	bc, #0x1
00103$:
	push	bc
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_num_transitions
	inc	sp
	pop	bc
	ld	a, b
	sub	a, e
	ret	NC
;src/story_controller.c:28: gotoxy(1, y_level);
	push	bc
	ld	h, c
	ld	l, #0x01
	push	hl
	call	_gotoxy
	pop	hl
	pop	bc
;src/story_controller.c:29: printf(get_page_transition(current_page, i));
	push	bc
	push	bc
	inc	sp
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_page_transition
	pop	hl
	push	de
	call	_printf
	pop	hl
	pop	bc
;src/story_controller.c:30: y_level += (1 + (strlen(get_page_transition(current_page, i)) >> 3));
	push	bc
	push	bc
	inc	sp
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_page_transition
	pop	hl
	pop	bc
	push	de
	call	_strlen
	pop	hl
	sra	d
	rr	e
	sra	d
	rr	e
	sra	d
	rr	e
	ld	a, e
	inc	a
	add	a, c
	ld	c, a
;src/story_controller.c:27: for (uint8_t i = 0; i < get_num_transitions(current_page); ++i) {
	inc	b
;src/story_controller.c:32: }
	jr	00103$
;src/story_controller.c:34: void move_cursor() {
;	---------------------------------
; Function move_cursor
; ---------------------------------
_move_cursor::
;src/story_controller.c:35: uint8_t y_level = 1;
;src/story_controller.c:36: for (uint8_t i = 0; i < current_transition; i++) {
	ld	bc, #0x100
00104$:
	ld	a, c
	ld	hl, #_current_transition
	sub	a, (hl)
	jr	NC, 00101$
;src/story_controller.c:37: gotoxy(0, y_level);
	push	bc
	push	bc
	inc	sp
	xor	a, a
	push	af
	inc	sp
	call	_gotoxy
	pop	hl
	pop	bc
;src/story_controller.c:38: y_level += (1 + (strlen(get_page_transition(current_page, i)) >> 3));
	push	bc
	ld	a, c
	push	af
	inc	sp
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_page_transition
	pop	hl
	pop	bc
	push	de
	call	_strlen
	pop	hl
	sra	d
	rr	e
	sra	d
	rr	e
	sra	d
	rr	e
	ld	a, e
	inc	a
	add	a, b
	ld	b, a
;src/story_controller.c:39: printf(" ");
	push	bc
	ld	de, #___str_0
	push	de
	call	_printf
	pop	hl
	pop	bc
;src/story_controller.c:36: for (uint8_t i = 0; i < current_transition; i++) {
	inc	c
	jr	00104$
00101$:
;src/story_controller.c:41: gotoxy(0, y_level);
	push	bc
	push	bc
	inc	sp
	xor	a, a
	push	af
	inc	sp
	call	_gotoxy
	pop	hl
	ld	de, #___str_1
	push	de
	call	_printf
	pop	hl
	pop	bc
;src/story_controller.c:43: for (uint8_t i = current_transition; i < get_num_transitions(current_page); i++) {
	ld	hl, #_current_transition
	ld	c, (hl)
00107$:
	push	bc
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_num_transitions
	inc	sp
	pop	bc
	ld	a, c
	sub	a, e
	ret	NC
;src/story_controller.c:44: y_level += (1 + (strlen(get_page_transition(current_page, i)) >> 3));
	push	bc
	ld	a, c
	push	af
	inc	sp
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_page_transition
	pop	hl
	pop	bc
	push	de
	call	_strlen
	pop	hl
	sra	d
	rr	e
	sra	d
	rr	e
	sra	d
	rr	e
	ld	a, e
	inc	a
	add	a, b
	ld	b, a
;src/story_controller.c:45: gotoxy(0, y_level);
	push	bc
	push	bc
	inc	sp
	xor	a, a
	push	af
	inc	sp
	call	_gotoxy
	pop	hl
	ld	de, #___str_0
	push	de
	call	_printf
	pop	hl
	pop	bc
;src/story_controller.c:43: for (uint8_t i = current_transition; i < get_num_transitions(current_page); i++) {
	inc	c
;src/story_controller.c:48: }
	jr	00107$
___str_0:
	.ascii " "
	.db 0x00
___str_1:
	.ascii ">"
	.db 0x00
;src/story_controller.c:50: void move_cursor_up() {
;	---------------------------------
; Function move_cursor_up
; ---------------------------------
_move_cursor_up::
;src/story_controller.c:51: if (current_transition > 0) {
	ld	hl, #_current_transition
	ld	a, (hl)
	or	a, a
	jp	Z,_move_cursor
;src/story_controller.c:52: current_transition--;
	dec	(hl)
;src/story_controller.c:54: move_cursor();
;src/story_controller.c:55: }
	jp	_move_cursor
;src/story_controller.c:57: void move_cursor_down() {
;	---------------------------------
; Function move_cursor_down
; ---------------------------------
_move_cursor_down::
;src/story_controller.c:58: if (current_transition + 1 < get_num_transitions(current_page)) {
	ld	hl, #_current_transition
	ld	c, (hl)
	ld	b, #0x00
	inc	bc
	push	bc
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_num_transitions
	inc	sp
	pop	bc
	ld	l, e
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	ld	e, h
	ld	d, b
	ld	a, c
	sub	a, l
	ld	a, b
	sbc	a, h
	bit	7, e
	jr	Z, 00110$
	bit	7, d
	jr	NZ, 00111$
	cp	a, a
	jr	00111$
00110$:
	bit	7, d
	jr	Z, 00111$
	scf
00111$:
	jp	NC,_move_cursor
;src/story_controller.c:59: current_transition++;
	ld	hl, #_current_transition
	inc	(hl)
;src/story_controller.c:61: move_cursor();
;src/story_controller.c:62: }
	jp	_move_cursor
;src/story_controller.c:64: void transition_to_page(int8_t page) {
;	---------------------------------
; Function transition_to_page
; ---------------------------------
_transition_to_page::
;src/story_controller.c:65: title_phase = false;
	ld	hl, #_title_phase
	ld	(hl), #0x00
;src/story_controller.c:66: transition_phase = false;
	ld	hl, #_transition_phase
	ld	(hl), #0x00
;src/story_controller.c:67: page_phase = true;
	ld	hl, #_page_phase
	ld	(hl), #0x01
;src/story_controller.c:68: current_page = page;
	ldhl	sp,	#2
	ld	a, (hl)
	ld	(#_current_page),a
;src/story_controller.c:69: current_section = 0;
	ld	hl, #_current_section
	ld	(hl), #0x00
;src/story_controller.c:70: current_transition = 0;
	ld	hl, #_current_transition
	ld	(hl), #0x00
;src/story_controller.c:71: }
	ret
;src/story_controller.c:73: void next_section() {
;	---------------------------------
; Function next_section
; ---------------------------------
_next_section::
;src/story_controller.c:74: if (current_section < get_num_sections(current_page)) {
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_num_sections
	inc	sp
	ld	hl, #_current_section
	ld	a, (hl)
	sub	a, e
	jr	NC, 00102$
;src/story_controller.c:75: current_section++;
	inc	(hl)
00102$:
;src/story_controller.c:77: if (current_section >= get_num_sections(current_page)) {
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_num_sections
	inc	sp
	ld	a, (#_current_section)
	sub	a, e
	jr	C, 00109$
;src/story_controller.c:78: if (get_num_transitions(current_page) > 0) {
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_get_num_transitions
	inc	sp
	ld	a, e
	or	a, a
	jr	Z, 00106$
;src/story_controller.c:79: page_phase = false;
	ld	hl, #_page_phase
	ld	(hl), #0x00
;src/story_controller.c:80: transition_phase = true;
	ld	hl, #_transition_phase
	ld	(hl), #0x01
	jr	00109$
00106$:
;src/story_controller.c:82: else if (!is_end_card(current_page)) {
	ld	a, (#_current_page)
	push	af
	inc	sp
	call	_is_end_card
	inc	sp
	bit	0, e
	jr	NZ, 00109$
;src/story_controller.c:83: current_page++;
	ld	hl, #_current_page
	inc	(hl)
;src/story_controller.c:84: transition_to_page(current_page);
	ld	a, (hl)
	push	af
	inc	sp
	call	_transition_to_page
	inc	sp
00109$:
;src/story_controller.c:87: display_current_text();
	call	_display_current_text
;src/story_controller.c:88: if (transition_phase) {
	ld	hl, #_transition_phase
	bit	0, (hl)
;src/story_controller.c:89: move_cursor();
	jp	NZ,_move_cursor
;src/story_controller.c:91: }
	ret
;src/story_controller.c:93: void previous_section() {
;	---------------------------------
; Function previous_section
; ---------------------------------
_previous_section::
;src/story_controller.c:94: if (current_section > 0) {
	ld	hl, #_current_section
	ld	a, (hl)
	or	a, a
	ret	Z
;src/story_controller.c:95: current_section--;
	dec	(hl)
;src/story_controller.c:96: display_current_text();
;src/story_controller.c:98: }
	jp	_display_current_text
;src/story_controller.c:100: void display_current_text() {
;	---------------------------------
; Function display_current_text
; ---------------------------------
_display_current_text::
;src/story_controller.c:101: clear_screen();
	call	_clear_screen
;src/story_controller.c:102: if (title_phase) {
	ld	hl, #_title_phase
	bit	0, (hl)
;src/story_controller.c:103: display_title();
	jp	NZ,_display_title
;src/story_controller.c:105: else if (page_phase) {
	ld	hl, #_page_phase
	bit	0, (hl)
;src/story_controller.c:106: display_page_section();
	jp	NZ,_display_page_section
;src/story_controller.c:108: else if (transition_phase) {
	ld	hl, #_transition_phase
	bit	0, (hl)
;src/story_controller.c:109: display_transition_options();
	jp	NZ,_display_transition_options
;src/story_controller.c:111: }
	ret
;src/story_controller.c:113: void handle_title_input() {
;	---------------------------------
; Function handle_title_input
; ---------------------------------
_handle_title_input::
;src/story_controller.c:114: switch(joypad()) {
	call	_joypad
	ld	a, e
	sub	a, #0x10
	ret	NZ
;src/story_controller.c:116: waitpadup();
	call	_waitpadup
;src/story_controller.c:117: title_phase = false;
	ld	hl, #_title_phase
	ld	(hl), #0x00
;src/story_controller.c:118: page_phase = true;
	ld	hl, #_page_phase
	ld	(hl), #0x01
;src/story_controller.c:119: display_current_text();
;src/story_controller.c:123: }
;src/story_controller.c:124: }
	jp	_display_current_text
;src/story_controller.c:126: void handle_page_input() {
;	---------------------------------
; Function handle_page_input
; ---------------------------------
_handle_page_input::
;src/story_controller.c:127: switch(joypad()) {
	call	_joypad
	ld	a, e
	cp	a, #0x01
	jr	Z, 00101$
	sub	a, #0x02
	jr	Z, 00102$
	ret
;src/story_controller.c:128: case J_RIGHT:
00101$:
;src/story_controller.c:129: waitpadup();
	call	_waitpadup
;src/story_controller.c:130: next_section();
;src/story_controller.c:131: break;
	jp	_next_section
;src/story_controller.c:132: case J_LEFT:
00102$:
;src/story_controller.c:133: waitpadup();
	call	_waitpadup
;src/story_controller.c:134: previous_section();
;src/story_controller.c:138: }
;src/story_controller.c:139: }
	jp	_previous_section
;src/story_controller.c:141: void handle_transition_input() {
;	---------------------------------
; Function handle_transition_input
; ---------------------------------
_handle_transition_input::
;src/story_controller.c:142: switch(joypad()) {
	call	_joypad
	ld	a, e
	cp	a, #0x02
	jr	Z, 00101$
	cp	a, #0x04
	jr	Z, 00102$
	cp	a, #0x08
	jr	Z, 00103$
	sub	a, #0x10
	jr	Z, 00104$
	ret
;src/story_controller.c:143: case J_LEFT:
00101$:
;src/story_controller.c:144: waitpadup();
	call	_waitpadup
;src/story_controller.c:145: transition_phase = false;
	ld	hl, #_transition_phase
	ld	(hl), #0x00
;src/story_controller.c:146: page_phase = true;
	ld	hl, #_page_phase
;src/story_controller.c:147: previous_section();
;src/story_controller.c:148: break;
	ld	(hl), #0x01
	jp	_previous_section
;src/story_controller.c:149: case J_UP:
00102$:
;src/story_controller.c:150: waitpadup();
	call	_waitpadup
;src/story_controller.c:151: move_cursor_up();
;src/story_controller.c:152: break;
	jp	_move_cursor_up
;src/story_controller.c:153: case J_DOWN:
00103$:
;src/story_controller.c:154: waitpadup();
	call	_waitpadup
;src/story_controller.c:155: move_cursor_down();
;src/story_controller.c:156: break;
	jp	_move_cursor_down
;src/story_controller.c:157: case J_A:
00104$:
;src/story_controller.c:158: waitpadup();
	call	_waitpadup
;src/story_controller.c:159: transition_to_page(get_transition_destination(current_page, current_transition));
	ld	a, (#_current_transition)
	ld	h, a
	ld	a, (#_current_page)
	ld	l, a
	push	hl
	call	_get_transition_destination
	pop	hl
	ld	a, e
	push	af
	inc	sp
	call	_transition_to_page
	inc	sp
;src/story_controller.c:160: display_current_text();
;src/story_controller.c:164: }
;src/story_controller.c:165: }
	jp	_display_current_text
;src/story_controller.c:167: void handle_input() {
;	---------------------------------
; Function handle_input
; ---------------------------------
_handle_input::
;src/story_controller.c:168: if (title_phase) {
	ld	hl, #_title_phase
	bit	0, (hl)
;src/story_controller.c:169: handle_title_input();
	jp	NZ,_handle_title_input
;src/story_controller.c:171: else if (page_phase) {
	ld	hl, #_page_phase
	bit	0, (hl)
;src/story_controller.c:172: handle_page_input();
	jp	NZ,_handle_page_input
;src/story_controller.c:174: else if (transition_phase) {
	ld	hl, #_transition_phase
	bit	0, (hl)
;src/story_controller.c:175: handle_transition_input();
	jp	NZ,_handle_transition_input
;src/story_controller.c:177: }
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__current_page:
	.db #0x00	; 0
__xinit__current_section:
	.db #0x00	; 0
__xinit__current_transition:
	.db #0x00	; 0
__xinit__title_phase:
	.db #0x01	;  1
__xinit__page_phase:
	.db #0x00	;  0
__xinit__transition_phase:
	.db #0x00	;  0
	.area _CABS (ABS)
