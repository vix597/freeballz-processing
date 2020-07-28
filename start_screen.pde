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
    
    Button playButton;
    
    StartScreen() {
      float buttonHeight = width * 0.15;
      float buttonWidth = width / 1.5;
      float halfWidth = buttonWidth / 2;
      float halfHeight = buttonHeight / 2;
      float xPos = (width / 2) - halfWidth;
      float yPos = (height / 2) - halfHeight;
      
      playButton = new Button("PLAY", xPos, yPos, buttonWidth, buttonHeight, 10);
    }
    
    void display() {
        /*
         * Called on each iteration of the draw loop
         * to display the start screen in GameState.START_SCREEN
         */
        
        pushMatrix();
        playButton.display();
        popMatrix();
    }
    
    void handleInput(InputType input) {
        /*
         * Called to handle any input that
         * happened while on this screen
         */
        
        if (input == InputType.TOUCH_END && playButton.onButton(mouseX, mouseY)) {
            currentState = GameState.PLAYING;  // Set the game state to playing
        }  
    }
}
