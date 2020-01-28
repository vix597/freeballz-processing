/*
 * globals.pde
 *
 * All variables that need global scope
 *
 *  Created on: December 23, 2019
 *      Author: Sean LaPlante
 */

int TIME = 0;
boolean DEBUG = true;  // Displays cheat lines and other useful info

enum GameState {
    START_SCREEN,
    PLAYING
}

enum InputType {
    TOUCH_START,
    TOUCH_END,
    TOUCH_MOVE
}

GameState currentState;

StartScreen startScreen;

MainGame ENGINE;


int FRAME_RATE = 90;

//
// Globally set these based on DPI
//
// These are set in setup()
//
float BALL_RADIUS;              // The radius of the game ball
float SHOT_SPEED;               // The speed the ball travels for a shot
float BLOCK_WIDTH;              // The width of a game block
int EXPLODE_PARTICLE_COUNT;     // Number of particles a block turns into when it explodes
int EXPLODE_ALPHA_CHANGE;       // Rate of change for the alpha of an explostion particle (how fast do they fade out?)
float EXPLODE_PARTICLE_BWIDTH;  // An explosion particle is also a square. What's its width and height?
float BLOCK_XY_SPACING;         // The whitespace between the blocks
float BLOCK_FONT;               // Size of font on a block
float DEFAULT_TEXT_SIZE;        // Size of the rest of the text (for now. TODO - this will probably go away or change)
int BLOCK_COLUMNS;              // Number of columns for blocks
float HUD_TOP_SIZE_PERCENT;     // Percentage of the screen height that should be taken for the top of the HUD
float HUD_BOTTOM_SIZE_PERCENT;  // Percentage of the screen height that should be taken for the bottom of the HUD
float SLIDE_VELOCITY;           // y direction velocity for sliding blocks down when the level changes


void startTimer() {
    /*
     * Used to profile the program when DEBUG is true
     */
    if (!DEBUG) {
        return;
    }
    TIME = millis();
}


void stopTimer(String func) {
    /*
     * Used to profile the program when DEBUG is true
     */
    if (!DEBUG) {
        return;
    }
    println(func, ": ", millis() - TIME);
}
