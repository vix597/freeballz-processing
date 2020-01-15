/*
 * main_game.pde
 *
 * Class that represents the main game
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */


enum GameAction {
    PREPARE_SHOT,
    CHANGE_LEVEL,
    EXECUTING_SHOT
}


enum GameActionState {
    ACTION_START,
    ACTION_ACTIVE,
    ACTION_COMPLETE
}

 
class MainGame {
    /*
     * This is where the main game logic exists
     */
    
    private Hud hud;
    
    private GameAction action;
    private GameActionState actionState;
    
    // Game screen area
    public GameScreen screen;

    private int launchY;
    private PVector currentLaunchPoint;
    private Ball launchPointBall;
    
    private int level;
    private int numBalls;
    private int score;
    private int coins;
    
    public ArrayList<Ball> balls;
    public ArrayList<Block> blocks;
    
    MainGame() {
        balls = new ArrayList<Ball>();
        blocks = new ArrayList<Block>();
        action = GameAction.PREPARE_SHOT;
        actionState = GameActionState.ACTION_START;
        
        loadGame();
        
        hud = new Hud(level, numBalls, score, coins);  
        screen = new GameScreen(0, width, hud.getTopLine(), hud.getBottomLine());  // left, right, top, bottom of play area
        launchY = screen.bottom - 5;
        currentLaunchPoint = new PVector(width / 2, launchY);  // Start out at the center
        launchPointBall = new Ball(currentLaunchPoint);
        
        generateBlocks();
    }
    
    void loadGame() {
        /*
         * Load the game state
         */
        level = 1;
        numBalls = 1;
        score = 0;
        coins = 0;
    }
    
    void saveGame() {
        /*
         * Called to save the current game state
         */
        // TODO
    }
    
    PVector _extend_line_down(PVector startPoint, PVector endPoint) {
        /* 
         * Draw a line extended to the edge of the
         * screen based on a start and end point.
         * Returns a vector of the calculated end point 
         * for the new line
         */
         
        float x1 = startPoint.x;
        float y1 = startPoint.y;
        float x = endPoint.x;
        float y = endPoint.y;
        
        if (x == x1) {
            return new PVector(x1, screen.bottom);
        } else {
            // Otherwise the line is at an angle and we need to do maths
            // m = (y - y1)/(x - x1)
            float m = (y - y1) / (x - x1);
            // y = mx + b, solve for b: b = y - (m * x)
            float b = y - (m * x);
            // Then, y = mx + b solve for x: x = (y - b) / m
            float newX = (screen.bottom - b) / m;

            float newY = screen.bottom;
            if (newX < 0) {
                // The line is going off the left of the screen
                newX = 0;
                newY = b;
            } else if (newX > width) {
                // The line is going off the right of the screen
                newX = width;
                newY = (m * newX) + b;
            }
            
            return new PVector(newX, newY);
        }
    }
    
    PVector _extend_line_up(PVector startPoint, PVector endPoint) {
        /* 
         * Draw a line extended to the edge of the
         * screen based on a start and end point.
         * Returns a vector of the calculated end point 
         * for the new line
         */
         
        float x = startPoint.x;
        float y = startPoint.y;
        float x1 = endPoint.x;
        float y1 = endPoint.y;
        
        if (x == x1) {
            return new PVector(x1, screen.top);
        } else {
            // Otherwise the line is at an angle and we need to do maths
            // m = (y - y1)/(x - x1)
            float m = (y - y1) / (x - x1);
            // y = mx + b, solve for b: b = y - (m * x)
            float b = y - (m * x);
            // Then, y = mx + b solve for x: x = (y - b) / m
            float newX = (screen.top - b) / m;

            float newY = screen.top;
            if (newX < 0) {
                // The line is going off the left of the screen
                newX = 0;
                newY = b;
            } else if (newX > width) {
                // The line is going off the right of the screen
                newX = width;
                newY = (m * newX) + b;
            }
            
            return new PVector(newX, newY);
        }
    }
    
