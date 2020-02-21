/*
 * action.pde
 *
 * A base class for a game action
 *
 * Created on: January 15, 2020
 *     Author: Sean LaPlante
 */


enum GameAction {
    PREPARE_SHOT,
    EXECUTING_SHOT,
    CHANGE_LEVEL
}


enum GameActionState {
    ACTION_START,
    ACTION_ACTIVE,
    ACTION_COMPLETE
}


Action getAction(Action currentAction) {
    if (currentAction == null) {
        return new PrepareShot();
    }
    
    if (currentAction.state != GameActionState.ACTION_COMPLETE) {
        return currentAction;
    }
    
    switch(currentAction.action) {
    case PREPARE_SHOT:
        return new ExecuteShot();
    case EXECUTING_SHOT:
        return new ChangeLevel();
    case CHANGE_LEVEL:
        return new PrepareShot();
    }
    
    return new PrepareShot();
}


abstract class Action {
    /*
     * Generic base class for a game action
     */
    public final GameAction action;
    protected GameActionState state;
    protected boolean isTouching;
    protected MainGame engine;

    Action(GameAction a) {
        action = a;
        state = GameActionState.ACTION_START;
        isTouching = false;
    }
    
    public abstract void actionStart();
    public abstract void actionActive();
    
    void display() {
        switch(state) {
        case ACTION_START:
            actionStart();
            break;
        case ACTION_ACTIVE:
            actionActive();
            break;
        case ACTION_COMPLETE:
            break;
        }
    }
    
    void nextState() {
        /*
         * Bump up to the next state of the action
         */
        switch(state) {
        case ACTION_START:
            state = GameActionState.ACTION_ACTIVE;
            break;
        case ACTION_ACTIVE:
            state = GameActionState.ACTION_COMPLETE;
            break;
        case ACTION_COMPLETE:
            // Do nothing, last state.
            break;
        }
    }
    
    void resetAction() {
        state = GameActionState.ACTION_START;
    }
    
    void handleInput(InputType input) {
        switch(input) {
        case TOUCH_START:
            isTouching = true;
            break;
        case TOUCH_END:
            isTouching = false;
            break;
        case TOUCH_MOVE:
            break;
        }
    }
}


class PrepareShot extends Action {
    /*
     * Action to prepare a shot. Draws shot lines, etc...
     */
    private boolean validAngle;
    private ShotLines shotLines;
    
    PrepareShot() {
        super(GameAction.PREPARE_SHOT);
        
        validAngle = false;
        
        // Initialize our handler for shot lines
        if (DEBUG) {
            shotLines = new ShotLines(100, true);
        } else {
            shotLines = new ShotLines(0, false);
        }
    }
    
    void actionStart() {}
    
    void actionActive() {
        // Handle aiming
 
        if (mouseY < (ENGINE.screen.launchY - BALL_RADIUS)) {              
            shotLines.display();
            validAngle = true;
        } else {
            validAngle = false;
        }
    }
    
    void handleInput(InputType input) {
        super.handleInput(input);
        if (isTouching) {
            nextState();
        }
        
        if (!isTouching && state == GameActionState.ACTION_ACTIVE) {
            // Release
            if (!validAngle) {
                resetAction();
                return;
            }
            
            if (shotLines.lines.size() > 0) {  // A quick touch could break this.
                ENGINE.launchLine = shotLines.lines.get(0);
                nextState();
            } else {
                println("WARNING: Touched too fast. Reset!");
                resetAction();
            }
        }
    }
}


class ExecuteShot extends Action {
    /*
     * Action to execute a shot.
     */
    private float reqDist = BALL_RADIUS * 5;
    private PVector velocity;
    private boolean launchPosUpdated;
    private int doneCount;
    private float velocityMag;
    private Ball prevBall;
    
    public int launchCount;
    
    ExecuteShot() {
        super(GameAction.EXECUTING_SHOT);
        velocity = null;
        prevBall = null;
        doneCount = 0;
        launchCount = 1;
        launchPosUpdated = false;
        velocityMag = SHOT_SPEED;
    }
    
    void actionStart() {
        velocity = ENGINE.launchLine.getDistVec();
        velocity.setMag(SHOT_SPEED);
        
        for (int i = 0; i < ENGINE.hud.numBalls; i++) {
            Ball ball = new Ball(ENGINE.screen.launchPoint.x, ENGINE.screen.launchPoint.y);
            ball.setVelocity(velocity);
            ENGINE.balls.add(ball);
        }
        
        nextState();
    }
    
    void actionActive() {
        int deleteCount = 0;
      
        if (ENGINE.balls.size() == 0) {
            println("shot complete");
            nextState();
            return;
        }
        
        if (prevBall != null && prevBall.distTraveled >= reqDist) {
            prevBall = null;
            launchCount++;
        }
      
        if (launchCount == 1) {
            ENGINE.launchPointBall.isVisible = false;
        }
      
        int i = 0;
        for (Ball ball : ENGINE.balls) {
            if (!ball.fired) {
                ball.fire();
            }
          
            ball.move();
            
            if (ball.isDone) {
                doneCount++;
            }
            
            if (doneCount == 1 && !launchPosUpdated) {
                // The first ball to land updates
                // the new launch 'x' position.
                ENGINE.screen.launchPoint.x = ball.location.x;
                launchPosUpdated = true;
                ball.isDelete = true;
                ENGINE.launchPointBall.isVisible = true;
            }
            
            if (ball.isDelete) {
                ENGINE.deleteBall(ball);
                deleteCount++;
            }
            
            i++;

            if (i >= launchCount) {
                prevBall = ball;
                break;            
            }
        }
                 
        launchCount -= deleteCount;
    }
    
    void handleInput(InputType input) {
        super.handleInput(input);
        
        if (input == InputType.TOUCH_END && state == GameActionState.ACTION_ACTIVE) {
            // SPEED UP!
            velocityMag += SHOT_SPEED;
            for (Ball ball : ENGINE.balls) {
                ball.setVelocityMag(velocityMag);
            }
        }
    }
}


class ChangeLevel extends Action {
    /*
     * Action to change to the next level.
     */
    
    ChangeLevel() {
        super(GameAction.CHANGE_LEVEL);
    }
    
    void actionStart() {
        /*
         * Increment the level
         */
        ENGINE.hud.level++;
        println("Moving to level: ", ENGINE.hud.level);
        ENGINE.world.generateNewRow();
        ENGINE.hud.saveGame(false);
        nextState();
    }
    
    void actionActive() {
        /*
         * Execute the level change animation and generate blocks
         */
        nextState();
    }
}
