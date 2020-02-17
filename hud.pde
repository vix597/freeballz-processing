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
    public int prevBest;
    
    private float charWidth;
    private float coinTxtX;
    private float coinTxtY;
    private float coinX;
    private float coinY;
    private float coinDiameter;
    
    private float lvlTxtX;
    private float lvlTxtY;
    
    Hud() {
      level = 1;
      numBalls = 1;
      coins = 0;
      prevBest = 1;
            
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
      
      //
      // Values used to position text and things in the HUD
      //
      coinDiameter = COIN_RADIUS * 2;
      charWidth = textWidth("0");  // Save off the width of a single number
      lvlTxtX = width / 2;
      lvlTxtY = (topLine / 2) - (DEFAULT_TEXT_SIZE / 16);  // Nudge it up a bit so it feels more 'centered'
      coinTxtX = (width - (COIN_RADIUS * 3)) - charWidth;
      coinTxtY = (topLine / 2) - (SMALL_TEXT_SIZE / 16);  // Nudge it up a bit so it feels more 'centered'
      coinX = width - coinDiameter;
      coinY = topLine / 2;
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
        text(str(level), lvlTxtX, lvlTxtY);

        //
        // Display a coin icon
        //
        noFill();
        stroke(237, 165, 16);
        strokeWeight(5);
        ellipse(coinX, coinY, coinDiameter, coinDiameter);

        //
        // Display the coin count next to the icon
        //
        fill(255);
        textSize(SMALL_TEXT_SIZE);
        textAlign(RIGHT, CENTER);
        text(str(coins), coinTxtX, coinTxtY);

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
    
    void gameOver() {
        /*
         * Called on game over to update the "best" score
         */
        level = 1;
        numBalls = 1;
        saveGame();
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
