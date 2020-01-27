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
    
    private ShotLines shotLines;
    
    PrepareShot() {
        super(GameAction.PREPARE_SHOT);
        
        // Initialize our handler for shot lines
        if (DEBUG) {
            shotLines = new ShotLines(100);
        } else {
            shotLines = new ShotLines(0);
        }
    }
    
    void actionStart() {}
    
    void actionActive() {
        // Handle aiming
        if (mouseY < mainGame.screen.launchY) {              
            shotLines.display();
        }
    }
    
    void handleInput(InputType input) {
        super.handleInput(input);
        if (isTouching) {
            nextState();
        }
        
        if (!isTouching && state == GameActionState.ACTION_ACTIVE) {
            // Release
            mainGame.launchLine = shotLines.lines.get(0);
            nextState();
        }
    }
}


class ExecuteShot extends Action {
    /*
     * Action to execute a shot.
     */
    private float reqDist = BALL_RADIUS * 4;
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
        velocity = mainGame.launchLine.getDistVec();
        velocity.setMag(SHOT_SPEED);
        
        for (int i = 0; i < mainGame.hud.numBalls; i++) {
            Ball ball = new Ball(mainGame.screen.launchPoint.x, mainGame.screen.launchPoint.y);
            ball.setVelocity(velocity);
            mainGame.balls.add(ball);
        }
        
        nextState();
    }
    
    void actionActive() {
        int deleteCount = 0;
      
        if (mainGame.balls.size() == 0) {
            println("shot complete");
            nextState();
            return;
        }
        
        if (prevBall != null && prevBall.distTraveled >= reqDist) {
            prevBall = null;
            launchCount++;
        }
      
        if (launchCount == 1) {
            mainGame.launchPointBall.isVisible = false;
        }
      
        int i = 0;
        for (Ball ball : mainGame.balls) {
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
                mainGame.screen.launchPoint.x = ball.location.x;
                launchPosUpdated = true;
                ball.isDelete = true;
                mainGame.launchPointBall.isVisible = true;
            }
            
            if (ball.isDelete) {
                mainGame.deleteBall(ball);
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
            for (Ball ball : mainGame.balls) {
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
        mainGame.hud.level++;
        println("Moving to level: ", mainGame.hud.level);
        nextState();
    }
    
    void actionActive() {
        /*
         * Execute the level change animation and generate blocks
         */
        nextState();
    }
}
