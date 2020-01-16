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
    public static final int shotSpeed = 7;
    
    private Hud hud;
    
    private Action action;
    
    // Game screen area
    public GameScreen screen;

    private Ball launchPointBall;
    
    private int level;
    private int numBalls;
    private int score;
    private int coins;
    
    public ArrayList<Ball> balls;
    public ArrayList<Block> blocks;
    public ArrayList<Block> deleteBlocks;
    
    private ArrayList<Line> lines;
    
    MainGame() {
        balls = new ArrayList<Ball>();
        blocks = new ArrayList<Block>();
        deleteBlocks = new ArrayList<Block>();
        lines = new ArrayList<Line>();
        action = null;
        
        loadGame();
        
        hud = new Hud(level, numBalls, score, coins);  
        screen = new GameScreen(0, width, hud.getTopLine(), hud.getBottomLine());  // left, right, top, bottom of play area
        launchPointBall = new Ball(screen.launchPoint);  // Pass in the PVector so that if the screen launchPoint is updated, so is this.
        
        generateBlocks();
    }
    
    void loadGame() {
        /*
         * Load the game state
         */
        level = 100;
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
            } else if (newX > screen.right) {
                // The line is going off the right of the screen
                newX = screen.right;
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
            } else if (newX > screen.right) {
                // The line is going off the right of the screen
                newX = screen.right;
                newY = (m * newX) + b;
            }
            
            return new PVector(newX, newY);
        }
    }
    
    void _get_shot_lines(int num_lines) {
        /*
         * Draw the shot lines. num_lines determines
         * how many additional lines to draw after the
         * first. Returns the lines to be drawn.
         */
        lines.clear();
         
        Line prevLine = new Line(
            screen.launchPoint,
            _extend_line_up(screen.launchPoint, new PVector(mouseX, mouseY))
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
                if (prevLine.endPoint.x < screen.middleX) {
                    nextPoint = new PVector(prevLine.endPoint.x - prevLine.run, prevLine.endPoint.y + prevLine.rise);
                } else {
                    nextPoint = new PVector(prevLine.endPoint.x - prevLine.run, prevLine.endPoint.y + prevLine.rise);
                }
                
                prevLine = new Line(prevLine.endPoint, _extend_line_down(prevLine.endPoint, nextPoint));
                lines.add(prevLine);
            } else if (prevLine.endPoint.x == 0) {
                // Ends at the left boundary
                PVector nextPoint, endPoint;
                if (prevLine.up) {
                    // Line direction is "up" the screen
                    nextPoint = new PVector(prevLine.endPoint.x + prevLine.run, prevLine.endPoint.y - prevLine.rise);
                    endPoint = _extend_line_up(prevLine.endPoint, nextPoint);
                } else {
                    // Line direction is "down" the screen
                    nextPoint = new PVector(prevLine.endPoint.x + prevLine.run, prevLine.endPoint.y - prevLine.rise);
                    endPoint = _extend_line_down(prevLine.endPoint, nextPoint);
                }
                
                prevLine = new Line(prevLine.endPoint, endPoint);
                lines.add(prevLine);
            } else if (prevLine.endPoint.x == screen.right) {
                // Ends at the right boundary
                PVector nextPoint, endPoint;
                if (prevLine.up) {
                    // Line direction is "up" the screen
                    nextPoint = new PVector(prevLine.endPoint.x - prevLine.run, prevLine.endPoint.y + prevLine.rise);
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
        int y = screen.top + int(width / 8.0);
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
 
        action = getAction(action);
        action.display();
         
        // Display the balls
        for (Ball ball: balls) {
            ball.display();
        }
        
        // Delete any blocks that should be deleted
        for (Block block : deleteBlocks) {
            blocks.remove(block);
        }
        deleteBlocks.clear();
        
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
        
        if (action != null) {
            action.handleInput(input);
            return;
        }
    }
}
