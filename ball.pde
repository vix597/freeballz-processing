/*
 * ball.pde
 *
 * Class for a Ball
 *
 *  Created on: December 23, 2019
 *      Author: Sean LaPlante
 */


class PickupBall extends WorldObject {
    /*
     * A new ball that can be collected
     */
    
    private float minRingRadius = 1.5;  // The min radius multiplier for the PICKUP_BALL_RADIUS
    private float maxRingRadius = 2.0;  // This is the max multiplier for the PICKUP_BALL_RADIUS
    private float pulseSpeed = 0.02;    // The speed the outer ring pulses at
    
    private float left;          // x value of left side of ball (same as location.x - radius)
    private float right;         // x value of right side of block (same as location.x + radius)
    private float top;           // y position of top of block (same as location.y - radius)
    private float bottom;        // y position of bottom of block (same as location.y + radius)
    private float radius;        // the distance from the middle to the edge of the circle
    private PVector middle;      // x, y coords of the middle of the ball (same as location)
    private float bWidth;        // diameter of the ball
    private float ringRadius;    // The current outer ring radius
    private int animDirection;   // Positive, pulse ring out. Negative, pulse ring in.
    
    PickupBall(float x, float y) {
        super(x, y, true, ObjectType.PICKUP_BALL);
        bWidth = PICKUP_BALL_RADIUS * 2;
        radius = PICKUP_BALL_RADIUS;
        left = location.x - radius;
        right = location.x + radius;
        top = location.y - radius;
        bottom = location.y + radius;
        middle = location;  // Same thing just store ref
        ringRadius = maxRingRadius;
    }
    
    void slide(float amount) {
        super.slide(amount);
        top += amount;
        bottom += amount;
    }
    
    void display() {
        pushMatrix();
        
        noStroke();
        fill(255);
        ellipse(location.x, location.y, PICKUP_BALL_RADIUS, PICKUP_BALL_RADIUS);
        
        strokeWeight(5);
        stroke(255);
        noFill();
        ellipse(location.x, location.y, PICKUP_BALL_RADIUS * ringRadius, PICKUP_BALL_RADIUS * ringRadius);
        
        popMatrix();
        
        //
        // Update for pulse animation
        //
        ringRadius += (pulseSpeed * animDirection);
        if (ringRadius >= maxRingRadius) {
            animDirection = -1;
            ringRadius = maxRingRadius;
        } else if (ringRadius <= minRingRadius) {
            animDirection = 1;
            ringRadius = minRingRadius;
        }        
    }
    
    float getLeft() {
        return left;
    }
    
    float getRight() {
        return right;
    }
    
    float getTop()  {
        return top;
    }
    
    float getBottom() {
        return bottom;
    }
    
    float getRadius() {
        return radius;
    }
    
    float getWidth() {
        return bWidth;
    }
    
    PVector getMiddle() {
        return middle;
    }
    
    boolean isBallInObject(Ball ball) {
        /*
         * Called to determine if the x,y of the provided 'point'
         * is inside the bounds of this object. Used for collision
         * detection.
         */
         return isCircleInCircle(ball.location, BALL_RADIUS, this.location, this.radius);
    }
    
    void collide() {
        /*
         * Called when a ball collides with this object
         */
        ENGINE.world.deletePickupBall(this);
        //
        // TODO - Animate collecting the ball
        //
    }
}


class Ball {
    /*
     * A ball with velocity, direction, size, and location
     */
    public boolean isDelete;
    public boolean isDone;
    public boolean isVisible;
    public boolean fired;
    public float distTraveled;

    private color col;
    private PVector velocity;  // Location for an ellipse is the center of the ellipse.
    private PVector location;
    
    Ball(PVector loc) {
        /*
         * This constructor takes a PVector and stores the reference.
         * Any updates to the PVector from the caller will happen here too.
         */
        location = loc;
        velocity = new PVector(0, 0);
        isDelete = false;
        isDone = false;
        fired = false;
        isVisible = true;
        distTraveled = 0;
        col = color(255);
    }
    
    Ball(float x, float y) {
      /*
       * This constructor takes an x, y coordinate and constructs a local
       * PVector.
       */
       location = new PVector(x, y);
       velocity = new PVector(0, 0);
       isDelete = false;
       fired = false;
       isDone = false;
       isVisible = true;
       distTraveled = 0;
       col = color(255);
    }
    
    void display() {
        /*
         * Called from the main draw method. Used to display the ball
         * on the screen.
         */
        if (isDelete || !isVisible) {
            return;
        }

        pushMatrix();
        noStroke();
        fill(col);
        ellipse(location.x, location.y, (BALL_RADIUS * 2), (BALL_RADIUS * 2));
        popMatrix();
    }
    
