/*
 * utils.pde
 *
 * Useful utility methods
 *
 * Created on: July 26, 2020
 *     Author: Sean LaPlante
 */
import java.lang.reflect.*;
 
 
boolean isAndroidMode() {
    /*
     * Determine if we're running in Android mode or not
     */
    Class cls = this.getClass();
    
    try {
        cls.getMethod("displayDensity");
    } catch (Exception e) {
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
    Class cls = this.getClass();
    Method displayDensityMethod = null;
    
    try {
        displayDensityMethod = cls.getMethod("displayDensity");
    } catch (Exception e) {
        println("Running in Android mode.");
    }
    
    if (displayDensityMethod != null) {
        println("Running in PC mode");
        try {
            return ((Integer)displayDensityMethod.invoke(this)).floatValue();
        } catch (Exception e) {
            println("PC: Unable to get display density - ", e);
            return 1.0;
        }
    } else {
        try {
            Field displayDensityField = cls.getField("displayDensity");
            return (float)displayDensityField.get(this);
        } catch (Exception e) {
            println("Android: Unable to get display density - ", e);
            return 1.0;
        }
    }
}

 
boolean isCircleInRect(PVector cLocation, float radius, PVector rLocation, float w, float h) {
    /*
     * Determine if the circle is overlapping the rect
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
     */
    return dist(locationOne.x, locationOne.y, locationTwo.x, locationTwo.y) < (radiusOne + radiusTwo);
}
