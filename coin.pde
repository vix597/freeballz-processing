/*
 * coin.pde
 *
 * A collectible coin
 *
 * Created on: January 26, 2020
 *     Author: Sean LaPlante
 */
 

class Coin extends WorldObject {
    /*
     * A coin that can be collected
     */
      
    private float left;          // x value of left side of the coin (same as location.x - radius)
    private float right;         // x value of right side of the coin (same as location.x + radius)
    private float top;           // y position of top of the coin (same as location.y - radius)
    private float bottom;        // y position of bottom of the coin (same as location.y + radius)
    private float radius;        // the distance from the middle to the edge of the coin
    private PVector middle;      // x, y coords of the middle of the coin (same as location)
    private float bWidth;        // diameter of the coin
  
    Coin(float x, float y) {
        super(x, y, true, ObjectType.COIN);
        bWidth = COIN_RADIUS * 2.0;
        radius = COIN_RADIUS;
        left = location.x - radius;
        right = location.x + radius;
        top = location.y - radius;
        bottom = location.y + radius;
        middle = location;  // Same thing just store ref
    }
    
    void display() {
        pushMatrix();
        noFill();
        stroke(237, 165, 16);
        strokeWeight(5);
        ellipse(location.x, location.y, bWidth, bWidth);
        popMatrix();
    }
    
    void slide(float amount) {
        super.slide(amount);
        top += amount;
        bottom += amount;
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
    
    boolean isPointInObject(PVector point) {
        /*
         * Called to determine if the x,y of the provided 'point'
         * is inside the bounds of this object. Used for collision
         * detection.
         */
        return false;
    }
    
    void collide() {
        /*
         * Called when a ball collides with this object
         */
        ENGINE.world.deleteCoin(this);
    }
}
