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
    //fullScreen();  // Runs the sketch fullscreen. Must be first line in setup()
    //
    // PC
    //
    size(600, 1233);  // For testing in Java mode

    //
    // Android Settings
    //
    //BALL_RADIUS = width * 0.02;
    //SHOT_SPEED = 7 * displayDensity;
    //BLOCK_FONT = 28 * displayDensity;
    //BLOCK_COLUMNS = 7;
    //BLOCK_WIDTH = width / BLOCK_COLUMNS;
    //BLOCK_XY_SPACING = BLOCK_WIDTH * 0.07;
    //DEFAULT_TEXT_SIZE = 42 * displayDensity;
    //EXPLODE_PARTICLE_COUNT = 25;
    //EXPLODE_PARTICLE_BWIDTH = 12 * displayDensity;
    //EXPLODE_ALPHA_CHANGE = 10;
    //
    // PC Settings
    //
    BALL_RADIUS = width * 0.02;
    SHOT_SPEED = 7 * displayDensity();
    BLOCK_FONT = 28 * displayDensity();
    BLOCK_COLUMNS = 7;
    BLOCK_WIDTH = width / BLOCK_COLUMNS;
    BLOCK_XY_SPACING = BLOCK_WIDTH * 0.07;
    DEFAULT_TEXT_SIZE = 42 * displayDensity();
    EXPLODE_PARTICLE_COUNT = 35;
    EXPLODE_PARTICLE_BWIDTH = 12;
    EXPLODE_ALPHA_CHANGE = 10;

    //
    // Android
    //
    //androidSetup();  // Do the android specific bits
    
    //
    // Setup the rest
    //
    frameRate(FRAME_RATE); // Bump framerate to 90 FPS (default 60)
    currentState = GameState.START_SCREEN;
    startScreen = new StartScreen();
    mainGame = new MainGame();
    
    println("osballs!setup: Complete");
    println("\tBALL_RADIUS: ", BALL_RADIUS);
    println("\tSHOT_SPEED: ", SHOT_SPEED);
    println("\tBLOCK_FONT: ", BLOCK_FONT);
    println("\tBLOCK_WIDTH: ", BLOCK_WIDTH);
    println("\tBLOCK_XY_SPACING: ", BLOCK_XY_SPACING);
    println("\tEXPLODE_PARTICLE_COUNT: ", EXPLODE_PARTICLE_COUNT);
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
        mainGame.display();
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
        mainGame.handleInput(InputType.TOUCH_START);
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
        mainGame.handleInput(InputType.TOUCH_END);
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
        mainGame.handleInput(InputType.TOUCH_MOVE);
        break;
    }
}
