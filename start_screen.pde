/*
 * start_screen.pde
 *
 * The initial screen presented to the user
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */
 
 
class StartScreen {
    /*
     * Contains buttons for play, settings, etc.
     */
    
    StartScreen() {}
    
    void display() {
        /*
         * Called on each iteration of the draw loop
         * to display the start screen in GameState.START_SCREEN
         */
        
        pushMatrix();
        textAlign(CENTER);
        textSize(42 * displayDensity);
        fill(255);
        text("Touch to start", width/2, height/2);
        popMatrix();
    }
    
    void handleInput(InputType input) {
        /*
         * Called to handle any input that
         * happened while on this screen
         */
        
        if (input == InputType.TOUCH_END) {
            currentState = GameState.PLAYING;  // Set the game state to playing
        }  
    }
}
