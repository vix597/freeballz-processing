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

GameState currentState = GameState.START_SCREEN;
StartScreen startScreen = null;
MainGame ENGINE = null;


int FRAME_RATE = 90;

//
// Globals used throughout the game
//
// These are set in setup()
//
float BALL_RADIUS;              // The radius of the game ball
float PICKUP_BALL_RADIUS;       // The radius of the ring around pickup balls
float COIN_RADIUS;              // The radius of a coin
float SHOT_SPEED;               // The speed the ball travels for a shot
float BLOCK_WIDTH;              // The width of a game block
float BLOCK_RADIUS;             // A block's corner radius to make the corners kind-of rounded
int EXPLODE_PART_COUNT;         // Number of particles a block turns into when it explodes
int EXPLODE_ALPHA_CHANGE;       // Rate of change for the alpha of an explostion particle (how fast do they fade out?)
float EXPLODE_PART_MAX_SPEED;   // Minimum speed (used to set the velocity) - Should be negative.
float EXPLODE_PART_MIN_SPEED;   // Max speed (used to set the velocity) - Should be positive.
float EXPLODE_PART_BWIDTH;      // An explosion particle is also a square. What's its width and height?
float EXPLODE_PART_RADIUS;      // An explosion particle's corner radius to make the rects rounded.
float BLOCK_XY_SPACING;         // The whitespace between the blocks
float DEFAULT_TEXT_SIZE;        // Size of the rest of the text
float SMALL_TEXT_SIZE;          // Size of small text
int BLOCK_COLUMNS;              // Number of columns for blocks
float HUD_TOP_SIZE_PERCENT;     // Percentage of the screen height that should be taken for the top of the HUD
float HUD_BOTTOM_SIZE_PERCENT;  // Percentage of the screen height that should be taken for the bottom of the HUD
float SLIDE_VELOCITY;           // y direction velocity for sliding blocks down when the level changes
String SAVE_LOCATION;           // The save location. On android just "osballs.json". On PC "data/osballs.json"
int VERSION_MAJOR = 1;          // Major version number (e.g. the 1 in 1.2.3)
int VERSION_MINOR = 0;          // Minor version number (e.g. the 2 in 1.2.3)
int VERSION_BUILD = 0;          // The build/patch version number (e.g. the 3 in 1.2.3)
boolean IS_ANDROID_MODE;        // Set in settings(). True if running in Android mode, False otherwise.
float BUTTON_RADIUS;            // A button's corner radius.


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


void startGame() {
    /*
     * Called in setup and game over
     */
    currentState = GameState.START_SCREEN;
    startScreen = new StartScreen();
    ENGINE = new MainGame();
    ENGINE.world.generateNewRow();
    ENGINE.hud.loadGame();
}


void gameOver() {
    /*
     * Called when they lose
     */
    ENGINE.hud.gameOver();  // This will save what is required.
    startGame();
}
