/*
 * coin.pde
 *
 * A collectible coin
 *
 * Created on: January 26, 2020
 *     Author: Sean LaPlante
 */
 

class Coin extends WorldObject {
  
    Coin(float x, float y) {
        super(x, y, true);
    }
    
    void display() {
        pushMatrix();
        noFill();
        stroke(237, 165, 16);
        strokeWeight(5);
        ellipse(location.x, location.y, BALL_RADIUS * 3, BALL_RADIUS * 3);
        popMatrix();
    }
}
