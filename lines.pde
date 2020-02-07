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
        
        distVec = PVector.sub(line.endPoint, line.startPoint);
        
        for (Block block : ENGINE.world.blocks) {
            if (!block.isDelete) {
                checkCollision(block);  // Recalculates endPoint appropriately
            }
        }
        
        distVec = PVector.sub(line.endPoint, line.startPoint);  // Get the distance vector for the line
    }
    
    void display() {
        for (Block block : ENGINE.world.blocks) {
            if (!block.isDelete) {
                checkCollision(block);
            }
        }
        line.display();
    }
    
    PVector getDistVec() {
        return distVec.copy();
    }
     
    private PVector linesIntersect(Line l1, Line l2) {
      /*
       * Check if line l1 intersects with line l2 and returns the first intersection PVector
       */
      float x1 = l1.startPoint.x;
      float x2 = l1.endPoint.x;
      float y1 = l1.startPoint.y;
      float y2 = l1.endPoint.y;
      float x3 = l2.startPoint.x;
      float x4 = l2.endPoint.x;
      float y3 = l2.startPoint.y;
      float y4 = l2.endPoint.y;

      // calculate the direction of the lines
      float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
      float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    
      // if uA and uB are between 0-1, lines are colliding
      if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    
        float intersectionX = x1 + (uA * (x2-x1));
        float intersectionY = y1 + (uA * (y2-y1));
    
        return new PVector(intersectionX, intersectionY);
      }
      
      return null;
    }
     
    private void checkCollision(Block other) {
        //
        // Get the lines 4 that make up the rect
        //
        PVector pt = null;
        boolean left = false, right = false, up = false, down = false;
        
        Line leftSide = new Line(
            other.location.x,
            other.location.y,
            other.location.x,
            other.location.y + other.getWidth()
        );
        Line rightSide = new Line(
            other.location.x + other.getWidth(),
            other.location.y,
            other.location.x + other.getWidth(),
            other.location.y + other.getWidth()
        );
        Line top = new Line(
            other.location.x,
            other.location.y,
            other.location.x + other.getWidth(),
            other.location.y
        );
        Line bottom = new Line(
            other.location.x,
            other.location.y + other.getWidth(),
            other.location.x + other.getWidth(),
            other.location.y + other.getWidth()
        );
        
        // Which direction is the line going
        if (distVec.y > 0) {
            down = true;
        } else {
            up = true;
        }
        
        if (distVec.x > 0) {
            right = true;
        } else {
            left = true;
        }
        
        if (up) {
            pt = linesIntersect(line, bottom);
            if (pt == null) {
                if (left) {
                    pt = linesIntersect(line, rightSide);
                }
                if (right) {
                    pt = linesIntersect(line, leftSide);
                }
            }
        }
        if (down) {
            pt = linesIntersect(line, top);
            
            if (pt == null) {
                if (left) {
                    pt = linesIntersect(line, rightSide);
                }
                if (right) {
                    pt = linesIntersect(line, leftSide);
                }
            }
        }
        
        if (pt == null) {
            return;
        }
        
        line.endPoint = pt;
    }

    private void extendLine() {
        /* 
         * Draw a line extended to the edge of the
         * screen based on a start and end point.
         */
        float x = line.startPoint.x;
        float y = line.startPoint.y;
        float x1 = line.endPoint.x;
        float y1 = line.endPoint.y;
        
        if (x == x1) {
            line.endPoint = new PVector(x1, ENGINE.screen.top);
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
                newX = (ENGINE.screen.top - b) / m;
                newY = ENGINE.screen.top;
            } else {
                newX = (ENGINE.screen.bottom - b) / m;
                newY = ENGINE.screen.bottom;
            }

            if (newX < 0) {
                // The line is going off the left of the screen
                newX = 0;
                newY = b;
            } else if (newX > ENGINE.screen.right) {
                // The line is going off the right of the screen
                newX = ENGINE.screen.right;
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
            ENGINE.screen.launchPoint.x,
            ENGINE.screen.launchPoint.y,
            mouseX,
            mouseY
        );
            
        lines.add(prevLine);  // We always get at least 1 line.
    
        for (int i = 0; i < numLines; i++) {
            if (prevLine.line.endPoint.y == ENGINE.screen.bottom) {
                break;  // Balls end at the bottom of the screen
            }
            
            if (prevLine.line.isVerticle()) {
                break;  // Don't bother if the line is verticle
            }
            
            PVector distVec = prevLine.getDistVec();
            
            if (prevLine.line.endPoint.x == ENGINE.screen.left || prevLine.line.endPoint.x == ENGINE.screen.right) {
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

    
    
