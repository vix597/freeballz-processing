/*
 * ball.pde
 *
 * Class for a Ball
 *
 *  Created on: December 23, 2019
 *      Author: Sean LaPlante
 */


class Ball {
    /*
     * A ball with velocity, direction, size, and location
     */

    public boolean isDelete;

    private PVector velocity;  // Location for an ellipse is the center of the ellipse.
    private PVector location;
    
    public static final int radius = 12;
    
    Ball(PVector loc) {
        /*
         * This constructor takes a PVector and stores the reference.
         * Any updates to the PVector from the caller will happen here too.
         */
        location = loc;
        velocity = new PVector(0, 0);
        isDelete = false;
    }
    
    Ball(float x, float y) {
      /*
       * This constructor takes an x, y coordinate and constructs a local
       * PVector.
       */
       location = new PVector(x, y);
       velocity = new PVector(0, 0);
       isDelete = false;
    }
    
    void display() {
        /*
         * Called from the main draw method. Used to display the ball
         * on the screen.
         */
        if (isDelete) {
            return;
        }

        pushMatrix();
        fill(255);
        ellipse(location.x, location.y, (radius * 2), (radius * 2));
        popMatrix();
    }
    
    void fire(PVector vel) {
        /*
         * Set the balls velocity
         */
        velocity = vel;
    }
    
    void move() {
        /*
         * Called to add velocity to the ball
         */        
        if (isDelete) {
            return;
        }
         
        location.add(velocity);
        checkBoundaryCollision();
        for (Block block : mainGame.blocks) {
            if (!block.isDelete) {
                checkCollision(block);
            }
        }
    }
    
    void checkBoundaryCollision() {
        /*
         * Check for collision with the screen boundary
         */
        if (location.x > mainGame.screen.right - radius) {
          location.x = mainGame.screen.right - radius;
          velocity.x *= -1;
        } else if (location.x < radius) {
          location.x = radius;
          velocity.x *= -1;
        } else if (location.y > mainGame.screen.bottom - radius) {
          isDelete = true;  // Balls die at the bottom of the play area
        } else if (location.y < mainGame.screen.top + radius) {
          location.y = mainGame.screen.top + radius;
          velocity.y *= -1;
        }
    }
    
    void checkCollision(Block other) {
        /*
         * Check for a collision with a block
         */
      
        // Get distances between the objects
        PVector distVec = PVector.sub(other.middle, location);  // Location for ellipse is middle
        float dist = distVec.mag();
    
        // Minimum distance before they are touching
        float minDistance = radius + other.radius;
    
        if (dist < minDistance) {
            // Collision is impossible until this is true.
            boolean above = false, below = false, left = false, right = false;
            
            // Get the leading point on the circle
            PVector radiusVec = velocity.setMag(null, radius);
            PVector edgePoint = PVector.add(location, radiusVec);
            
            if (location.x > other.right) {
                // ball is on the right of the block
                edgePoint = new PVector(location.x - radius, location.y);
                right = true;
            } else if (location.x < other.left) {
                // ball is on the left of the block
                edgePoint = new PVector(location.x + radius, location.y);
                left = true;
            } else if (location.y > other.bottom) {
                // ball is underneith
                edgePoint = new PVector(location.x, location.y - radius);
                below = true;
            } else if (location.y < other.top) {
                // ball is above
                edgePoint = new PVector(location.x, location.y + radius);
                above = true;
            }
            
            if (edgePoint.x > other.left && edgePoint.x < other.right && edgePoint.y > other.top && edgePoint.y < other.bottom) {
                if (left || right) {
                    velocity.x *= -1;
                } else if (above || below) {
                    velocity.y *= -1;
                }
                
                if (left) {
                    location.x = other.left - radius;
                } else if (right) {
                    location.x = other.right + radius;
                } else if (above) {
                    location.y = other.top - radius;
                } else if (below) {
                    location.y = other.bottom + radius;
                }
                
                other.hit();
            } 
        }
    }
}
