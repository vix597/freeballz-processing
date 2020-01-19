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
float BALL_RADIUS = 12;
float SHOT_SPEED = 7;
float BLOCK_WIDTH = width / 7.0;
float BLOCK_XY_SPACING = BLOCK_WIDTH * 0.05;
float BLOCK_FONT = 26;