    void setVelocity(PVector vel) {
        /*
         * Set the ball's velocity
         */
        velocity = vel.copy();
    }
    
    void setVelocityMag(float mag) {
        /*
         * Used to speed up the play. Max speed cannot exceed
         * BALL_RADIUS * 1.25 for collision detection
         */ 
        if (mag >= (BALL_RADIUS * 1.25) - 1) {
            mag = (BALL_RADIUS * 1.25) - 1;
        }
        velocity.setMag(mag);
    }
    
    void fire() {
        /*
         * Set the ball's state to fired
         */
        fired = true;
    }
    
    void move() {
        /*
         * Called to add velocity to the ball
         */        
        if (isDelete) {
            return;
        } else if (isDone) {
            checkIsDelete();
            return;
        }
         
        distTraveled += velocity.mag();
        location.add(velocity);
        
        // Check for collision with the boundary
        checkBoundaryCollision();
        
        // Check for collision with objects
        for (Block block : ENGINE.world.blocks) {
            if (!block.isDelete && !block.isExplode) {
                checkCollision(block);
            }
        }
        
        for (PickupBall ball : ENGINE.world.pickupBalls) {
            checkCollision(ball);
        }
        
        for (Coin coin : ENGINE.world.coins) {
            checkCollision(coin);
        }
    }
    
    void checkIsDelete() {
        if (location.x == ENGINE.screen.launchPoint.x) {
            isDelete = true;
            return;
        } else if (velocity.x < 0 && location.x < ENGINE.screen.launchPoint.x) {
            isDelete = true;
            return;
        } else if (velocity.x > 0 && location.x > ENGINE.screen.launchPoint.x) {
            isDelete = true;
            return;
        }
        
        if (location.x > ENGINE.screen.launchPoint.x + (BALL_RADIUS * 2)) {
            velocity.x = BALL_RADIUS * -1;
            location.add(velocity);
        } else if (location.x < ENGINE.screen.launchPoint.x - (BALL_RADIUS * 2)) {
            velocity.x = BALL_RADIUS;
            location.add(velocity);
        } else {
            location.x = ENGINE.screen.launchPoint.x;
        }
    }
    
    void checkBoundaryCollision() {
        /*
         * Check for collision with the screen boundary
         */
        if (!fired) {
            return;
        }
         
        if (location.x > ENGINE.screen.right - BALL_RADIUS) {
          location.x = ENGINE.screen.right - BALL_RADIUS;
          velocity.x *= -1;
        } else if (location.x < BALL_RADIUS) {
          location.x = BALL_RADIUS;
          velocity.x *= -1;
        } else if (location.y > ENGINE.screen.bottom - BALL_RADIUS) {
          isDone = true;
          velocity.y = 0;
          velocity.x = 0;
          location.y = ENGINE.screen.launchPoint.y;
        } else if (location.y < ENGINE.screen.top + BALL_RADIUS) {
          location.y = ENGINE.screen.top + BALL_RADIUS;
          velocity.y *= -1;
        }
    }
    
    void checkCollision(WorldObject other) {
        /*
         * Check for a collision with a world object
         */
        if (!this.fired) {
            // Can't be colliding before we're fired
            return;
        }
        
        if (dist(other.getMiddle().x, other.getMiddle().y, this.location.x, this.location.y) > BALL_RADIUS + other.getRadius()) {
            // We're too far aways to even bother checking
            return;
        }
           
        if (!other.isBallInObject(this)) {
            // We're not colliding. Return.
            return;
        }
        
        if (other.isCollectible()) {
            // It's collectible so just call its collide method and return.
            // We don't bounce off collectible items.
            other.collide();
            return;
        }
       
        if (location.x >= other.getRight()) {
            // ball is on the right
            this.velocity.x *= -1;
            this.location.x = other.getRight() + BALL_RADIUS;
        } else if (location.x <= other.getLeft()) {
            // ball is on the left
            this.velocity.x *= -1;
            this.location.x = other.getLeft() - BALL_RADIUS;
        } else if (location.y >= other.getBottom()) {
            // ball is under
            this.velocity.y *= -1;
            location.y = other.getBottom() + BALL_RADIUS;
        } else if (location.y <= other.getTop()) {
            // ball is above
            this.velocity.y *= -1;
            location.y = other.getTop() - BALL_RADIUS;
        } else {
            // ball is somehow inside the object (maybe moving too fast)
            velocity.x *= -1;
            velocity.y *= -1;
            this.location.sub(this.velocity);  // Undo the last movement
        }
        
        other.collide();
    }
}
