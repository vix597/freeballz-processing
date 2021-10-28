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

    float getLength() {
        /*
         * Get the length of the line
         */
        return abs(PVector.sub(endPoint, startPoint).mag());
    }

    void setEndPoint(PVector ep) {
        /*
         * Set the line's end point and recalculate
         */
        endPoint = ep.copy();
    }

    boolean isVerticle() {
        /*
         * Return true if the line is straight up and down, false otherwise
         */
        return startPoint.x == endPoint.x;
    }

    PVector getNormal() {
        /*
         * Get the line perpendicular to this one
         */
        PVector tangent = new PVector(endPoint.y - startPoint.y, startPoint.x - endPoint.x);
        return tangent.normalize();
    }

    void display() {
        /*
         * Draw the line
         */
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

    ShotLine(float startX, float startY, float endX, float endY, boolean enableCollision) {
        line = new Line(startX, startY, endX, endY);

        if (enableCollision) {
            extendLineToScreenBoundary();  // Recalulates endPoint appropriately

            // If we're enabling collisions, check for them and update the end point
            for (Block block : ENGINE.world.blocks) {
                if (!block.isDelete) {
                    if (checkCollision(block)) {  // Recalculates endPoint appropriately
                        break;
                    }
                }
            }
        }
    }

    private PVector getHeading() {
        /*
         * Get the heading
         */
        PVector heading = PVector.sub(line.endPoint, line.startPoint);
        return heading.normalize();
    }

    void extend(float amount) {
        /*
         * Extend the line by amount
         */
        PVector heading = getHeading();
        PVector moveEndPoint = heading.mult(amount);
        line.setEndPoint(line.endPoint.add(moveEndPoint));
    }

    void shrink(float amount) {
        /*
         * Shorten the line by amount
         */
        PVector heading = getHeading();
        PVector moveEndPoint = heading.mult(amount);
        line.setEndPoint(line.endPoint.sub(moveEndPoint));
    }

    boolean isHeadingDown() {
        /*
         * True if the line's heading is in the down direction
         */
        return getHeading().y > 0;
    }

    boolean isHeadingUp() {
        /*
         * True if the line's heading is in the up direction
         */
        return getHeading().y < 0;
    }

    boolean isHeadingLeft() {
        /*
         * True if the line's heading is in the left direction
         */
        return getHeading().x > 0;
    }

    boolean isHeadingRight() {
        /*
         * True if the line's heading is in the right direction
         */
        return getHeading().x < 0;
    }

    void display() {
        line.display();
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

        return getLineInterectPoint(x1, y1, x2, y2, x3, y3, x4, y4);
    }

    private boolean lineIntersectsBlock(Line line, Block block) {
        /*
         * Wraps call to getLineIntersectPointWithRect
         */
        return lineIntersectsRect(
            line.startPoint.x, line.startPoint.y, line.endPoint.x,
            line.endPoint.y, block.location.x, block.location.y,
            block.bWidth, block.bWidth
        );
    }

    private PVector lineIntersectsBlockSide(Line line, Block block, BlockSide side) {
        float x1 = line.startPoint.x;
        float x2 = line.endPoint.x;
        float y1 = line.startPoint.y;
        float y2 = line.endPoint.y;
        float rx = block.location.x;
        float ry = block.location.y;
        float rw = block.bWidth;  // It's a square, don't need height.

        switch (side) {
        case BLOCK_LEFT:
            return getLineIntersectPointWithRectLeft(x1, y1, x2, y2, rx, ry, rw, rw);
        case BLOCK_RIGHT:
            return getLineIntersectPointWithRectRight(x1, y1, x2, y2, rx, ry, rw, rw);
        case BLOCK_TOP:
            return getLineIntersectPointWithRectTop(x1, y1, x2, y2, rx, ry, rw, rw);
        case BLOCK_BOTTOM:
            return getLineIntersectPointWithRectBottom(x1, y1, x2, y2, rx, ry, rw, rw);
        default:
            return null;
        }
    }

    private boolean checkCollision(Block other) {
        //
        // Get the 4 lines that make up the rect. Returns true on collision
        // since a line can't collide with more than one block. So stop checking.
        //
        PVector pt = null;
        boolean left = false, right = false, up = false, down = false;

        if (!lineIntersectsBlock(line, other)) {
            return false;
        }

        down = isHeadingDown();
        up = isHeadingUp();
        left = isHeadingLeft();
        right = isHeadingRight();

        if (up) {
            pt = lineIntersectsBlockSide(line, other, BlockSide.BLOCK_BOTTOM);
            if (pt == null) {
                if (left) {
                    pt = lineIntersectsBlockSide(line, other, BlockSide.BLOCK_RIGHT);
                }
                if (right) {
                    pt = lineIntersectsBlockSide(line, other, BlockSide.BLOCK_LEFT);
                }
            }
        }
        if (down) {
            pt = lineIntersectsBlockSide(line, other, BlockSide.BLOCK_TOP);

            if (pt == null) {
                if (left) {
                    pt = lineIntersectsBlockSide(line, other, BlockSide.BLOCK_RIGHT);
                }
                if (right) {
                    pt = lineIntersectsBlockSide(line, other, BlockSide.BLOCK_LEFT);
                }
            }
        }

        if (pt == null) {
            return false;
        }

        line.setEndPoint(pt);
        return true;
    }

    private void extendLineToScreenBoundary() {
        /*
         * Draw a line extended to the edge of the
         * screen based on a start and end point.
         */
        PVector collisionPoint = null;

        extend((width + height) * 2);  // This will ensure the line's end point is definetely off the screen no matter what

        // Now we find out where it intersects and set the end point.
        Line[] screenLines = {
            new Line(ENGINE.screen.left - 10, ENGINE.screen.top, ENGINE.screen.right + 10, ENGINE.screen.top),
            new Line(ENGINE.screen.left - 10, ENGINE.screen.bottom, ENGINE.screen.right + 10, ENGINE.screen.bottom),
            new Line(ENGINE.screen.left, ENGINE.screen.top - 10, ENGINE.screen.left, ENGINE.screen.bottom + 10),
            new Line(ENGINE.screen.right, ENGINE.screen.top - 10, ENGINE.screen.right, ENGINE.screen.bottom + 10)
        };

        // It can only be colliding with one
        for (Line screenLine : screenLines) {
            collisionPoint = linesIntersect(line, screenLine);
            if (collisionPoint != null) {
                line.setEndPoint(collisionPoint);
                break;
            }
        }
    }
}


