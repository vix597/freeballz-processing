/*
 * world.pde
 *
 * Handles all the level logic. Moving blocks down,
 * generating blocks maintaining the grid, etc...
 *
 * Created on: January 12, 2020
 *     Author: Sean LaPlante
 */


enum ObjectType {
    BLOCK,
    COIN,
    PICKUP_BALL
}


abstract class WorldObject {
    /*
     * An object that's displayed in the world as part of the level
     * may be a block, collectible ball, or coin or other powerup
     */

    public final ObjectType type;
    public boolean isCollectible;
    protected PVector location;
        
    WorldObject(float x, float y, boolean collect, ObjectType _type) {
        location = new PVector(x, y);
        isCollectible = collect;
        type = _type;
    }
    
    WorldObject(PVector loc, boolean collect, ObjectType _type) {
        location = loc;
        isCollectible = collect;
        type = _type;
    }
    
    void slide(float amount) {
        /*
         * Called to slide the object down on
         * level change
         */
        location.y += amount;
    }
    
    /*
     * The following abstract methods must be
     * implemented by all subclasses. Allows
     * for our collision detection code to be
     * the same regardless of the object.
     */
    public abstract float getLeft();    // Get the left 'x' coord of the object.
    public abstract float getRight();   // Get the right 'x' coord of the object.
    public abstract float getTop();     // Get the top 'y' coord of the object.
    public abstract float getBottom();  // Get the bottom 'y' coord of the object.
    public abstract float getRadius();  // Get the radius of the object.
    public abstract float getWidth();  // Get the width (or diameter) of the object.
    public abstract PVector getMiddle();// Get the middle (x, y) coords of the object.
    public abstract void collide();  // called when a ball collides with the object.
    public abstract void display();  // called on each frame to display the object.
    public abstract boolean isPointInObject(PVector point);  // called to check if a point is inside the bounds of this object (used for collision).
}


class World {
    /*
     * Generates the blocks and collectibles for a level
     */    
    public ArrayList<Block> blocks;
    public ArrayList<Coin> coins;
    public ArrayList<PickupBall> pickupBalls;
    
    private ArrayList<Block> deleteBlocks;
    private ArrayList<Coin> deleteCoins;
    private ArrayList<PickupBall> deletePickupBalls;
    
    private float slideVelocity;
    private boolean slide;
    private float pixelsMoved;
    
    World() {
        blocks = new ArrayList<Block>();
        coins = new ArrayList<Coin>();
        pickupBalls = new ArrayList<PickupBall>();
        deleteBlocks = new ArrayList<Block>();
        deleteCoins = new ArrayList<Coin>();
        deletePickupBalls = new ArrayList<PickupBall>();
        slideVelocity = SLIDE_VELOCITY;
        slide = false;
        pixelsMoved = 0;
    }
    
    void display() {
        // Delete any collectible balls that should be deleted
        for (PickupBall ball : deletePickupBalls) {
            pickupBalls.remove(ball);
        }
        deletePickupBalls.clear();
        
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
        
        // Do we need to slide everything down?
        if (slide) {
            slideObjectsDown();
        }
        
        // Display collectible balls
        for (PickupBall ball : pickupBalls) {
            ball.display();
        }
 
        // Display coins
        for (Coin coin : coins) {
            coin.display();
        }
        
        // Display the blocks
        for (Block block : blocks) {
            block.display();
        }
    }
    
    void slideObjectsDown() {
        float moveAmount = 0;
        float potentialMove = pixelsMoved + slideVelocity;
      
        if (potentialMove == BLOCK_WIDTH) {
            moveAmount = slideVelocity;
            slide = false;
        } else if (potentialMove < BLOCK_WIDTH) {
            moveAmount = slideVelocity;
        } else {
            moveAmount = potentialMove - BLOCK_WIDTH;  // Ensure we don't go too far
            slide = false;
        }
        
        for (Coin coin : coins) {
            coin.slide(moveAmount);
            // TODO - Detect coin at bottom and delete it
        }

        for (PickupBall ball : pickupBalls) {
            ball.slide(moveAmount);
            // TODO - Detect ball at bottom and delete it
        }
        
        for (Block block : blocks) {
            block.slide(moveAmount);
            
            // Check for game over
            if (block.bottom >= ENGINE.hud.bottomLine) {
                println("GAME OVER!!!!!");
                gameOver();
                return;
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
        boolean generatedCoin = false;
        boolean generatedPickupBall = false;
        int num = int(random(1, BLOCK_COLUMNS)); 
        float x = 0;
        float y = ENGINE.screen.top;

        for (int i = 0; i < BLOCK_COLUMNS && num > 0; i++) {
            if (int(random(2)) == 0 && (BLOCK_COLUMNS - i) > num) {
                if (!generatedPickupBall && ENGINE.hud.level > 1) {
                    // Need one of these per level (except level 1)
                    pickupBalls.add(new PickupBall(x + (BLOCK_WIDTH / 2), y + (BLOCK_WIDTH / 2)));
                    generatedPickupBall = true;
                } else if (!generatedCoin) {
                    // Chance of one coin per level
                    coins.add(new Coin(x + (BLOCK_WIDTH / 2), y + (BLOCK_WIDTH / 2)));
                    generatedCoin = true;
                }
                x += BLOCK_WIDTH;
            } else {
                int val = getBlockValue();
                Block block = new Block(new PVector(x, y), val);
                blocks.add(block);
                x += BLOCK_WIDTH;
                num--;
            }
        }
        
        if (!generatedPickupBall && ENGINE.hud.level > 1) {
            // Make sure we generated a pickup ball (except level 1)
            pickupBalls.add(new PickupBall(x + (BLOCK_WIDTH / 2), y + (BLOCK_WIDTH / 2)));
        } else if (!generatedCoin && int(random(2)) == 0) {
            // Chance of coin in last slot
            coins.add(new Coin(x + (BLOCK_WIDTH / 2), y + (BLOCK_WIDTH / 2)));
        }
        
        slide = true;
    }
 
    void deletePickupBall(PickupBall delPickupBall) {
        /*
         * Handle deleting a collectible ball
         */
         ENGINE.hud.numBalls++;
         deletePickupBalls.add(delPickupBall);
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
