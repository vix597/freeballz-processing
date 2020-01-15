/*
 * block.pde
 *
 * Class for a Block
 *
 *  Created on: January 11, 2020
 *      Author: Sean LaPlante
 */


class Block {
    /*
     * A block with hit points, size, and location
     */
    public float left;        // x value of left side of block (same as location.x)
    public float right;       // x value of right side of block (same as location.x + bWidth)
    public float top;         // y position of top of block (same as location.y)
    public float bottom;      // y position of bottom of block (same as location.y + bWidth)
    public PVector location;  // x, y coords of top left corner of block
    public PVector middle;    // x, y coords of the middle of the block
    public float bWidth;      // Width and height of block (it's a square)
    public int hitPoints;     // Number of points this block is worth
    public int remHitPoints;  // Hit points remaining
    
    Block(PVector loc, int points, float _bWidth) {
        bWidth = _bWidth;
        location = loc;
        hitPoints = points;
        remHitPoints = points;
        left = location.x;
        right = location.x + bWidth;
        top = location.y;
        bottom = location.y + bWidth;
        middle = new PVector(location.x + (bWidth / 2.0), location.y + (bWidth / 2.0));
    }
    
    color getColor() {
        /*
         * Get the current color of the block based on it's current remaining hit points.
         * starting values of r,g,b are 28, 230, and 88 respectively.
         */
        if (remHitPoints < 10) {
        
        }
        return color(
            int(28 + (remHitPoints)),
            int(230 - (remHitPoints / 1.2)),
            int(88 - (remHitPoints / 3.5))
        );
    }
    
    void _displayBlock() {
        /*
         * Display the block
         */
        pushMatrix();
        fill(getColor());
        stroke(100);
        rect(location.x, location.y, bWidth, bWidth);
        popMatrix();
    }
    
    void _displayText() {
        /*
         * Write the remaining hit points on the block
         */
        pushMatrix();
        fill(0);
        textAlign(CENTER);
        textSize(26);
        text(str(remHitPoints), middle.x, middle.y + 10);  // +10 to make the number more "centered"
        popMatrix();
    }
    
    void display() {
        /*
         * Called from the main draw method. Used to display the block
         * on the screen.
         */
        _displayBlock();
        _displayText();
    }
}
