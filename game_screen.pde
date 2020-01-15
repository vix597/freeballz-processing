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
    
    GameScreen(int l, int r, int t, int b) {
        left = l;
        right = r;
        top = t;
        bottom = b;
    }
}
