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
    
    // The percentage of screen space taken at the top and bottom
    // by the HUD
    private static final float topSizePercent = 5.0;
    private static final float bottomSizePercent = 10.0;
    
    private float bottomLine;
    private float topLine;
    private float topHeight;
    private float bottomHeight;
    
    private int level;
    private int numBalls;
    private int score;
    private int coins;
    
    Hud(int _level, int _numBalls, int _score, int _coins) {
      level = _level;
      numBalls = _numBalls;
      score = _score;
      coins = _coins;
      
      topHeight = int(height * (topSizePercent / 100.0));
      bottomHeight = int(height * (bottomSizePercent / 100.0));
      
      topLine = topHeight;
      bottomLine = height - bottomHeight;
    }
    
    float getTopLine() {
        /*
         * Return the bottom of the top of the HUD
         */
        return topLine;
    }
    
    float getBottomLine() {
        /*
         * Return the top of the bottom of the HUD
         */
        return bottomLine;
    }
    
    void nextLevel() {
        /*
         * Called when the player moves to the next level
         */
        level++;
    }
    
    void collectCoin() {
        /*
         * Called when the player collects a coin
         */
        coins++;
    }
    
    void scorePoints(int points) {
        /*
         * Called when the player destroys a block
         * to collect the points for the block
         */
        score += points;
    }
    
    void collectBall() {
        /*
         * Called when the player collects another ball
         */
        numBalls++;
    }
        
    void display() {
        /*
         * Called on each draw loop to display the HUD
         */
        pushMatrix();
        
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
}
