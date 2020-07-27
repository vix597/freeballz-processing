/*
 * os-balls.pde
 *
 * Main game file for OS-Balls
 *
 *  Created on: December 23, 2019
 *      Author: Sean LaPlante
 */
 

void setup() {
    /*
     * Builtin method provided by Processing. This is
     * always called first.
     */
    
    //
    // Android
    //
    fullScreen();  // Runs the sketch fullscreen. Must be first line in setup()
    //
    // PC
    //
    //size(600, 1233);  // For testing in Java mode

    //
    // Android Settings
    //
    SHOT_SPEED = 8 * displayDensity;
    DEFAULT_TEXT_SIZE = 42 * displayDensity;
    SMALL_TEXT_SIZE = 28 * displayDensity;
    EXPLODE_PART_BWIDTH = 12 * displayDensity;
    SLIDE_VELOCITY = 5 * displayDensity;
    EXPLODE_PART_MAX_SPEED = 3 * displayDensity;
    EXPLODE_PART_MIN_SPEED = -3 * displayDensity;
    SAVE_LOCATION = "osballs.json";
    //
    // PC Settings
    //
    //SHOT_SPEED = 8 * displayDensity();
    //DEFAULT_TEXT_SIZE = 42 * displayDensity();
    //SMALL_TEXT_SIZE = 28 * displayDensity();
    //EXPLODE_PART_BWIDTH = 12 * displayDensity();
    //SLIDE_VELOCITY = 5 * displayDensity();
    //EXPLODE_PART_MAX_SPEED = 3 * displayDensity();
    //EXPLODE_PART_MIN_SPEED = -3 * displayDensity();
    //SAVE_LOCATION = "data/osballs.json";
    //
    // Shared Settings
    //
    BALL_RADIUS = width * 0.02;
    PICKUP_BALL_RADIUS = BALL_RADIUS * 1.75;
    COIN_RADIUS = BALL_RADIUS * 1.5;
    BLOCK_COLUMNS = 7;
    BLOCK_WIDTH = width / BLOCK_COLUMNS;
    BLOCK_XY_SPACING = BLOCK_WIDTH * 0.07;
    EXPLODE_PART_COUNT = 35;
    EXPLODE_ALPHA_CHANGE = 10;
    HUD_TOP_SIZE_PERCENT = 8.0;
    HUD_BOTTOM_SIZE_PERCENT = 15.0;
    
    //
    // Android
    //
    androidSetup();  // Do the android specific bits
    
    //
    // Setup the rest
    //
    frameRate(FRAME_RATE); // Bump framerate to 90 FPS (default 60)
    startGame();
    
    println("osballs!setup: Complete");
    println("\tBALL_RADIUS: ", BALL_RADIUS);
    println("\tSHOT_SPEED: ", SHOT_SPEED);
    println("\tSMALL_TEXT_SIZE: ", SMALL_TEXT_SIZE);
    println("\tBLOCK_COLUMNS: ", BLOCK_COLUMNS);
    println("\tBLOCK_WIDTH: ", BLOCK_WIDTH);
    println("\tBLOCK_XY_SPACING: ", BLOCK_XY_SPACING);
    println("\tDEFAULT_TEXT_SIZE: ", DEFAULT_TEXT_SIZE);
    println("\tEXPLODE_PART_COUNT: ", EXPLODE_PART_COUNT);
    println("\tEXPLODE_PART_BWIDTH: ", EXPLODE_PART_BWIDTH);
    println("\tEXPLODE_PART_MAX_SPEED: ", EXPLODE_PART_MAX_SPEED);
    println("\tEXPLODE_PART_MIN_SPEED: ", EXPLODE_PART_MIN_SPEED);
    println("\tEXPLODE_ALPHA_CHANGE: ", EXPLODE_ALPHA_CHANGE);
    println("\tHUD_TOP_SIZE_PERCENT: ", HUD_TOP_SIZE_PERCENT);
    println("\tHUD_BOTTOM_SIZE_PERCENT: ", HUD_BOTTOM_SIZE_PERCENT);
    println("\tSLIDE_VELOCITY: ", SLIDE_VELOCITY);
}


void draw() {
    /*
     * Builtin method provided by Processing. This is
     * called on each frame.
     */
    background(60);  // Set background to black
    
    switch(currentState) {
    case START_SCREEN:
        startScreen.display();
        break;
    case PLAYING:
        ENGINE.display();
        break;
    }
}


void mousePressed() {
    /*
     * Called when the mouse or touch is pressed
     */
    switch(currentState) {
    case START_SCREEN:
        startScreen.handleInput(InputType.TOUCH_START);
        break;
    case PLAYING:
        ENGINE.handleInput(InputType.TOUCH_START);
        break;
    }
}


void mouseReleased() {
    /*
     * Called when the mouse or touch is released
     */
    switch(currentState) {
    case START_SCREEN:
        startScreen.handleInput(InputType.TOUCH_END);
        break;
    case PLAYING:
        ENGINE.handleInput(InputType.TOUCH_END);
        break;
    }
}


void mouseMoved() {
    /*
     * Called when the mouse or touch is moved
     */
    switch(currentState) {
    case START_SCREEN:
        startScreen.handleInput(InputType.TOUCH_MOVE);
        break;
    case PLAYING:
        ENGINE.handleInput(InputType.TOUCH_MOVE);
        break;
    }
}
