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
    fullScreen();  // Runs the sketch fullscreen. Must be first line in setup()
    //size(600, 1024);  // For testing in Java mode

    androidSetup();  // Do the android specific bits
    
    frameRate(90); // Bump framerate to 90 FPS (default 60)
    
    currentState = GameState.START_SCREEN;
    startScreen = new StartScreen();
    mainGame = new MainGame();
    
    //
    // Android Settings
    //
    BALL_RADIUS = 12 * displayDensity;
    SHOT_SPEED = 7 * displayDensity;
    BLOCK_FONT = 26 * displayDensity;
    
    println("osballs!setup: Complete");
}


void draw() {
    /*
     * Builtin method provided by Processing. This is
     * called on each frame.
     */
    background(0);  // Set background to black
    
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
