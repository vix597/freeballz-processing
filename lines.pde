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
        startPoint = new PVector(startX, startY);
        endPoint = new PVector(endX, endY);
    }
    
    boolean isVerticle() {
        return startPoint.x == endPoint.x;
    }
    
    void display() {
        pushMatrix();
        stroke(255);
        line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
        popMatrix();
    }
}
 
 
class ShotLine {
    /*
     * Handles drawing a line. Supports collision detection with blocks.
     * and maintains a direction with vectors.
     */
    public Line line;
    private PVector distVec;
     
    ShotLine(float startX, float startY, float endX, float endY) {
        line = new Line(startX, startY, endX, endY);
        extendLine();  // Recalulates endPoint appropriately
        
        for (Block block : mainGame.blocks) {
            if (!block.isDelete) {
                checkCollision(block);  // Recalculates endPoint appropriately
            }
        }
        
        distVec = PVector.sub(line.endPoint, line.startPoint);  // Get the distance vector for the line
    }
    
    void display() {
        for (Block block : mainGame.blocks) {
            if (!block.isDelete) {
                checkCollision(block);
            }
        }
        line.display();
    }
    
    PVector getDistVec() {
        return distVec.copy();
    }
     
    private void checkCollision(Block other) {
        /*
        Line left = new Line(other.location.x, other.location.y, other.location.x + other.bWidth, other.location.y + other.bWidth);
        Line right = new Line();
        Line top = new Line();
        Line bottom = new Line();
        float x1 = one.get_start().x;
        float y1 = one.get_start().y;
        float x2 = one.get_end().x;
        float y2 = one.get_end().y;
        
        float x3 = two.get_start().x;
        float y3 = two.get_start().y;
        float x4 = two.get_end().x;
        float y4 = two.get_end().y;
        
        float bx = x2 - x1;
        float by = y2 - y1;
        float dx = x4 - x3;
        float dy = y4 - y3;
       
        float b_dot_d_perp = bx * dy - by * dx;
       
        if(b_dot_d_perp == 0) return null;
       
        float cx = x3 - x1;
        float cy = y3 - y1;
       
        float t = (cx * dy - cy * dx) / b_dot_d_perp;
        if(t < 0 || t > 1) return null;
       
        float u = (cx * by - cy * bx) / b_dot_d_perp;
        if(u < 0 || u > 1) return null;
       
        return new PVector(x1+t*bx, y1+t*by);
        */
    }

    private void extendLine() {
        /* 
         * Draw a line extended to the edge of the
         * screen based on a start and end point.
         * Returns a vector of the calculated end point 
         * for the new line
         */
        float x = line.startPoint.x;
        float y = line.startPoint.y;
        float x1 = line.endPoint.x;
        float y1 = line.endPoint.y;
        
        if (x == x1) {
            line.endPoint = new PVector(x1, mainGame.screen.top);
        } else {
            // Otherwise the line is at an angle and we need to do maths
            // m = (y - y1)/(x - x1)
            float m = (y - y1) / (x - x1);
            // y = mx + b, solve for b: b = y - (m * x)
            float b = y - (m * x);
            
            // Then, y = mx + b solve for x: x = (y - b) / m
            float newX;
            float newY;
            if (y > y1) {
                newX = (mainGame.screen.top - b) / m;
                newY = mainGame.screen.top;
            } else {
                newX = (mainGame.screen.bottom - b) / m;
                newY = mainGame.screen.bottom;
            }

            if (newX < 0) {
                // The line is going off the left of the screen
                newX = 0;
                newY = b;
            } else if (newX > mainGame.screen.right) {
                // The line is going off the right of the screen
                newX = mainGame.screen.right;
                newY = (m * newX) + b;
            }
            
            line.endPoint = new PVector(newX, newY);
        }
    }
}


class ShotLines {
    /*
     * Manages the shot lines for the game
     */
     
    public ArrayList<ShotLine> lines;
    private int numLines;
     
    ShotLines(int n) {
        lines = new ArrayList<ShotLine>();
        numLines = n;
    }
    
    void display() {
        getShotLines();
        
        for (ShotLine line : lines) {
            line.display();
        }
    }
    
    private void getShotLines() {
        /*
         * Draw the shot lines. num_lines determines
         * how many additional lines to draw after the
         * first. Returns the lines to be drawn.
         */
        lines.clear();  // This is called in display, so clear on each call.
         
        ShotLine prevLine = new ShotLine(
            mainGame.screen.launchPoint.x,
            mainGame.screen.launchPoint.y,
            mouseX,
            mouseY
        );
            
        lines.add(prevLine);  // We always get at least 1 line.
    
        for (int i = 0; i < numLines; i++) {
            if (prevLine.line.endPoint.y == mainGame.screen.bottom) {
                break;  // Balls end at the bottom of the screen
            }
            
            if (prevLine.line.isVerticle()) {
                break;  // Don't bother if the line is verticle
            }
            
            PVector distVec = prevLine.getDistVec();
            
            if (prevLine.line.endPoint.x == mainGame.screen.left || prevLine.line.endPoint.x == mainGame.screen.right) {
                distVec.x *= -1;
            } else {
                distVec.y *= -1;
            }
            distVec.normalize();
            
            PVector endPoint = PVector.add(prevLine.line.endPoint, distVec);
            
            prevLine = new ShotLine(prevLine.line.endPoint.x, prevLine.line.endPoint.y, endPoint.x, endPoint.y);
            lines.add(prevLine);
        }
    }
}

    
    
