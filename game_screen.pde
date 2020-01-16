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
    
    public int left;
    public int right;
    public int top;
    public int bottom;
    public int middleX;
    public int middleY;
    public int launchY;
    public PVector launchPoint;
    
    GameScreen(int l, int r, int t, int b) {
        left = l;
        right = r;
        top = t;
        bottom = b;
        middleX = right / 2;
        middleY = bottom / 2;
        launchY = bottom - Ball.radius;
        launchPoint = new PVector(middleX, launchY);
    }
}
