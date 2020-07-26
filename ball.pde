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
     
    private float left;          // x value of left side of ball (same as location.x - radius)
    private float right;         // x value of right side of block (same as location.x + radius)
    private float top;           // y position of top of block (same as location.y - radius)
    private float bottom;        // y position of bottom of block (same as location.y + radius)
    private float radius;        // the distance from the middle to the edge of the circle
    private PVector middle;      // x, y coords of the middle of the ball (same as location)
    private float bWidth;        // diameter of the ball
    
    PickupBall(float x, float y) {
        super(x, y, true, ObjectType.PICKUP_BALL);
        bWidth = PICKUP_BALL_RADIUS * 2;
        radius = PICKUP_BALL_RADIUS;
        left = location.x - radius;
        right = location.x + radius;
        top = location.y - radius;
        bottom = location.y + radius;
        middle = location;  // Same thing just store ref
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
        ellipse(location.x, location.y, (BALL_RADIUS * 2), (BALL_RADIUS * 2));
        
        strokeWeight(5);
        stroke(255);
        noFill();
        ellipse(location.x, location.y, bWidth, bWidth);
        
        popMatrix();
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
        if (!fired) {
            return;
        }
      
        // Get distances between the objects
        PVector distVec = PVector.sub(other.getMiddle(), location);  // Location for ellipse is middle
        float dist = distVec.mag();
    
        // Minimum distance before they are touching
        float minDistance = BALL_RADIUS + other.getRadius();
    
        if (dist < minDistance) {
            // Collision is impossible until this is true.
            boolean above = false, below = false, left = false, right = false, inside = false;
            
            // Get the leading point on the circle
            PVector radiusVec = velocity.setMag(null, BALL_RADIUS);
            PVector edgePoint = PVector.add(location, radiusVec);
            
            if (location.x >= other.getRight()) {
                // ball is on the right of the block
                edgePoint = new PVector(location.x - BALL_RADIUS, location.y);
                right = true;
            } else if (location.x <= other.getLeft()) {
                // ball is on the left of the block
                edgePoint = new PVector(location.x + BALL_RADIUS, location.y);
                left = true;
            } else if (location.y >= other.getBottom()) {
                // ball is underneith
                edgePoint = new PVector(location.x, location.y - BALL_RADIUS);
                below = true;
            } else if (location.y <= other.getTop()) {
                // ball is above
                edgePoint = new PVector(location.x, location.y + BALL_RADIUS);
                above = true;
            } else {
                inside = true;
            }
            
            if (edgePoint.x > other.getLeft() && edgePoint.x < other.getRight() && edgePoint.y > other.getTop() && edgePoint.y < other.getBottom()) {
                //
                // We collided - Decide what to do.
                //
                
                if (!other.isCollectible) {
                    // It's not collectible. Bounce off it.
                
                    if (left || right) {
                        velocity.x *= -1;
                    } else if (above || below) {
                        velocity.y *= -1;
                    } else if (inside) {
                      velocity.x *= -1;
                      velocity.y *= -1;
                    }
                    
                    if (left) {
                        location.x = other.getLeft() - BALL_RADIUS;
                    } else if (right) {
                        location.x = other.getRight() + BALL_RADIUS;
                    } else if (above) {
                        location.y = other.getTop() - BALL_RADIUS;
                    } else if (below) {
                        location.y = other.getBottom() + BALL_RADIUS;
                    }
                }
                
                other.collide();
            } 
        }
    }
}
