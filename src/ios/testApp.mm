/*
 * Copyright (c) 2011 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/ofxPd for documentation
 *
 */

#include "testApp.h"
#include "login_cred.h"

//--------------------------------------------------------------
void testApp::setup() {
    
    login = false; // flag used to indicate that user is not logged in
    userSet = false; // flag used to indicate that user has been set
    requesting = false;
    request_fail = false;
    signedup = true;
    loading_bar = 0;
    testAppForeground = true;
 //   ofSetFrameRate(60);


    ofDisableAlphaBlending();
	ofBackground(177, 181, 180);

    
 	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	
    load_font.loadFont("Helvetica.dfont", 40);
    login_message.loadFont("Helvetica.dfont", 20);
//    myText.init("Helvetica.dfont", 50);
    
//    myText.setText("LOADING");

    
    
	// the number if libpd ticks per buffer,
	// used to compute the audio buffer len: tpb * blocksize (always 64)
	ticksPerBuffer = 8;	// 8 * 64 = buffer len of 512
    
    newLine = new t_lines;
    //newLine->setup();
    

    top_bar.loadImage("app_top.png");
    bottom_bar.loadImage("app_bottom.png");
 //   bottom_bar.setImageType(OF_IMAGE_COLOR);

    w = ofGetWindowWidth();
    h = ofGetWindowHeight();

    
    myDBCon = new dbConnect;
    
    myDBCon->setup(&Myself);
    
    // creates an object of type DatabaseManager
    dbMng = new hurlyBurly::DatabaseManager(&Myself, myDBCon);
    
    // setup the app core
    core.setup(2, 1, 44100, ticksPerBuffer, dbMng);
    
    
	// setup OF sound stream
	ofSoundStreamSetup(2, 1, this, 44100, ofxPd::blockSize()*ticksPerBuffer, 3);
    
    myDBCon->checkCon();
    
    newLine->offset = 0;
    touchdown_y = 0;
    delta_movment = 0;
    touchup_y = 0;

    
}


//--------------------------------------------------------------
void testApp::update() {
    ofBackground(177, 181, 180);

    
    if (login) {
        Myself.update();
        core.update();
        dbMng->update();
        myDBCon->update();
        
    }  else{
        
        if (requesting == true) {
            time(&end); // wait 5 seconds before running this code
            cout << ".";
            if (difftime (end,start) >= 5){
                
                if (Myself.getStatus() == -1) {
                    cout << "\n(testApp::update()) - YOU ARE NOT CONNECTED\n";
                    Myself.setName(log_name);
                    Myself.setPassword(log_pass);
                    Myself.setUserId(hardCodedId_);
                    
                    core.pd.sendBang("start_tag");
                    login = true; // move to main app
                    requesting = false;
                    
                } else {
                    
                    if (myDBCon->check[0] == '1'){ // if is "1" the user is validated
                        
                        Myself.setName(log_name);
                        Myself.setPassword(log_pass);
                        Myself.setUserId(ofToInt(myDBCon->userID));
                        
                        core.pd.sendBang("start_tag");
                        login = true; // move to main app
                        requesting = false;
                        
                        myDBCon->checkCon_and_askFriends_Inf();
                    }
                    
                    if (myDBCon->check[0] == '0'){  // if is "0" the user is regected
                        ofDrawBitmapString(ofToString(myDBCon->message), 100, 100);
                        requesting = true;
                    }
                }
            }
        }
        
        
        if (signedup == true) {
            log_name = hardCodedName_; // this will read usernames form login_cred.h
            log_pass = hardCodedPass_; // this will read usernames form login_cred.h
            certifyUser(log_name, log_pass);
            signedup = false;
        }
    }
}


//--------------------------------------------------------------
void testApp::draw() {
    
      
    if (login == false) {
        
        // dislpay "loading" message
        if (requesting == true) {
            
            if (loading_bar < 60){
                ofSetColor(loading_bar*4.25,loading_bar*4.25,loading_bar*4.25);
                load_font.drawString("LOADING", (w*0.5)-(load_font.stringWidth("LOADING")*0.5), h*0.4);
//                ofDrawBitmapString("LOADING", 123, 100);
                
                if (myDBCon->user_on_the_system){
                    ofSetColor(60, 60, 60);
                    login_message.drawString("Yhe!! You're in", (w*0.5)-(login_message.stringWidth("Yhe!! You're in")*0.5), h*0.6);
                }
                
                loading_bar++;
                
            }else{
                loading_bar = 0;
            }
        }
        
        // displays bad login error message
        if (request_fail){
            ofSetColor(255, 0, 0);
            ofDrawBitmapString("!!!! LOGIN FAIL !!!!", 100, 300);
        }
        
    } else {
        
        if (dbMng->timer >= 1 && dbMng->timer <= 3) {
            ofSetColor(255, 255, 255);
            ofCircle(w*0.5, h*0.5, w/3);
            ofSetColor(177, 181, 180);
            load_font.drawString("analysing...", (w*0.5)-(load_font.stringWidth("analysing...")*0.5), (h*0.5)+(load_font.stringHeight("analysing...")*0.5));
                   
        }

        ofSetColor(255, 255, 255);
        top_bar.draw(0, 0, w, (top_bar.getHeight())*(w/(top_bar.getWidth())));
        bottom_bar.draw(0, h-(bottom_bar.getHeight()/(bottom_bar.getWidth()/w)), w, (bottom_bar.getHeight())*(w/(bottom_bar.getWidth())));

        core.draw();
        dbMng->draw();
        myDBCon->draw(); // is changing the bars colors
        Myself.draw();
       // newLine->draw();
        
       

       
    }
}



