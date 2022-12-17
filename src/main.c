#include <gb/gb.h>
#include <stdio.h>
#include <string.h>
#include "story_controller.h"

void main(void)
{
    display_current_text();
    // Loop forever
    while(1) {
		// Game main loop processing goes here
        handle_input();
		// Done processing, yield CPU and wait for start of next frame
        wait_vbl_done();
    }
}
