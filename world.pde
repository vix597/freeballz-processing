/*
 * world.pde
 *
 * Handles all the level logic. Moving blocks down,
 * generating blocks maintaining the grid, etc...
 *
 * Created on: January 12, 2020
 *     Author: Sean LaPlante
 */
 

class World {
    /*
     * Generates the blocks and collectibles for a level
     */    
    public ArrayList<Block> blocks;
    public ArrayList<Coin> coins;
    public ArrayList<Ball> newBalls;
    
    private ArrayList<Block> deleteBlocks;
    private ArrayList<Coin> deleteCoins;
    private ArrayList<Ball> deleteNewBalls;
    
    private float slideVelocity;
    private boolean slide;
    private float pixelsMoved;
    
    World() {
        blocks = new ArrayList<Block>();
        coins = new ArrayList<Coin>();
        newBalls = new ArrayList<Ball>();
        deleteBlocks = new ArrayList<Block>();
        deleteCoins = new ArrayList<Coin>();
        deleteNewBalls = new ArrayList<Ball>();
        slideVelocity = SLIDE_VELOCITY;
        slide = false;
        pixelsMoved = 0;
    }
    
    void display() {
        // Delete any collectible balls that should be deleted
        for (Ball ball : deleteNewBalls) {
            newBalls.remove(ball);
        }
        deleteNewBalls.clear();
        
        // Delete any coins that should be deleted
        for (Coin coin : deleteCoins) {
            coins.remove(coin);
        }
        deleteCoins.clear();
        
        // Delete any blocks that should be deleted
        for (Block block : deleteBlocks) {
            blocks.remove(block);
        }
        deleteBlocks.clear();
        
        // Display collectible balls
        for (Ball ball : newBalls) {
            ball.display();
        }
 
        // Display coins
        for (Coin coin : coins) {
            coin.display();
        }
        
        // Do we need to slide the blocks?
        if (slide) {
            slideBlocksDown();
        }
        
        // Display the blocks
        for (Block block : blocks) {
            block.display();
        }
    }
    
    void slideBlocksDown() {
        float moveAmount = 0;
        float potentialMove = pixelsMoved + slideVelocity;
      
        if (potentialMove == BLOCK_WIDTH) {
            moveAmount = slideVelocity;
            slide = false;
        } else if (potentialMove < BLOCK_WIDTH) {
            moveAmount = slideVelocity;
        } else {
            moveAmount = slideVelocity - BLOCK_WIDTH;  // Ensure we don't go too far
            slide = false;
        }
        
        for (Block block : blocks) {
            block.slide(moveAmount);
            
            // Check for game over
            if (block.bottom >= ENGINE.hud.bottomLine) {
                println("GAME OVER!!!!!");
            }
        }
        
        if (slide) {
            pixelsMoved += moveAmount;
        } else {
            pixelsMoved = 0;  // Reset if we're done.
        }
    }
    
    int getBlockValue() {
        /*
         * Get a random value for a block
         * based on the current level
         */
         float chance = random(100);
         if (chance < 33) {
             // 1/3rd chance of the block value being double the current level
             return ENGINE.hud.level * 2;
         }
         // otherwise the new blocks value is just the level
         return ENGINE.hud.level;
    }
   
    void generateNewRow() {
        /*
         * Generatea new row of blocks
         */
        int num = int(random(1, BLOCK_COLUMNS)); 
        float x = 0;
        float y = ENGINE.screen.top;

        for (int i = 0; i < BLOCK_COLUMNS && num > 0; i++) {
            if (int(random(2)) == 0 && (BLOCK_COLUMNS - i) > num) {
                x += BLOCK_WIDTH;
            } else {
                int val = getBlockValue();
                Block block = new Block(new PVector(x, y), val);
                blocks.add(block);
                x += BLOCK_WIDTH;
                num--;
            }
        }
        
        slide = true;
    }
    
    void deleteNewBall(Ball delNewBall) {
        /*
         * Handle deleting a collectible ball
         */
         ENGINE.hud.numBalls++;
         deleteNewBalls.add(delNewBall);
    }
    
    void deleteCoin(Coin delCoin) {
        /*
         * Handle deleting a coin
         */
        ENGINE.hud.coins++;
        deleteCoins.add(delCoin);
    }
    
    void deleteBlock(Block delBlock) {
        /*
         * Handle deleting a block
         */
         deleteBlocks.add(delBlock);
    }
}
