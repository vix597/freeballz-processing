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
        rect(location.x, location.y, bWidth, bWidth, EXPLODE_PART_RADIUS);
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

    protected float left;          // x value of left side of block (same as location.x)
    protected float right;         // x value of right side of block (same as location.x + bWidth)
    protected float top;           // y position of top of block (same as location.y)
    protected float bottom;        // y position of bottom of block (same as location.y + bWidth)
    protected float radius;        // the distance from the middle to a corner
    protected PVector middle;      // x, y coords of the middle of the block
    protected float bWidth;        // Width and height of block (it's a square)

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
    
    boolean collide(Ball ball) {
        /*
         * Called to check for an handle collisions
         */
        if (!isCircleInRect(ball.location, BALL_RADIUS, this.location, this.bWidth, this.bWidth)) {
            return false;  // Not colliding
        }
        
        if (ball.location.x >= getRight()) {
            // ball is on the right
            ball.velocity.x *= -1;
            ball.location.x = getRight() + BALL_RADIUS;
        } else if (ball.location.x <= getLeft()) {
            // ball is on the left
            ball.velocity.x *= -1;
            ball.location.x = getLeft() - BALL_RADIUS;
        } else if (ball.location.y >= getBottom()) {
            // ball is under
            ball.velocity.y *= -1;
            ball.location.y = getBottom() + BALL_RADIUS;
        } else if (ball.location.y <= getTop()) {
            // ball is above
            ball.velocity.y *= -1;
            ball.location.y = getTop() - BALL_RADIUS;
        } else {
            // ball is somehow inside the object (maybe moving too fast)
            ball.velocity.x *= -1;
            ball.velocity.y *= -1;
            ball.location.sub(ball.velocity);  // Undo the last movement
        }
        
        if (!ball.isSimulated) {
            handleCollision();
        }
        return true;
    }
    
    protected void handleCollision() {
        /*
         * Called from collide() if a collision occurs to decrement point
         * values and update the block's color
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
        drawShape();
        popMatrix();
    }
    
    protected void drawShape() {
        /*
         * Method that can be overriden. Used to draw the actual shape
         */
        // We want to display the block in the middle of the hit box
        // and a little smaller so that it looks like there are gaps
        // between blocks.
        rect(location.x + spacingX, location.y + spacingY, bWidth - spacingX, bWidth - spacingY, BLOCK_RADIUS);
    }
    
    private void displayText() {
        /*
         * Write the remaining hit points on the block
         */
        String remHitPointsStr = str(remHitPoints);
        float textSize = SMALL_TEXT_SIZE;
         
        pushMatrix();
        fill(0);
        textAlign(CENTER, CENTER);
        
        if (remHitPointsStr.length() > 3) {
            int multiplier = remHitPointsStr.length() - 3;
            textSize -= (4 * multiplier);
        }
        
        if (textSize < 6) {
            // Limit how small the text could get
            textSize = 6;
        }
        
        textSize(textSize);
        text(str(remHitPoints), middle.x, middle.y);
        popMatrix();
    }
}
