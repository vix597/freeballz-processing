/*
 * hud.pde
 *
 * The heads up display class
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */


import java.lang.*;

 
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
    
    private int ballsCollectedThisTurn;
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
      ballsCollectedThisTurn = 0;
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
        if (prevBest < level) {
            prevBest = level;
        }
        level = 1;
        numBalls = 1;
        saveGame(true);
    }
    
    void loadGame() {
        /*
         * Load the latest save
         */
        JSONObject json = null, version = null;
        int ver_major = 0, ver_minor = 0, ver_build = 0;
        String currentVersion;
        
        // Will throw an exception if the file doesn't exist yet.
        try {
            json = loadJSONObject(SAVE_LOCATION);
        } catch (Exception e) {
            println("No save file yet.");
            return;
        }
                
        // Parse out the version info
        version = json.getJSONObject("version");
        ver_major = version.getInt("major");
        ver_minor = version.getInt("minor");
        ver_build = version.getInt("build");
        
        currentVersion = str(VERSION_MAJOR) + "." + str(VERSION_MINOR) + "." + str(VERSION_BUILD);
        println("Free Ballz version: ", currentVersion);        

        if (ver_major > VERSION_MAJOR || ver_minor > VERSION_MINOR || ver_build > VERSION_BUILD) {
            println("Downgrading is not supported. Clearing save data.");
            return;  // Just return. The save data will be overwritten on save.
        }
        
        if (ver_major < VERSION_MAJOR || ver_minor < VERSION_MINOR || ver_build < VERSION_BUILD) {
            migrateVersion(ver_major, ver_minor, ver_build);
        }
        
        level = json.getInt("level");
        numBalls = json.getInt("numBalls");
        prevBest = json.getInt("prevBest");
        coins = json.getInt("coins");
        
        JSONArray jsonBlocks = json.getJSONArray("blocks");
        JSONArray jsonCoins = json.getJSONArray("pickupCoins");
        JSONArray jsonPickupBalls = json.getJSONArray("pickupBalls");

        if (jsonBlocks.size() > 0 || jsonCoins.size() > 0 || jsonPickupBalls.size() > 0) {
            ENGINE.world.blocks.clear();
            ENGINE.world.coins.clear();
            ENGINE.world.pickupBalls.clear();
            
            for (int idx = 0; idx < jsonBlocks.size(); idx++) {
                JSONObject jsonBlock = (JSONObject)jsonBlocks.get(idx);
                float x, y;
                x = jsonBlock.getFloat("locationX");
                y = jsonBlock.getFloat("locationY");
                ENGINE.world.blocks.add(new Block(new PVector(x, y), jsonBlock.getInt("points")));    
            }
            
            for (int idx = 0; idx < jsonCoins.size(); idx++) {
                JSONObject jsonCoin = (JSONObject)jsonCoins.get(idx);
                float x, y;
                x = jsonCoin.getFloat("locationX");
                y = jsonCoin.getFloat("locationY");
                ENGINE.world.coins.add(new Coin(x, y));
            }
            
            for (int idx = 0; idx < jsonPickupBalls.size(); idx++) {
                JSONObject jsonPickupBall = (JSONObject)jsonPickupBalls.get(idx);
                float x, y;
                x = jsonPickupBall.getFloat("locationX");
                y = jsonPickupBall.getFloat("locationY");
                ENGINE.world.pickupBalls.add(new PickupBall(x, y));
            }
        }
        
        println("Loaded game:");
        println("\tLevel: ", level);
        println("\tCoins: ", coins);
        println("\tPrevious Best: ", prevBest);
        println("\tNumber of balls: ", numBalls);
    }
    
    void saveGame(boolean gameOver) {
        /*
         * Save the game state
         *
         * gameOver will be set false unless it's game over.
         * On game over we clear the blocks.
         */
        JSONObject json = new JSONObject();
        json.setInt("level", level);
        json.setInt("numBalls", numBalls);
        json.setInt("prevBest", prevBest);
        json.setInt("coins", coins);
        
        JSONObject version = new JSONObject();
        version.setInt("major", VERSION_MAJOR);
        version.setInt("minor", VERSION_MINOR);
        version.setInt("build", VERSION_BUILD);
        json.setJSONObject("version", version);
        
        JSONArray jsonBlocks = new JSONArray();
        JSONArray jsonCoins = new JSONArray();
        JSONArray jsonPickupBalls = new JSONArray();
        
        if (!gameOver) {
            // Save the blocks so they can resume
            for (Block block : ENGINE.world.blocks) {
                JSONObject jsonBlock = new JSONObject();
                jsonBlock.setFloat("locationX", block.location.x);
                jsonBlock.setFloat("locationY", block.location.y);
                jsonBlock.setInt("points", block.remHitPoints);
                jsonBlocks.append(jsonBlock);
            }
            
            // Save the coins
            for (Coin coin : ENGINE.world.coins) {
                JSONObject jsonCoin = new JSONObject();
                jsonCoin.setFloat("locationX", coin.location.x);
                jsonCoin.setFloat("locationY", coin.location.y);
                jsonCoins.append(jsonCoin);
            }
            
            // Save the pickup balls
            for (PickupBall ball : ENGINE.world.pickupBalls) {
                JSONObject jsonPickupBall = new JSONObject();
                jsonPickupBall.setFloat("locationX", ball.location.x);
                jsonPickupBall.setFloat("locationY", ball.location.y);
                jsonPickupBalls.append(jsonPickupBall);
            }
        }

        json.setJSONArray("blocks", jsonBlocks);
        json.setJSONArray("pickupCoins", jsonCoins);
        json.setJSONArray("pickupBalls", jsonPickupBalls);
        
        saveJSONObject(json, SAVE_LOCATION);
    }
    
    void migrateVersion(int from_major, int from_minor, int from_build) {
        /*
         * Called automatically in loadGame() if the version in the config
         * doesn't match the current game version.
         */
        String from = str(from_major) + "." + str(from_minor) + "." + str(from_build);
        String to = str(VERSION_MAJOR) + "." + str(VERSION_MINOR) + "." + str(VERSION_BUILD);
        println("New version detected. Migrating save file from ", from, " to ", to);
        
        //
        // TODO: Write migrations here when we need them
        //
    }
}