//--------------------------------------------------------------
void testApp::exit() {
    myDBCon->updateStatus(Myself.getUserId());
	core.exit();
    
}



//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch) {
     touchdown_y = touch.y;
    
    newLine->touchDown(touch);
}



//--------------------------------------------------------------
void testApp::certifyUser(string enteredName, string enteredPass){
    
    cout << endl << "(testApp::certifyUser()) *****************************************************" << endl;
    cout << "(testApp::certifyUser()) The user ''"<< enteredName << "'' introduced his/her credentials"<<endl;
    cout << "(testApp::certifyUser()) *****************************************************" << endl<<endl;
    
    
    myDBCon->askIfUserIsRegistered(enteredName, enteredPass);
    time (&start);
    requesting = true;
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch) {
    
    if (newLine->offset <= 0 && newLine->offset >= -200) { // substituir 200 por "int lower_limit" !!!
        //&& abs(newLine->offset) < (newLine->num_friends*(newLine->amp_max))
        delta_movment = touch.y-touchdown_y;
      //  cout << "DELTA MOVMENT: " << delta_movment <<endl;
        newLine->offset = delta_movment + touchup_y;
        
        
    }

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch) {
    
    if (newLine->offset <= 0 && newLine->offset >= -200) {
        touchup_y = newLine->offset;
    }else{
        
        if (newLine->offset > 0) {
            newLine->offset = 0;
        }else{
            newLine->offset = -200;
        }
    }

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch) {
    
}

//--------------------------------------------------------------
void testApp::lostFocus() {
    
    cout << endl << "(testApp::lostFocus()) ************************************************************" << endl;
    cout<<"(testApp::lostFocus()) *************** A APLICAÇÃO PASSOU A BACKGROUND **********"<<endl;
    cout << "(testApp::lostFocus()) **********************************************************" << endl << endl;
    
    ofxiPhoneLockGLContext();
    Myself.appState_foreground_= false;
    cout << "(testApp::lostFocus()) USER STATUS (bg) --- " << Myself.getStatus() << endl;
    myDBCon->updateStatus(Myself.getUserId());
    Myself.status_changed(Myself.getStatus());

    
}

//--------------------------------------------------------------
void testApp::gotFocus() {
    
    cout << endl << "(testApp::gotFocus()) **********************************************************" << endl;
    cout<<"(testApp::gotFocus()) *************** A APLICAÇÃO PASSOU A FOREGROUND **********"<<endl;
    cout << "(testApp::gotFocus()) **********************************************************" << endl << endl;
    
    ofxiPhoneUnlockGLContext();
    Myself.appState_foreground_= true;
    cout << "(testApp::gotFocus()) USER STATUS (fg) --- " << Myself.getStatus() << endl;
    myDBCon->updateStatus(Myself.getUserId());
    Myself.status_changed(Myself.getStatus());
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning() {
    
    cout<<"(testApp::gotMemoryWarnign())&&&&&&&&&&&&&&&&& MEMORY WARNIGN &&&&&&&&&&&&&&&&&&&&&& "<<endl;
    
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation) {
    
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args) {
    
}

//--------------------------------------------------------------
void testApp::audioReceived(float * input, int bufferSize, int nChannels) {
	core.audioReceived(input, bufferSize, nChannels);
}

//--------------------------------------------------------------
void testApp::audioRequested(float * output, int bufferSize, int nChannels) {
	core.audioRequested(output, bufferSize, nChannels);
}

//--------------------------------------------------------------
void testApp::setLog_name(string setLogName){
    log_name = setLogName;
}

//--------------------------------------------------------------
void testApp::setLog_pass(string setLogPass){
    log_pass = setLogPass;
}

//--------------------------------------------------------------
string testApp::getLog_name(){
    return log_name;
}

//--------------------------------------------------------------
string testApp::getLog_pass(){
    return log_pass;
}



