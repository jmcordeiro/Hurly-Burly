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

//--------------------------------------------------------------
void testApp::setup() {
    
    login = false; // flag used to indicate that user is not logged in
    nameAndPass = false; // flag used to indicate that no name or pass had been inserted
    userSet = false; // flag used to indicate that user has been set
    requesting = false;
    request_fail = false;
    // requested_ok = false;
    loading_bar = 0;
  
    
    /*
    //COMMENT THIS PART TO AVOID MANUAL LOGIN
     
    key_name = new ofxiPhoneKeyboard(100, 2, 200, 20);
    key_name->setPosition(30, 105);
	key_name->setVisible(true);
	key_name->setBgColor(255, 255, 255, 255);
	key_name->setFontColor(0,0,0, 255);
	key_name->setFontSize(12);
    
    key_pass = new ofxiPhoneKeyboard(100, 2, 200, 20);
    key_pass->setPosition(30, 155);
	key_pass->setVisible(true);
	key_pass->setBgColor(255, 255, 255, 255);
	key_pass->setFontColor(0,0,0, 255);
	key_pass->setFontSize(12);
    key_pass->makeSecure();
    
     */
    
	// register touch events
	//ofRegisterTouchEvents(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	// iPhoneAlerts will be sent to this
	//ofxiPhoneAlerts.addListener(this);
	
	// if you want a landscape orientation
	// ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	
	ofBackground(88, 119, 252);
	
	// the number if libpd ticks per buffer,
	// used to compute the audio buffer len: tpb * blocksize (always 64)
	ticksPerBuffer = 8;	// 8 * 64 = buffer len of 512
    
    
    
    myDBCon = new dbConnect;
    
    myDBCon->setup(&Myself);
    
    // creates an object of type DatabaseManager
    dbMng = new hurlyBurly::DatabaseManager(&Myself, myDBCon);
    
    // setup the app core
    core.setup(2, 1, 44100, ticksPerBuffer, dbMng);
    
	// setup OF sound stream
	ofSoundStreamSetup(2, 1, this, 44100, ofxPd::blockSize()*ticksPerBuffer, 3);
    
    
}





//--------------------------------------------------------------
void testApp::update() {
    
    if (login) {
        
        core.update();
        dbMng->update();
        myDBCon->update();
        
        
        //
        // turn the textbox invisible
        key_name->setVisible(false);
        key_pass->setVisible(false);
        
         
    }  else{
        log_name = key_name->getText();
        log_pass = key_pass->getText();
        
        
        if (requesting == true) {
            
            time(&end);
            if (difftime (end,start) >= 5){
                
                cout << "check [0]: "<<myDBCon->check[0] << endl; // checks first line
                
                if (myDBCon->check[0] == '1'){ // if is "1" the user is validated
                    cout<< "message name ok: " << myDBCon->message << endl;
                    cout<< "user id: " << myDBCon->userID << endl;
                    
                    Myself.setName(log_name);
                    Myself.setPassword(log_pass);
                    Myself.setUserId(ofToInt(myDBCon->userID));
                    
                    core.pd.sendBang("start_tag");
                    login = true; // move to main app
                    
                }
                if (myDBCon->check[0] == '0'){  // if is "0" the user is regected
                    cout<<"message wrong: " << myDBCon->message << endl;
                    log_name = ("");
                    log_pass = ("");
                    key_name->setText("");
                    key_pass->setText("");
                    
                    request_fail = true;
                    requesting = false;
                }
            }
            
        }
    }
    
}


//--------------------------------------------------------------
void testApp::draw() {
    
    ofBackground(88, 119, 252);
    
    if (login == false) {
        ofSetColor(255, 255, 255);
        ofDrawBitmapString("USERNAME:", 30, 80);
        ofDrawBitmapString("PASSWORD:", 30, 130);
        
        
        // dislpay "loading" message
        if (requesting == true) {
            
            if (loading_bar < 60){
                ofSetColor(loading_bar*4.25,loading_bar*4.25,loading_bar*4.25);
                ofDrawBitmapString("LOADING", 100, 300);
                loading_bar++;
                if (loading_bar % 59 == 0) cout << "loading bar" << loading_bar << endl;
                
            }else{
                loading_bar = 0;
            }
        }
        
        
        // displays bad login error message
        
        if (request_fail){
            ofSetColor(255, 0, 0);
            ofDrawBitmapString("!!!! LOGIN FAIL !!!!", 100, 300);
        }
        
        
        
        // Draws a login button when name and pass have been inserted
        if (log_name != "" && log_pass != "") {
            request_fail = false;
            ofSetColor(255, 255, 255);
            ofRect(140, 170, 90, 20);
            ofSetColor(88, 119, 252, 255);
            ofDrawBitmapString("++ LOGIN ++", 140, 185);
            nameAndPass = true; // opens a touch area for the button
        }
        
        
    } else {
        core.draw();
        dbMng->draw();
        ofColor(255,255,255);
        ofDrawBitmapString("HURLY BURLY", 200, 30);
        myDBCon->draw();
        //Myself.draw();
    }
}



//--------------------------------------------------------------
void testApp::exit() {
	core.exit();
    
    
}



//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch) {
    
    // opens keyboard when user touches the textfield
    if (touch.id == 1){
		if(!key_name->isKeyboardShowing()){
			key_name->openKeyboard();
			key_name->setVisible(true);
		} else{
			key_name->setVisible(false);
		}
	}
    
    
    
    if (nameAndPass) {
        if (touch.x < 230 && touch.x > 140 && touch.y < 190 && touch.y > 170) {
            requesting = true;
            time (&start);
            certifyUser(log_name, log_pass);
        }
    }
    
    
}



//--------------------------------------------------------------
void testApp::certifyUser(string enteredName, string enteredPass){
    
    
    // FIX!!!! teste if data is inserted correctly
    
    myDBCon->askIfUserIsRegistered(enteredName, enteredPass);
    
    
    // creates a waiting period of 1 second to send info give time to send request to db
    
    // while (!myDBCon->check[0]) {
    
    //  }
    
}



//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch) {
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch) {
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch) {
    
}

//--------------------------------------------------------------
void testApp::lostFocus() {
    
    cout<<"!!!!!!!!!!!!!TESTE  - A APLICAÇÃO PASSOU A BACKGROUND!!!!!!"<<endl;
    ofxiPhoneLockGLContext();

}

//--------------------------------------------------------------
void testApp::gotFocus() {

    cout<<"*************** TESTE  - A APLICAÇÃO PASSOU A FOREGROUND **********"<<endl;

   
    
    ofxiPhoneUnlockGLContext();
    

    
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning() {
    
    cout<<"&&&&&&&&&&&&&&&&& MEMORY WARNIGN &&&&&&&&&&&&&&&&&&&&&& "<<endl;

    
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
