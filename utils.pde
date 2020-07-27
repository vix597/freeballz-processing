/*
 * utils.pde
 *
 * Useful utility methods
 *
 * Created on: July 26, 2020
 *     Author: Sean LaPlante
 */
 
 
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
