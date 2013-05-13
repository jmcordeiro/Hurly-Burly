/*
 * Copyright (c) 2011 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/ofxPd for documentation
 *
 
 >>>The TestApp is the OF default class, here is used to instantiate the The AppCore object (called core) and the DatabaseManager object pointer (called dbMng). 
 Is also used to instatiate interaction methods: touch, accell...
 
 */

#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "ofxMySQL.h"
#include "ofxHttpUtils.h"

#include "databaseManager.h"
#include "dbConnect.h"
#include "../AppCore.h"
#include "drawingFunctions.h"
//#include "lines.h"
//#include "ofxTextBlock.h"



using namespace hurlyBurly;

class testApp : public ofxiPhoneApp {
	
public:


    
    //METHODS
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);
    
	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);
    
    void certifyUser(string, string);
    
    void setLog_name(string);
    void setLog_pass(string);
    string getLog_name();
    string getLog_pass();
    
    ofImage top_bar;
    ofImage bottom_bar;

    int w;
    int h;

    
	// audio callbacks
	void audioReceived(float* input, int bufferSize, int nChannels);
	void audioRequested(float* output, int bufferSize, int nChannels);
    
    //ofURLFileLoader checkConnect;
    //ofHttpResponse isConnected;
    
    //VARIABLES
    int ticksPerBuffer;
    bool login;
    bool nameAndPass;
    bool userSet;
    bool requesting;
    bool request_fail;
    bool signedup;
    
   
    
    ofTrueTypeFont load_font;
    ofTrueTypeFont login_message;
    
//    ofxTextBlock        myText;
//    TextBlockAlignment  alignment;  //constants for controlling state

    int loading_bar;
    time_t start,end;
    
    
    // INSTANTIATED OBJECTS
  //  ofxiPhoneKeyboard* key_name;
  //  ofxiPhoneKeyboard* key_pass;
    
	AppCore core;
    User Myself;
    
 //   t_lines *newLine;
    dbConnect* myDBCon;
    DatabaseManager* dbMng;
   
    bool testAppForeground;

    
private:
    string log_name; // FIX getters and setters
    string log_pass;// FIX getters and setters

    
};


