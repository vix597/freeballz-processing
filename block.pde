/*
 * block.pde
 *
 * Class for a Block and Particle (for block explosion)
 *
 *  Created on: January 11, 2020
 *      Author: Sean LaPlante
 */


class Particle {
    /*
     * Explosion particle class used when a block is destroyed
     */
    color col;
    PVector location;
    PVector velocity;
    float bWidth;
    float alpha;

    Particle(float x, float y, color _col) {
        float xspeed = random(EXPLODE_PART_MIN_SPEED, EXPLODE_PART_MAX_SPEED);
        float yspeed = random(EXPLODE_PART_MIN_SPEED, EXPLODE_PART_MAX_SPEED);
        bWidth = EXPLODE_PART_BWIDTH;
        alpha = 300;

        col = _col;
        location = new PVector(x, y);
        velocity = new PVector(xspeed, yspeed);
    }
    
    void display() {
        location.add(velocity);

        pushMatrix();
        noStroke();
        fill(col, alpha);
        rect(location.x, location.y, bWidth, bWidth, 10);
        popMatrix();
        
        alpha -= EXPLODE_ALPHA_CHANGE;
    }
}


class Block extends WorldObject {
    /*
     * A block with hit points, size, and location
     */
    public int hitPoints;       // Number of points this block is worth
    public int remHitPoints;    // Hit points remaining
    public boolean isDelete;    // Whether or not the block is dead
    public boolean isExplode;   // Whether or not the block is exploding
    public float spacingX;      // Number of pixels to use as spacing to the left and right of the block
    public float spacingY;      // Number of pixels to use as spacing above and below the block

    private float left;          // x value of left side of block (same as location.x)
    private float right;         // x value of right side of block (same as location.x + bWidth)
    private float top;           // y position of top of block (same as location.y)
    private float bottom;        // y position of bottom of block (same as location.y + bWidth)
    private float radius;        // the distance from the middle to a corner
    private PVector middle;      // x, y coords of the middle of the block
    private float bWidth;        // Width and height of block (it's a square)

    private int explodeFrames;                     // Number of frames required for explosion
    private int explodeFrameCount;                 // Number of frames executed so far in explode animation
    private ArrayList<Particle> explodeParticles;  // The particles
    private int maxExplodeParticles;               // Number of particles to create for an explosion
    private float maxHSB;                          // Max for hue saturation brightness
    
    Block(PVector loc, int points) {
        super(loc, false, ObjectType.BLOCK);
        explodeFrames = int(FRAME_RATE / 3.0);
        bWidth = BLOCK_WIDTH;
        hitPoints = points;
        remHitPoints = points;
        left = location.x;
        right = location.x + bWidth;
        top = location.y;
        bottom = location.y + bWidth;
        middle = new PVector(location.x + (bWidth / 2.0), location.y + (bWidth / 2.0));
        isDelete = false;
        isExplode = false;
        spacingX = BLOCK_XY_SPACING;
        spacingY = BLOCK_XY_SPACING;
        maxExplodeParticles = EXPLODE_PART_COUNT;
        maxHSB = random(1, 100) + (hitPoints * random(1.0, 1.3));

        explodeParticles = new ArrayList<Particle>(maxExplodeParticles);

        PVector distVec = PVector.sub(middle, location);
        radius = distVec.mag();
    }
    
    void slide(float amount) {
        super.slide(amount);
        top += amount;
        bottom += amount;
        middle.y += amount;
    }
    
    void display() {
        /*
         * Called from the main draw method. Used to display the block
         * on the screen.
         */
        if (isDelete) {
            return;
        } else if (isExplode) {
            explode();
            return;
        }
         
        displayBlock();
        displayText();
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
         * Called when a ball collides with the block
         */
        remHitPoints--;
        if (remHitPoints == 0) {
            isExplode = true;
            colorMode(HSB, maxHSB, maxHSB, 100);
            for (int i =0; i < maxExplodeParticles; i++) {
                explodeParticles.add(new Particle(middle.x, middle.y, getColor()));
            }
            colorMode(RGB, 255, 255, 255);
        }
    }
    
    boolean isBallInObject(Ball ball) {
        /*
         * Called to determine if the x,y of the provided 'point'
         * is inside the bounds of this object. Used for collision
         * detection.
         */
        return isCircleInRect(ball.location, BALL_RADIUS, this.location, this.bWidth, this.bWidth);
    }
    
    private void explode() {
        /*
         * Internal method called when the hit-points reach 0
         */
        if (explodeFrameCount >= explodeFrames) {
            isDelete = true;
            explodeParticles.clear();
            ENGINE.world.deleteBlock(this);
        }
        
        for (Particle p : explodeParticles) {
            p.display();
        }
        
        explodeFrameCount++;
    }
    
    private color getColor() {
        /*
         * Get the current color of the block based on it's current remaining hit points.
         */
        float hue = constrain((remHitPoints * 1.5), 10, maxHSB);
        float sat = constrain((hitPoints - (remHitPoints / 2)), 10, maxHSB);
        return color(hue, sat, 100);
    }
    
    private void displayBlock() {
        /*
         * Display the block
         */
        pushMatrix();
        noStroke();
        colorMode(HSB, maxHSB, maxHSB, 100);
        fill(getColor());
        colorMode(RGB, 255, 255, 255);
        
        // We want to display the block in the middle of the hit box
        // and a little smaller so that it looks like there are gaps
        // between blocks.
        rect(location.x + spacingX, location.y + spacingY, bWidth - spacingX, bWidth - spacingY, 2);

        popMatrix();
    }
    
    private void displayText() {
        /*
         * Write the remaining hit points on the block
         */
        pushMatrix();
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(SMALL_TEXT_SIZE);
        text(str(remHitPoints), middle.x, middle.y);
        popMatrix();
    }
}
