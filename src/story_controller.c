#include "story_controller.h"

uint8_t current_page = 0;
uint8_t current_section = 0;
uint8_t current_transition = 0;

bool title_phase = true;
bool page_phase = false;
bool transition_phase = false;

void clear_screen() {
    cls();
    gotoxy(0, 0);
}

void display_title() {
    gotoxy(0, 8);
    printf(get_title_text());
}

void display_page_section() {
    printf(get_page_section(current_page, current_section));
}

void display_transition_options() {
    uint8_t y_level = 1;
    for (uint8_t i = 0; i < get_num_transitions(current_page); ++i) {
        gotoxy(1, y_level);
        printf(get_page_transition(current_page, i));
        y_level += (1 + (strlen(get_page_transition(current_page, i)) >> 3));
    }
}

void move_cursor() {
    uint8_t y_level = 1;
    for (uint8_t i = 0; i < current_transition; i++) {
        gotoxy(0, y_level);
        y_level += (1 + (strlen(get_page_transition(current_page, i)) >> 3));
        printf(" ");
    }
    gotoxy(0, y_level);
    printf(">");
    for (uint8_t i = current_transition; i < get_num_transitions(current_page); i++) {
        y_level += (1 + (strlen(get_page_transition(current_page, i)) >> 3));
        gotoxy(0, y_level);
        printf(" ");
    }
}

void move_cursor_up() {
    if (current_transition > 0) {
        current_transition--;
    }
    move_cursor();
}

void move_cursor_down() {
    if (current_transition + 1 < get_num_transitions(current_page)) {
        current_transition++;
    }
    move_cursor();
}

void transition_to_page(int8_t page) {
    title_phase = false;
    transition_phase = false;
    page_phase = true;
    current_page = page;
    current_section = 0;
    current_transition = 0;
}

void next_section() {
    if (current_section < get_num_sections(current_page)) {
        current_section++;
    }
    if (current_section >= get_num_sections(current_page)) {
        if (get_num_transitions(current_page) > 0) {
            page_phase = false;
            transition_phase = true;
        }
        else if (!is_end_card(current_page)) {
            current_page++;
            transition_to_page(current_page);
        }
    }
    display_current_text();
    if (transition_phase) {
        move_cursor();
    }
}

void previous_section() {
    if (current_section > 0) {
        current_section--;
        display_current_text();
    }
}

void display_current_text() {
    clear_screen();
    if (title_phase) {
        display_title();
    }
    else if (page_phase) {
        display_page_section();
    }
    else if (transition_phase) {
        display_transition_options();
    }
}

void handle_title_input() {
    switch(joypad()) {
        case J_A:
            waitpadup();
            title_phase = false;
            page_phase = true;
            display_current_text();
            break;
        default:
            break;
    }
}

void handle_page_input() {
    switch(joypad()) {
        case J_RIGHT:
            waitpadup();
            next_section();
            break;
        case J_LEFT:
            waitpadup();
            previous_section();
            break;
        default:
            break;
    }
}

void handle_transition_input() {
    switch(joypad()) {
        case J_LEFT:
            waitpadup();
            transition_phase = false;
            page_phase = true;
            previous_section();
            break;
        case J_UP:
            waitpadup();
            move_cursor_up();
            break;
        case J_DOWN:
            waitpadup();
            move_cursor_down();
            break;
        case J_A:
            waitpadup();
            transition_to_page(get_transition_destination(current_page, current_transition));
            display_current_text();
            break;
        default:
            break;
    }
}

void handle_input() {
    if (title_phase) {
        handle_title_input();
    }
    else if (page_phase) {
        handle_page_input();
    }
    else if (transition_phase) {
        handle_transition_input();
    }
}