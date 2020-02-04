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
    private ArrayList<Ball> deleteBalls;
        
    MainGame() {
        balls = new ArrayList<Ball>();
        deleteBalls = new ArrayList<Ball>();
        action = null;
        
        hud = new Hud();
        screen = new GameScreen(0, width, hud.topLine, hud.bottomLine);  // left, right, top, bottom of play area
        launchPointBall = new Ball(screen.launchPoint);  // Pass in the PVector so that if the screen launchPoint is updated, so is this.
        world = new World();
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
        
        // Display the balls
        for (Ball ball : balls) {
            ball.display();
        }
        
        // Display the world items (blocks and collectibles)
        world.display();
        
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
