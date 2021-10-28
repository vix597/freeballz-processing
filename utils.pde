/*
 * utils.pde
 *
 * Useful utility methods
 *
 * Created on: July 26, 2020
 *     Author: Sean LaPlante
 */
import java.lang.reflect.*;


Method getInternalProcessingMethod(String methodName) {
    /*
     * Helper method that can be used to return
     * an internal processing method by name
     */
    Class cls = this.getClass();
    
    try {
        return cls.getMethod(methodName);
    } catch (Exception e) {
        println("Cannot find", methodName, ":", e);
        return null;
    }
}


Object invokeInternalProcessingMethod(String methodName, Object ... args) {
    Method meth = getInternalProcessingMethod(methodName);
    if (meth != null) {
        try {
            return meth.invoke(this, args);
        } catch (Exception e) {
            println("Unable to invoke", methodName, ":", e);
        }
    }
    return null;
}


Object getInternalProcessingField(String fieldName) {
    /*
     * Helper method that can be used to return
     * an internal processing field by name
     */
    Class cls = this.getClass();
    
    try {
        return cls.getField(fieldName).get(this);
    } catch (Exception e) {
        println("Unable to get field", fieldName, ": ", e);
        return null;
    }
}


boolean isAndroidMode() {
    /*
     * Determine if we're running in Android mode or not
     */
     
    // What?
    // In Android mode 'displayDensity' is a field and in Java
    // mode 'displayDensity' is a method. This is a hack...but
    // it works.
    if (getInternalProcessingMethod("displayDensity") == null) {
        return true;
    }
    return false;
}


float getDisplayDensity() {
    /*
     * Get the display density regardless of whether or not
     * we're running on Android (where display density is not
     * a method) or if we're running on a PC where it is a method.
     */
    if (IS_ANDROID_MODE) {
        try {
            return (float)getInternalProcessingField("displayDensity");
        } catch (Exception e) {
            println("Android mode: Unable to get display density: ", e);
            return 1.0;
        }
    } else {
        try {
            // In java mode the displayDensity method returns an int, but
            // in Android mode it returns a float. This whole thing is
            // stupid.
            return ((Integer)invokeInternalProcessingMethod("displayDensity")).floatValue();
        } catch (Exception e) {
            println("Java mode: Unable to get display density: ", e);
            return 1.0;
        }
    }
}

 
boolean isCircleInRect(PVector cLocation, float radius, PVector rLocation, float w, float h) {
    /*
     * Determine if the circle is overlapping the rect
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    float distance;
    float testX = cLocation.x;
    float testY = cLocation.y;

    // which edge is closest?
    if (cLocation.x < rLocation.x) {
        // Left of rect
        testX = rLocation.x;
    } else if (cLocation.x > rLocation.x + w) {
        // Right of rect
        testX = rLocation.x + w;
    }
    
    if (cLocation.y < rLocation.y) {
        // Top of rect
        testY = rLocation.y;
    } else if (cLocation.y > rLocation.y + h) {
        // Bottom of rect
        testY = rLocation.y + h;
    }

    distance = new PVector(cLocation.x - testX, cLocation.y - testY).mag();
        
    return distance <= radius;
}

 
boolean isCircleInCircle(PVector locationOne, float radiusOne, PVector locationTwo, float radiusTwo) {
    /*
     * Determine if the circles are overlapping
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    return dist(locationOne.x, locationOne.y, locationTwo.x, locationTwo.y) < (radiusOne + radiusTwo);
}


PVector getLineIntersectPointWithRectLeft(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
    /*
     * Calculate and return the points at which a line intersects a rect's left side.
     * This method will return null if the line doesn't intersect the rect.
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    
    // check if the line has hit any of the rectangle's sides
    // uses the getLineInterectPoint method below
    PVector left = getLineInterectPoint(x1,y1,x2,y2, rx,ry,rx, ry+rh);
    
    if (left != null) {
        return left;
    }
    
    return null;
}


PVector getLineIntersectPointWithRectRight(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
    /*
     * Calculate and return the points at which a line intersects a rect's right side.
     * This method will return null if the line doesn't intersect the rect.
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    
    // check if the line has hit any of the rectangle's sides
    // uses the getLineInterectPoint method below
    PVector right = getLineInterectPoint(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh);
    
    if (right != null) {
        return right;
    }
    
    return null;
}


PVector getLineIntersectPointWithRectTop(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
    /*
     * Calculate and return the points at which a line intersects a rect's top side.
     * This method will return null if the line doesn't intersect the rect.
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    
    // check if the line has hit any of the rectangle's sides
    // uses the getLineInterectPoint method below
    PVector top = getLineInterectPoint(x1,y1,x2,y2, rx,ry, rx+rw,ry);
    
    if (top != null) {
        return top;
    }
    
    return null;
}


PVector getLineIntersectPointWithRectBottom(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
    /*
     * Calculate and return the points at which a line intersects a rect's bottom side.
     * This method will return null if the line doesn't intersect the rect.
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    
    // check if the line has hit any of the rectangle's sides
    // uses the getLineInterectPoint method below
    PVector bottom = getLineInterectPoint(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh);
    
    if (bottom != null) {
        return bottom;
    }
    
    return null;
}


boolean lineIntersectsRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {
    /*
     * Determine if a line intersects a rect.
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    
    // check if the line has hit any of the rectangle's sides
    // uses the Line/Line function below
    PVector left = getLineInterectPoint(x1,y1,x2,y2, rx,ry,rx, ry+rh);
    PVector right = getLineInterectPoint(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh);
    PVector top = getLineInterectPoint(x1,y1,x2,y2, rx,ry, rx+rw,ry);
    PVector bottom = getLineInterectPoint(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh);

    // if ANY of the above are true, the line
    // has hit the rectangle
    if (left != null || right != null  || top != null  || bottom != null) {
        return true;
    }
    return false;
}


PVector getLineInterectPoint(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    /*
     * Calculate and return the point at which 2 lines intersect.
     * This method will return null if they do not intersect
     *
     * Taken/Modified from: http://jeffreythompson.org/collision-detection/
     */
    
    // calculate the distance to intersection point
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

    // if uA and uB are between 0-1, lines are colliding
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
        
        // optionally, draw a circle where the lines meet
        float intersectionX = x1 + (uA * (x2-x1));
        float intersectionY = y1 + (uA * (y2-y1));
        return new PVector(intersectionX, intersectionY);
    }
    return null;
}