class ShotLines {
    /*
     * Manages the shot lines for the game
     */

    public ArrayList<ShotLine> lines;
    private int numLines;
    private boolean enableCollision;

    ShotLines(int n, boolean c) {
        lines = new ArrayList<ShotLine>(n);
        numLines = n;
        enableCollision = c;
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
            mouseY,
            enableCollision
        );

        lines.add(prevLine);  // We always get at least 1 line.

        for (int i = 0; i < numLines; i++) {
            if (prevLine.line.endPoint.y == ENGINE.screen.bottom) {
                break;  // Balls end at the bottom of the screen
            }

            if (prevLine.line.isVerticle()) {
                break;  // Don't bother if the line is verticle
            }

            PVector heading = prevLine.getHeading();

            if (prevLine.line.endPoint.x == ENGINE.screen.left || prevLine.line.endPoint.x == ENGINE.screen.right || prevLine.isHeadingLeft() || prevLine.isHeadingRight()) {
                heading.x *= -1;
            } else {
                heading.y *= -1;
            }

            PVector endPoint = PVector.add(prevLine.line.endPoint, heading);

            prevLine = new ShotLine(prevLine.line.endPoint.x, prevLine.line.endPoint.y, endPoint.x, endPoint.y, enableCollision);
            lines.add(prevLine);
        }
    }
}



