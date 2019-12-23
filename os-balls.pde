/*
 * os-balls.pde
 *
 * Main game file. Calls the required Processing methods: setup and draw.
 *
 *  Created on: December 23, 2019
 *      Author: Sean LaPlante
 */




void setup() {
    //******Get Screen DPI********
    DisplayMetrics dm = new DisplayMetrics();
    getWindowManager().getDefaultDisplay().getMetrics(dm);
    density = dm.density;
    densityDpi = dm.densityDpi;
    println("Screen densityDPI: "+densityDpi);
    //****************************

    //******Display Setup*********
    orientation(LANDSCAPE);
    smooth();
    background(255);
    frameRate(60);
    gameWidth=width;
    gameHeight=height-(height/7);
    barWidth=width;
    barHeight=height/7;
    //****************************

    //********Sound Setup*********
    paddleSound = new APMediaPlayer(this);
    wallSound = new APMediaPlayer(this);
    goal = new APMediaPlayer(this);
    goal.setMediaFile("sound/unGoal.wav");
    paddleSound.setMediaFile("sound/clink_paddle.wav");
    wallSound.setMediaFile("sound/clunk_wall.wav");
    goal.setLooping(false);
    paddleSound.setLooping(false);
    wallSound.setLooping(false);
    goal.setVolume(1.0,1.0);
    wallSound.setVolume(1.0,1.0);
    paddleSound.setVolume(1.0,1.0);
    //*****************************

    //*******Eat Da Glass sound setup********
    eatDaGlass = new ArrayList();
    for(int i=0;i<3;i++){
        APMediaPlayer temp = new APMediaPlayer(this);
        temp.setMediaFile("sound/trippy"+i+".wav");
        temp.setLooping(false);
        temp.setVolume(1.0,1.0);
        eatDaGlass.add(temp);
    }
    glassCount=0;
    //***************************************

    //******Objects setup*********
    sc = new Start_Screen();
    hPadleSpeed=3;
    cPadleSpeed=3;
    hScore=0;
    cScore=0;
    displayMode=NORM;
    ballStep = new PVector(0.5,0.8);
    leftPadle = new Padle(true);
    rightPadle = new Padle(false);
    ball = new Ball();
    controlPanel = new ControlPanel();
    //****************************
}

void draw(){
   if(start){
        background(255);
        displayMode=NORM;
        sc.display();
        if(currentEvent!=null){
            if(checkInside(sc.easyX,sc.easyY,sc.easyW,sc.easyH)){
                mode=EASY;
                start=false;
                println("Mode is EASY");
            }
            else if(checkInside(sc.medX,sc.medY,sc.medW,sc.medH)){
                mode=MEDIUM;
                start=false;
                println("Mode is MEDIUM");
            }
            else if(checkInside(sc.hardX,sc.hardY,sc.hardW,sc.hardH)){
                mode=HARD;
                start=false;
                println("Mode is HARD");
            }
            else if(checkInside(sc.impX,sc.impY,sc.impW,sc.impH)){
                mode=IMPOSSIBLE;
                start=false;
                println("Mode is IMPOSSIBLE");
            }
            else if(checkInside(0,0,100,100)){
                mode=HARD;
                displayMode=TRIPPY;
                start=false;
                println("SECRET MODE DISCOVERED");
            }
        }
    }
    else{
        if(displayMode==TRIPPY){
            //              R                  G                       B               Alpha
            background((ball.loc.x%256),(ball.loc.y%256),((ball.loc.x+ball.loc.y)%256),50);
        }
        else if(displayMode==NORM)
            background(255);
        displayScore();                           //Displays the current comp vs human score
        ball.move();                              //move the ball by its velocity every frame

        //get current padle locations
        leftLoc = leftPadle.getLoc();
        rightLoc = rightPadle.getLoc();

        checkCollisions();
        computerAI();

        //*******handle left padle movement*******
        if(!beingTouched || currentEvent==null || currentEvent.getAction()==MotionEvent.ACTION_UP){
            moveUp=false;
            moveDown=false;
        }

        if(leftPadle.y+(leftPadle.pHeight/2) > gameHeight){
            leftPadle.y=gameHeight-(leftPadle.pHeight/2);
            down=false;
            moveDown=false;
        }else
            down=true;
        if(leftPadle.y-(leftPadle.pHeight/2) < 0){
            leftPadle.y=0+(leftPadle.pHeight/2);
            up=false;
            moveUp=false;
        }else
            up=true;

        if(moveUp && up && checkButtonRight())
            leftPadle.y-=hPadleSpeed;
        if(moveDown && down && checkButtonLeft())
            leftPadle.y+=hPadleSpeed;
        //****************************************

        if(ball.vel.y > 3)
            hPadleSpeed = abs((int)ball.vel.y);

        //check for ceiling and floor
        if((ball.loc.y+(ball.bWidth/2))>gameHeight){
            if(displayMode==NORM)
                wallSound.start();
            else{
                APMediaPlayer temp = (APMediaPlayer) eatDaGlass.get(glassCount);
                temp.start();
                glassCount++;
                if(glassCount>2)
                    glassCount=0;
            }
            ball.loc.y=gameHeight-(ball.bHeight/2);
            ball.vel.y *= -1;
        }
        if((ball.loc.y-(ball.bWidth/2))<0){
            if(displayMode==NORM)
                wallSound.start();
            else{
                APMediaPlayer temp = (APMediaPlayer) eatDaGlass.get(glassCount);
                temp.start();
                glassCount++;
                if(glassCount>2)
                    glassCount=0;
            }
            ball.loc.y=0+(ball.bHeight/2);
            ball.vel.y *= -1;
        }

        //if it goes out create a new ball
        if(ball.loc.x>(gameWidth-rightPadle.pDistance) || ball.loc.x<leftPadle.pDistance){
            if(displayMode==NORM)
                goal.start();
            else{
                APMediaPlayer temp = (APMediaPlayer) eatDaGlass.get(glassCount);
                temp.start();
                glassCount++;
                if(glassCount>2)
                    glassCount=0;
            }
            //Handle scores
            if(ball.loc.x>(gameWidth-rightPadle.pDistance)){
                hScore++;
                println("Human score is: "+hScore);
            }
            else{
                cScore++;
                println("Computer score is: "+cScore);
            }

            hPadleSpeed=3;
            ball = new Ball();
            leftPadle = new Padle(true);
            rightPadle = new Padle(false);
        }

        //display elements on screen
        leftPadle.display();
        rightPadle.display();
        controlPanel.display();
        ball.display();

        //Games play until 9
        if(hScore==9 || cScore==9){
            reset();
            start=true;
        }
    }
}







