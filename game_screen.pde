/*
 * game_screen.pde
 *
 * Represents the play space for the main game
 *
 * Created on: January 14, 2020
 *     Author: Sean LaPlante
 */
 

class GameScreen {
    /*
     * Stores information needed to check boundaries of the game screen
     */
    
    public float left;
    public float right;
    public float top;
    public float bottom;
    public float middleX;
    public float middleY;
    public float launchY;
    public PVector launchPoint;
    
    GameScreen(float l, float r, float t, float b) {
        left = l;
        right = r;
        top = t;
        bottom = b;
        middleX = right / 2;
        middleY = bottom / 2;
        launchY = bottom - BALL_RADIUS;
        launchPoint = new PVector(middleX, launchY);
    }
}