    ArrayList<Line> _get_shot_lines(int num_lines) {
        /*
         * Draw the shot lines. num_lines determines
         * how many additional lines to draw after the
         * first. Returns the lines to be drawn.
         */

        ArrayList<Line> lines = new ArrayList<Line>();   
        Line prevLine = new Line(
            currentLaunchPoint,
            _extend_line_up(currentLaunchPoint, new PVector(mouseX, mouseY))
        );
            
        lines.add(prevLine);  // We always get at least 1 line.
    
        for (int i = 0; i < num_lines; i++) {
            if (prevLine.endPoint.y == screen.bottom) {
              break;  // Balls end at the bottom of the screen
            }
            
            if (prevLine.isVerticle()) {
                break;  // Don't bother if the line is verticle
            }
            
            if (prevLine.endPoint.y == screen.top) {  // Ends at the top boundary
                PVector nextPoint;
                if (prevLine.endPoint.x < (width / 2)) {
                    nextPoint = new PVector(prevLine.endPoint.x - prevLine.run, prevLine.endPoint.y + prevLine.rise);
                } else {
                    nextPoint = new PVector(prevLine.endPoint.x + prevLine.run, prevLine.endPoint.y + prevLine.rise);
                }
                
                prevLine = new Line(prevLine.endPoint, _extend_line_down(prevLine.endPoint, nextPoint));
                lines.add(prevLine);
            } else if (prevLine.endPoint.x == 0) {
                // Ends at the left boundary
                PVector nextPoint, endPoint;
                if (prevLine.startPoint.y > prevLine.endPoint.y) {
                    // Line direction is "up" the screen
                    nextPoint = new PVector(prevLine.endPoint.x + prevLine.run, prevLine.endPoint.y - prevLine.rise);
                    endPoint = _extend_line_up(prevLine.endPoint, nextPoint);
                } else {
                    // Line direction is "down" the screen
                    nextPoint = new PVector(prevLine.endPoint.x + prevLine.run, prevLine.endPoint.y + prevLine.rise);
                    endPoint = _extend_line_down(prevLine.endPoint, nextPoint);
                }
                
                prevLine = new Line(prevLine.endPoint, endPoint);
                lines.add(prevLine);
            } else if (prevLine.endPoint.x == width) {
                // Ends at the right boundary
                PVector nextPoint, endPoint;
                if (prevLine.startPoint.y > prevLine.endPoint.y) {
                    // Line direction is "up" the screen
                    nextPoint = new PVector(prevLine.endPoint.x - prevLine.run, prevLine.endPoint.y - prevLine.rise);
                    endPoint = _extend_line_up(prevLine.endPoint, nextPoint);
                } else {
                    // Line direction is "down" the screen
                    nextPoint = new PVector(prevLine.endPoint.x - prevLine.run, prevLine.endPoint.y + prevLine.rise);
                    endPoint = _extend_line_down(prevLine.endPoint, nextPoint);
                }
                
                prevLine = new Line(prevLine.endPoint, endPoint);
                lines.add(prevLine);
            }
        }
    
        return lines;
    }
    
    int getBlockValue() {
        /*
         * Get a random value for a block
         * based on the current level
         */
         int min = int(level / 3.0);
         if (min < 1) {
           min = 1;
         }
         int max = int(level * 1.33);
         return int(random(min, max));
    }
   
    void generateBlocks() {
        /*
         * Generate blocks for the
         * current level
         */
        int min;
        int max;
        
        if (level < 8) {
            min = 1;
            max = level;
        } else {
            min = 1;
            max = 7;
        }

        int gen = int(random(min, max));
         
        float x = 0;
        int y = screen.top;
        float bWidth = width / 8.0;
        float spacing = (width / 7.0) - bWidth;
        for (int i = 1; i <= gen; i++) {
            Block block = new Block(
                new PVector(x, y),
                getBlockValue(),
                int(bWidth)
            );
            
            blocks.add(block);

            x += bWidth + spacing;
            
            if (i % 7 == 0 && i > 0) {
                y += bWidth + spacing;
                x = 0;
            }
        }
    }
    
    void display() {
        /*
         * Called on each iteration of the draw loop
         */
        hud.display();
        
        switch(action) {
        case PREPARE_SHOT:        
            // Handle aiming
            if (actionState == GameActionState.ACTION_ACTIVE && mouseY < launchY) {
                ArrayList<Line> lines;
              
                if (DEBUG) {
                    lines = _get_shot_lines(100);
                } else {
                    lines = _get_shot_lines(0);
                }
                
                for (Line line : lines) {
                    line.display();
                }
            }
            break;
        case EXECUTING_SHOT:
            if (balls.size() == 0) {
                action = GameAction.CHANGE_LEVEL;
                actionState = GameActionState.ACTION_START;
            }
            
            if (actionState == GameActionState.ACTION_START) {
                for (int i = 0; i < numBalls; i++) {
                    Ball ball = new Ball(currentLaunchPoint);
                    balls.add(ball);
                    ball.fire(new PVector(-5, -5));
                }
                actionState = GameActionState.ACTION_ACTIVE;
            }
            
            for (Ball ball: balls) {
                ball.move();
            }
            
            break;
        case CHANGE_LEVEL:
            // TODO
            action = GameAction.PREPARE_SHOT;
            break;
        }
        
        // Display the balls
        for (Ball ball: balls) {
            ball.display();
        }
        
        // Display the blocks
        for (Block block : blocks) {
            block.display();
        }
        
        // Display the current launch point
        launchPointBall.display();
    }
    
    void handleInput(InputType input) {
        /*
         * Called on each input event to handle input
         */
        
        if (input == InputType.TOUCH_START && hud.isTouchInHud()) {
            hud.handleInput(input);
            return;
        } 

        // Otherwise the game handles it.
        println("main_game!handleInput: Not touching the HUD!");
        
        switch(input) {
        case TOUCH_START:
            if (action == GameAction.PREPARE_SHOT) {
                actionState = GameActionState.ACTION_ACTIVE;
            }
            break;
        case TOUCH_END:
            if (action == GameAction.PREPARE_SHOT) {
                actionState = GameActionState.ACTION_START;
                action = GameAction.EXECUTING_SHOT;
            }
            break;
        case TOUCH_MOVE:
            break;
        }
    }
}
