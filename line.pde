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
     
    Line(PVector start, PVector end) {
        startPoint = start;
        endPoint = end;
        
        if (isVerticle()) {
            rise = 0;
            run = 0;
            slope = 0;
        } else {
            rise = abs(startPoint.y - endPoint.y);
            run = abs(startPoint.x - endPoint.x);
            slope = rise / run;
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
