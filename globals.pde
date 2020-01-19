/*
 * globals.pde
 *
 * All variables that need global scope
 *
 *  Created on: December 23, 2019
 *      Author: Sean LaPlante
 */

boolean DEBUG = true;  // Displays cheat lines and other useful info

enum GameState {
    START_SCREEN,
    PLAYING
}

enum InputType {
    TOUCH_START,
    TOUCH_END,
    TOUCH_MOVE
}

GameState currentState;

StartScreen startScreen;

MainGame mainGame;


//
// Globally set these based on DPI
//
// These are set in setup()
//
float BALL_RADIUS;
float SHOT_SPEED;
float BLOCK_WIDTH;
float BLOCK_XY_SPACING;
float BLOCK_FONT;
