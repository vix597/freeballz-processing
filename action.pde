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
    
    PrepareShot() {
        super(GameAction.PREPARE_SHOT);
    }
    
    void actionStart() {}
    
    void actionActive() {
        // Handle aiming
        if (mouseY < mainGame.screen.launchY) {              
            if (DEBUG) {
                mainGame._get_shot_lines(100);
            } else {
                mainGame._get_shot_lines(0);
            }
            
            for (Line line : mainGame.lines) {
                line.display();
            }
        }
    }
    
    void handleInput(InputType input) {
        super.handleInput(input);
        if (isTouching) {
            nextState();
        }
        
        if (!isTouching && state == GameActionState.ACTION_ACTIVE) {
            // Release
            nextState();
        }
    }
}


class ExecuteShot extends Action {
    /*
     * Action to execute a shot.
     */
    
    private PVector velocity;
    private int deleteCount;
    
    ExecuteShot() {
        super(GameAction.EXECUTING_SHOT);
        velocity = null;
        deleteCount = 0;
    }
    
    void actionStart() {
        Line launchLine = mainGame.lines.get(0);
        
        if (launchLine.isVerticle()) {
            velocity = new PVector(0, MainGame.shotSpeed);
        } else {
            velocity = new PVector(abs(launchLine.run), abs(launchLine.rise) * -1);
            velocity.setMag(MainGame.shotSpeed);
            
            if (launchLine.left) {
                velocity.x = velocity.x * -1;
            }
        }
        
        for (int i = 0; i < mainGame.numBalls; i++) {
            Ball ball = new Ball(mainGame.screen.launchPoint.x, mainGame.screen.launchPoint.y);
            mainGame.balls.add(ball);
            ball.fire(velocity);  // Pass a ref to velocity. If we change this class' velocity, it will change all balls.
        }
        nextState();
    }
    
    void actionActive() {
        if (mainGame.balls.size() == 0) {
            println("shot complete");
            nextState();
        }
        
        ArrayList<Ball> deleteBalls = new ArrayList<Ball>();
    
        for (Ball ball: mainGame.balls) {
            ball.move();
            
            if (ball.isDelete) {
                deleteBalls.add(ball);
                deleteCount++;
            }
            
            if (deleteCount == 1) {
                // The first ball to land updates
                // the new launch 'x' position.
                mainGame.screen.launchPoint.x = ball.location.x;
            }
        }
        
        for (Ball ball: deleteBalls) {
            mainGame.balls.remove(ball);
        }
        
        deleteBalls.clear();
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
        
        nextState();
    }
    
    void actionActive() {
        nextState();
    }
}
