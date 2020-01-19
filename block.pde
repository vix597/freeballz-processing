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
    public float radius;      // the distance from the middle to a corner
    public PVector location;  // x, y coords of top left corner of block
    public PVector middle;    // x, y coords of the middle of the block
    public float bWidth;      // Width and height of block (it's a square)
    public int hitPoints;     // Number of points this block is worth
    public int remHitPoints;  // Hit points remaining
    public boolean isDelete;  // Whether or not the block is dead
    public int spacingX;      // Number of pixels to use as spacing to the left and right of the block
    public int spacingY;      // Number of pixels to use as spacing above and below the block
    
    Block(PVector loc, int points, float _bWidth, int _spacingX, int _spacingY) {
        bWidth = _bWidth;
        location = loc;
        hitPoints = points;
        remHitPoints = points;
        left = location.x;
        right = location.x + bWidth;
        top = location.y;
        bottom = location.y + bWidth;
        middle = new PVector(location.x + (bWidth / 2.0), location.y + (bWidth / 2.0));
        isDelete = false;
        spacingX = _spacingX;
        spacingY = _spacingY;

        PVector distVec = PVector.sub(middle, location);
        radius = distVec.mag();
    }
    
    void display() {
        /*
         * Called from the main draw method. Used to display the block
         * on the screen.
         */
        if (isDelete) {
            return;
        }
         
        displayBlock();
        displayText();
    }
    
    void hit() {
        /*
         * Called when a ball collides with the block
         */
        remHitPoints--;
        if (remHitPoints == 0) {
            isDelete = true;
            mainGame.deleteBlocks.add(this);
        }
    }
    
    private color getColor() {
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
    
    private void displayBlock() {
        /*
         * Display the block
         */
        pushMatrix();
        fill(getColor());
        stroke(100);
        
        // We want to display the block in the middle of the hit box
        // and a little smaller so that it looks like there are gaps
        // between blocks.
        rect(location.x + spacingX, location.y + spacingY, bWidth - spacingX, bWidth - spacingY);

        popMatrix();
    }
    
    private void displayText() {
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
}
