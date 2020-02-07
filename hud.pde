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
      coins = 99;
      
      topHeight = int(height * (HUD_TOP_SIZE_PERCENT / 100.0));
      bottomHeight = int(height * (HUD_BOTTOM_SIZE_PERCENT / 100.0));
      
      topLine = topHeight;
      bottomLine = height - bottomHeight;
      
      //
      // Adjust the bottom of the HUD to be bigger so that
      // the game screen height is evenly divisible by
      // BLOCK_WIDTH
      //
      float gameScreenHeight = bottomLine - topLine;
      
      // Round to the nearest whole number of block widths
      int numBlockWidthsTall = int(gameScreenHeight / BLOCK_WIDTH);
      
      // Now change bottomHeight and bottomLine appropriately
      // -1 from BLOCK_WIDTH so we collide with the floor when
      // we slide blocks down for game over.
      bottomLine = topLine + (BLOCK_WIDTH * numBlockWidthsTall) - 1;
      bottomHeight = height - bottomLine;
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

        //
        // Display coin count
        //
        noFill();
        stroke(237, 165, 16);
        strokeWeight(5);
        ellipse((width - (BALL_RADIUS * 2)), (topLine / 2), (BALL_RADIUS * 2), (BALL_RADIUS * 2));

        fill(255);
        textSize(SMALL_TEXT_SIZE);
        textAlign(CENTER, CENTER);
        text(str(coins), (width - (BALL_RADIUS * 3)) - (str(coins).length() * (SMALL_TEXT_SIZE / 1.5)), (topLine / 2));

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
