/*
 * button.pde
 *
 * Class for a Button
 *
 *  Created on: July 25, 2020
 *      Author: Sean LaPlante
 */


class Button {
  /*
   * A button that can be pressed/clicked
   */
  PVector location;
  float buttonWidth;
  float buttonHeight;
  float cornerRadius;
  color buttonColor;
  color buttonHoverColor;
  color textColor;
  String text;
  float textSize;
  
  color DEFAULT_TEXT_COLOR = color(255);  // white
  color DEFAULT_BUTTON_COLOR = color(255, 53, 73);  // red/pink
  color DEFAULT_BUTTON_HOVER_COLOR = color(160, 33, 46);  // darker
    
  Button(String text, float x, float y, float buttonWidth, float buttonHeight, float cornerRadius) {
    create(text, new PVector(x, y), buttonWidth, buttonHeight, cornerRadius);
    this.buttonColor = DEFAULT_BUTTON_COLOR;
    this.buttonHoverColor = DEFAULT_BUTTON_HOVER_COLOR;
    this.textColor = DEFAULT_TEXT_COLOR;
    this.textSize = DEFAULT_TEXT_SIZE;
  }
  
  void create(String text, PVector location, float buttonWidth, float buttonHeight, float cornerRadius) {
    this.text = text;
    this.location = location;
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
    this.cornerRadius = cornerRadius;
  }
  
  void setColor(color c) {
    this.buttonColor = c;
  }
  
  void setHoverColor(color c) {
    this.buttonHoverColor = c;
  }
  
  void setTextColor(color c) {
    this.textColor = c;
  }
  
  void setTextSize(float size) {
    this.textSize = size;
  }
  
  void display() {
    pushMatrix();
    noStroke();
        
    if (onButton(mouseX, mouseY)) {
      fill(this.buttonHoverColor);  // Set hover color
    } else {
      fill(this.buttonColor);  // Set normal color
    }
    
    rect(this.location.x, this.location.y, this.buttonWidth, this.buttonHeight, this.cornerRadius);
    
    fill(this.textColor);  // Black text
    textSize(this.textSize);
    strokeWeight(1);
    textAlign(CENTER, CENTER);
    text(this.text, this.location.x + (this.buttonWidth / 2), this.location.y + (this.buttonHeight / 2));
    popMatrix();
  }
  
  boolean onButton(float posX, float posY) {
    if (posX > this.location.x && posX < (this.location.x + this.buttonWidth) && posY > this.location.y && posY < (this.location.y + this.buttonHeight)) {
      return true;
    }
    return false;
  }
}
