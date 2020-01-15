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
    //fullScreen();  // Runs the sketch fullscreen. Must be first line in setup()
    size(600, 1024);
    frameRate(90); // Bump framerate to 90 FPS (default 60)
    
    // Force the orientation to portrait. Prevents auto-rotate.
    //orientation(PORTRAIT);
    
    // Set window flags to keep the screen on
    //keepScreenOn();
    
    currentState = GameState.START_SCREEN;
    startScreen = new StartScreen();
    mainGame = new MainGame();
    
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


//void touchStarted() {
void mousePressed() {
    /*
     * Called when the mouse button is pressed
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


//void touchEnded() {
void mouseReleased() {
    /*
     * Called when the mouse button is released
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
