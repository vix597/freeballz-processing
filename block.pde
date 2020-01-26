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
        float xspeed = random(-3, 3);
        float yspeed = random(-3, 3);
        bWidth = EXPLODE_PARTICLE_BWIDTH;
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
        rect(location.x, location.y, bWidth, bWidth);
        popMatrix();
        
        alpha -= EXPLODE_ALPHA_CHANGE;
    }
}


class Block {
    /*
     * A block with hit points, size, and location
     */
    public float left;          // x value of left side of block (same as location.x)
    public float right;         // x value of right side of block (same as location.x + bWidth)
    public float top;           // y position of top of block (same as location.y)
    public float bottom;        // y position of bottom of block (same as location.y + bWidth)
    public float radius;        // the distance from the middle to a corner
    public PVector location;    // x, y coords of top left corner of block
    public PVector middle;      // x, y coords of the middle of the block
    public float bWidth;        // Width and height of block (it's a square)
    public int hitPoints;       // Number of points this block is worth
    public int remHitPoints;    // Hit points remaining
    public boolean isDelete;    // Whether or not the block is dead
    public boolean isExplode;   // Whether or not the block is exploding
    public float spacingX;      // Number of pixels to use as spacing to the left and right of the block
    public float spacingY;      // Number of pixels to use as spacing above and below the block
    
    private int explodeFrames;                     // Number of frames required for explosion
    private int explodeFrameCount;                 // Number of frames executed so far in explode animation
    private ArrayList<Particle> explodeParticles;  // The particles
    private int maxExplodeParticles;               // Number of particles to create for an explosion
    private float maxHSB;                          // Max for hue saturation brightness
    
    Block(PVector loc, int points) {
        explodeFrames = int(FRAME_RATE / 3.0);
        bWidth = BLOCK_WIDTH;
        location = loc;
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
        maxExplodeParticles = EXPLODE_PARTICLE_COUNT;
        maxHSB = random(1, 100) + (hitPoints * random(1.0, 1.3));

        explodeParticles = new ArrayList<Particle>(maxExplodeParticles);

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
        } else if (isExplode) {
            explode();
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
            isExplode = true;
            colorMode(HSB, maxHSB, maxHSB, 100);
            for (int i =0; i < maxExplodeParticles; i++) {
                explodeParticles.add(new Particle(middle.x, middle.y, getColor()));
            }
            colorMode(RGB, 255, 255, 255);
        }
    }
    
    private void explode() {
        /*
         * Internal method called when the hit-points reach 0
         */
        if (explodeFrameCount >= explodeFrames) {
            isDelete = true;
            explodeParticles.clear();
            mainGame.deleteBlock(this);
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
        colorMode(HSB, maxHSB, maxHSB, 100);
        fill(getColor());
        colorMode(RGB, 255, 255, 255);
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
        textAlign(CENTER, CENTER);
        textSize(BLOCK_FONT);
        text(str(remHitPoints), middle.x, middle.y);
        popMatrix();
    }
}
