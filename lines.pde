/*
 * lines.pde
 *
 * Class for lines and shot lines
 *
 * Created on: January 12, 2020
 *     Author: Sean LaPlante
 */


class Line {
    /*
     * Handles holding information needed for a line
     */
    
    public PVector startPoint;
    public PVector endPoint;
    
    Line(float startX, float startY, float endX, float endY) {
        /*
         * Create a line from 4 points. The PVector objects are created
         * here.
         */
        startPoint = new PVector(startX, startY);
        endPoint = new PVector(endX, endY);
    }
    
    Line(PVector start, PVector end) {
        /*
         * Creates a line using 2 PVectors as reference.
         * If the provided PVector references are changed in
         * the calling environment, the line will be changed.
         */
        startPoint = start;
        endPoint = end;
    }
    
    private PVector getHeading() {
        /*
         * Get the heading
         */
        PVector heading = PVector.sub(endPoint, startPoint);
        return heading.normalize();
    }
    
    boolean isVerticle() {
        return startPoint.x == endPoint.x;
    }
    
    void display() {
        pushMatrix();
        stroke(255);
        strokeWeight(1);
        line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
        popMatrix();
    }
}


class ShotLines {
    /*
     * Manages the shot lines for the game
     */
     
    public Line launchLine;
    private int numLines;
 
    ShotLines(int n) {
        numLines = n;
    }
    
    void display() {
        // Set the launch line, used by MainGame
        launchLine = new Line(ENGINE.screen.launchPoint.x, ENGINE.screen.launchPoint.y, mouseX, mouseY);
        
        Ball ghostBall = new Ball(ENGINE.launchPointBall.location.copy());
        ghostBall.isSimulated = true;  // Won't destroy blocks or pickup items
        PVector velocity = launchLine.getHeading();
        velocity.setMag(SHOT_SPEED);
        ghostBall.fire();
        ghostBall.setVelocity(velocity);
        for (int i = 0; i < 600; i++) {
            if (ghostBall.bounceCount >= numLines) {
                break;
            }

            ghostBall.move();
            if (i % 4 == 0 && !ghostBall.isDone) {
                ghostBall.display();
            }
        }
    }
}
