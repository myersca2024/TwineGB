#ifndef STORY_H
#define STORY_H

#include <gb/gb.h>
#include <string.h>
#include <stdbool.h>

const char* get_title_text();
const char* get_page_section(uint8_t page, uint8_t section);
const char* get_page_transition(uint8_t page, uint8_t num);
const uint8_t get_num_pages();
const uint8_t get_num_sections(uint8_t page);
const uint8_t get_num_transitions(uint8_t page);
const int8_t get_transition_destination(uint8_t page, uint8_t transition);
bool is_end_card(uint8_t card);

#endif