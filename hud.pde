/*
 * hud.pde
 *
 * The heads up display class
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */
 
 
class Hud {
    /*
     * A class to handle the game's heads up display.
     * This will show current level, score, and other info
     */    
    public float bottomLine;
    public float topLine;
    public float topHeight;
    public float bottomHeight;
    public int level;
    public int numBalls;
    public int coins;
    
    Hud() {
      level = 1;
      numBalls = 1;
      coins = 0;
      
      topHeight = int(height * (HUD_TOP_SIZE_PERCENT / 100.0));
      bottomHeight = int(height * (HUD_BOTTOM_SIZE_PERCENT / 100.0));
      
      topLine = topHeight;
      bottomLine = height - bottomHeight;
    }
        
    void display() {
        /*
         * Called on each draw loop to display the HUD
         */
        pushMatrix();
        
        noStroke();
        
        //
        // Draw the HUD
        //
        fill(80);
        rect(0,0, width, topHeight);
        rect(0, bottomLine, width, bottomHeight);
        
        //
        // Current level. Middle top
        //
        fill(255);
        textSize(DEFAULT_TEXT_SIZE);
        textAlign(CENTER, CENTER);
        text(str(level), width / 2, topLine / 2);

        popMatrix();
    }
  
    boolean isTouchInHud() {
        /*
         * Called to determine if an input event should be passed
         * to the HUD
         */
    
        // First check if we're touching the HUD
        if (mouseY <= topLine) {
            return true;
        } else if (mouseY >= bottomLine) {
            return true;
        }
        
        return false;
    }
  
    void handleInput(InputType input) {
        /*
         * Called to handle input on the HUD
         */
        println("hud!handleInput: You're touching the HUD!");
    }
    
    void loadGame() {
        /*
         * Load the latest save
         */
    }
    
    void saveGame() {
        /*
         * Save the game state
         */
    }
}
