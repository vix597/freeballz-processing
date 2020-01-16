/*
 * line.pde
 *
 * Class for a Line
 *
 *  Created on: January 12, 2020
 *      Author: Sean LaPlante
 */
 
 
class Line {
    /*
     * Handles drawing a line. Supports collision detection with blocks.
     */
     
    public PVector startPoint;
    public PVector endPoint;
    
    public float slope;
    public float rise;
    public float run;
     
    // Direction components
    public boolean up;
    public boolean down;
    public boolean left;
    public boolean right;
     
    Line(PVector start, PVector end) {
        up = false;
        down = false;
        left = false;
        right = false;
        
        startPoint = start;
        endPoint = end;
        
        if (isVerticle()) {
            rise = 0;
            run = 0;
            slope = 0;
            up = true;
        } else {
            rise = startPoint.y - endPoint.y;
            run = startPoint.x - endPoint.x;
            slope = rise / run;
            
            if (rise > 0) {
                up = true;
            } else {
                down = true;
            }
            
            if (run > 0) {
                left = true;
            } else {
                right = true;
            }
        }
    }
        
    boolean isVerticle() {
        /*
         * Determine if the line is a verticle line
         */
        return startPoint.x == endPoint.x;
    }
        
    void display() {
        pushMatrix();
        stroke(255);
        line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
        popMatrix();
    }
}
