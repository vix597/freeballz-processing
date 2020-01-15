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

    private PVector velocity;
    private PVector location;
    private static final int radius = 12;
    
    Ball(PVector loc) {
        location = new PVector(loc.x, loc.y);
        velocity = new PVector(0, 0);
    }
    
    void display() {
        /*
         * Called from the main draw method. Used to display the ball
         * on the screen.
         */
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
        location.add(velocity);
        checkBoundaryCollision();
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
          location.y = mainGame.screen.bottom - radius;
          velocity.y *= -1;
        } else if (location.y < mainGame.screen.top + radius) {
          location.y = mainGame.screen.top + radius;
          velocity.y *= -1;
        }
    }
}
