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
        return null;
    }
}


Field getInternalProcessingField(String fieldName) {
    /*
     * Helper method that can be used to return
     * an internal processing field by name
     */
    Class cls = this.getClass();
    
    try {
        return cls.getField(fieldName);
    } catch (Exception e) {
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
    Method displayDensityMethod = getInternalProcessingMethod("displayDensity");
    
    if (displayDensityMethod == null) {
        Field displayDensityField = getInternalProcessingField("displayDensity");
        try {
            return (float)displayDensityField.get(this);
        } catch (Exception e) {
            println("Android mode: Unable to get display density: ", e);
            return 1.0;
        }
    } else {
        try {
            // In java mode the displayDensity method returns an int, but
            // in Android mode it returns a float. This whole thing is
            // stupid.
            return ((Integer)displayDensityMethod.invoke(this)).floatValue();
        } catch (Exception e) {
            println("Java mode: Unable to get display density: ", e);
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
