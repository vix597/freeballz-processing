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
    Button newGameButton;
    
    StartScreen() {
      float buttonHeight = width * 0.15;
      float buttonWidth = width / 1.5;
      float halfWidth = buttonWidth / 2;
      float halfHeight = buttonHeight / 2;
      float xPos = (width / 2) - halfWidth;
      float yPos = (height / 2) - halfHeight;
      float buttonPadding = buttonHeight / 3;
      
      playButton = new Button("CONTINUE", xPos, yPos, buttonWidth, buttonHeight, 10);
      newGameButton = new Button("NEW GAME", xPos, yPos + buttonHeight + buttonPadding, buttonWidth, buttonHeight, 10);
    }
    
    void display() {
        /*
         * Called on each iteration of the draw loop
         * to display the start screen in GameState.START_SCREEN
         */
        
        pushMatrix();
        playButton.display();
        newGameButton.display();
        popMatrix();
    }
    
    void handleInput(InputType input) {
        /*
         * Called to handle any input that
         * happened while on this screen
         */
        
        if (input == InputType.TOUCH_END && playButton.onButton(mouseX, mouseY)) {
            println("Continue game");
            currentState = GameState.PLAYING;  // Set the game state to playing
        }  else if (input == InputType.TOUCH_END && newGameButton.onButton(mouseX, mouseY)) {
            println("New game");
            ENGINE.hud.gameOver();
            ENGINE.hud.loadGame();
            currentState = GameState.PLAYING;  // Set the game state to playing
        }
    }
}
