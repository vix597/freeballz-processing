/*
 * main_game.pde
 *
 * Class that represents the main game
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */


class MainGame {
    /*
     * This is where the main game logic exists
     */    

    public Hud hud;
    public Action action;
    public GameScreen screen;
    public Ball launchPointBall;
    public ShotLine launchLine;
    public World world;
    
    public ArrayList<Ball> balls;
    public ArrayList<Block> blocks;
    public ArrayList<Coin> coins;
    public ArrayList<Ball> newBalls;
    
    private ArrayList<Ball> deleteBalls;
    private ArrayList<Block> deleteBlocks;
    private ArrayList<Coin> deleteCoins;
    private ArrayList<Ball> deleteNewBalls;
        
    MainGame() {
        balls = new ArrayList<Ball>();
        blocks = new ArrayList<Block>();
        coins = new ArrayList<Coin>();
        newBalls = new ArrayList<Ball>();
        deleteBlocks = new ArrayList<Block>();
        deleteBalls = new ArrayList<Ball>();
        deleteCoins = new ArrayList<Coin>();
        deleteNewBalls = new ArrayList<Ball>();
        action = null;
        
        loadGame();
        
        screen = new GameScreen(0, width, hud.getTopLine(), hud.getBottomLine());  // left, right, top, bottom of play area
        launchPointBall = new Ball(screen.launchPoint);  // Pass in the PVector so that if the screen launchPoint is updated, so is this.
        world = new World(this);
        world.generateBlocks();
    }
    
    void loadGame() {
        /*
         * Load the game state
         */
        hud = new Hud(1, 1, 0, 0);
    }
    
    void saveGame() {
        /*
         * Called to save the current game state
         */
        // TODO
    }
    
    void deleteNewBall(Ball delNewBall) {
        /*
         * Handle deleting a collectible ball
         */
         hud.numBalls++;
         deleteNewBalls.add(delNewBall);
    }
    
    void deleteCoin(Coin delCoin) {
        /*
         * Handle deleting a coin
         */
        hud.coins++;
        deleteCoins.add(delCoin);
    }
    
    void deleteBlock(Block delBlock) {
        /*
         * Handle deleting a block
         */
         deleteBlocks.add(delBlock);
    }
    
    void deleteBall(Ball ball) {
        /*
         * Handle deleting a ball
         */
         deleteBalls.add(ball);
    }
    
    void display() {
        /*
         * Called on each iteration of the draw loop
         */
        hud.display();
 
        action = getAction(action);
        action.display();
                 
        // Delete any balls that should be deleted
        for (Ball ball : deleteBalls) {
            balls.remove(ball);
        }
        deleteBalls.clear();
        
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
        
        // Display the balls
        for (Ball ball : balls) {
            ball.display();
        }
        
        // Display collectible balls
        for (Ball ball : newBalls) {
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
        
        // Display the current launch point and number of balls
        launchPointBall.display();
        displayNumBalls();
    }
    
    void handleInput(InputType input) {
        /*
         * Called on each input event to handle input
         */
        
        if (input == InputType.TOUCH_START && hud.isTouchInHud()) {
            hud.handleInput(input);
            return;
        }
        
        if (action != null) {
            action.handleInput(input);
            return;
        }
    }
    
    private void displayNumBalls() {
        /*
         * Display the number of balls above the launch point ball
         */
        int num = 0;
                  
        if (action.action == GameAction.EXECUTING_SHOT && action.state == GameActionState.ACTION_ACTIVE) {
            ExecuteShot execShotAction = (ExecuteShot)action;
            num = hud.numBalls - execShotAction.launchCount;
        } else {
            num = hud.numBalls;
        }
        
        if (num <= 0) {
            return;
        }

        String message = "x" + str(num);
        
        pushMatrix();
        fill(255);
        textSize(BLOCK_FONT);
        textAlign(CENTER);
        text(message, launchPointBall.location.x, (launchPointBall.location.y - (BALL_RADIUS * 2)));
        popMatrix();
    }
}
