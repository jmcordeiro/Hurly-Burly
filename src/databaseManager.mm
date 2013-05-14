//
//  databaseManager.cpp
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/20/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

// The only object of this class is created in testApp.mm and is called dbManager.
// It receives as parameters of the constructor, the credencials of the user and the connection with the database;



#include "databaseManager.h"
using namespace hurlyBurly;


// constructor -----------------
DatabaseManager::DatabaseManager(User* bridgeUser, dbConnect* dbc){
    myUserDB = bridgeUser;
    myDBC = dbc;
    setup();
}


//destructor --------------------
DatabaseManager::~DatabaseManager(){
}


// setup ----------------------------
void DatabaseManager::setup(){
    lock = false;
    flagAddTag = false;
    flagAddTag_draw = false;
    background = false;
    offline = false;
    
}


// update ----------------------------
void DatabaseManager::update(){
    
    //receives a bang from PD (AppCore) to create a new Tag
 /*   if (flagAddTag) {
        
        //creates a tag (loudness/tag/timedate) to draw on the screen
        // setTag(loudnessFromPd, tagFromPd, timeDateFromPd);
        
        cout << "####### USER STATUS: " << myUserDB->getStatus() << endl;
        
        if (myUserDB->getStatus() == 1) { // status = 1, the user is online
        // creates a temporary tag with the same values from previous to be uploaded to the user vector mycollection_.
        newTagEventServer(myUserDB->getUserId(), loudnessFromPd, tagFromPd, timeDateFromPd);
        }
        
        if (myUserDB->getStatus() == -1) { // t
            // creates a temporary tag with the same values from previous to be uploaded to the user vector mycollection_.
            newTagEventFile(myUserDB->getUserId(), loudnessFromPd, tagFromPd, timeDateFromPd);
        }

            
        //calls MyUser draw method
        //myUserDB->draw();
        
        flagAddTag = false;
    }
  */
    
}




// update ----------------------------
void DatabaseManager::draw(){
    
    // draws a yellow audio-in meter
 //   ofSetColor(255, 255, 0);
//    ofFill();
//    ofRect(30, 20, ofMap(dbFromPd, -100.0, 10.0, 1.0, 30.0), 10);
    
    //prints the variable "timer", which is an integer received from pure data
 //   ofDrawBitmapString(ofToString(timer), 30,50);
    
    // draws [RECORD] on screen while recording
    /*
    if (timer >= 1 && timer <= 3) {
        ofSetColor(255, 0, 0);
        ofDrawBitmapString("[RECORDING]", 7, 100);
    }
    */
    
 // draws user and password on screen
 //   ofSetColor(255, 255, 0);
 //   ofDrawBitmapString("User: "+ myUserDB->getName(), 30, 70);
 //   ofDrawBitmapString("Password: "+ myUserDB->getPassword(), 30,80);
 //   ofDrawBitmapString("Friends online: "+ ofToString(myUserDB->getNumberOfFriendsOnline()), 30,90);
    
    //draws user "line" on the screen
    if (flagAddTag_draw) {
        myUserDB->myLine->offset = myDBC->off;

    myUserDB->myLine->whatLineToDraw(true);
    }
}



// Creates a new tag on the server ----------------------------
void DatabaseManager::newTagEventServer(int usr, float loud, float tag, string timeDate, string username){
    Tag* temp;
    temp = new Tag(usr, loud, tag, timeDate, username);
    myDBC->uploadNewTag(temp); // triggers the uploadTag method of the class dbConnect
    delete temp;
}


// Creates a new tag on a file ----------------------------
void DatabaseManager::newTagEventFile(int usr, float loud, float tag, string timeDate, string username){
    
    cout << "DatabaseManager::newTagEvent() - Write on FILE!!! (DatabaseManager.mm)\n";
    Tag* temp;
    temp = new Tag(usr, loud, tag, timeDate, username);
    myUserDB->addTagToFile(temp); // triggers the addTag() method of the class User which adds the tag to a file;
    delete temp;
    
    
}


void DatabaseManager::newTagEvent(){

    cout << "DatabaseManager::newTagEvent() - ####### USER STATUS: " << myUserDB->getStatus() << endl;
    
    if (myUserDB->getStatus() == 1) { // status = 1, the user is online

        // creates a temporary tag with the same values from previous to be uploaded to the user vector mycollection_.
        cout << "DatabaseManager::newTagEvent() - Write on SERVER!!! (DatabaseManager.mm)\n";
        
        newTagEventServer(myUserDB->getUserId(), loudnessFromPd, tagFromPd, timeDateFromPd, myUserDB->getName());
    }
    
    if (myUserDB->getStatus() == -1) { // t
        // creates a temporary tag with the same values from previous to be uploaded into the txt file
        newTagEventFile(myUserDB->getUserId(), loudnessFromPd, tagFromPd, timeDateFromPd, myUserDB->getName());
    }

    myUserDB->myLine->dotLoudness_ = loudnessFromPd;
    cout << "DatabaseManager::newTagEvent() - loudnessFrom PD: " << loudnessFromPd << endl;
    myUserDB->myLine->dotTag_ = tagFromPd;
    myUserDB->myLine->dotName_ = myUserDB->getName();
    myUserDB->myLine->dotStatus_ = myUserDB->getStatus();
    //myUserDB->myLine->rank = myDBC->myLinesCollection_.size()+1;
    myUserDB->myLine->rank = myDBC->myLinesCollection_.size()+1;
    myUserDB->myLine->num_friends =  ofToInt(myDBC->numberOfFriends);
    myUserDB->myLine->setup();
    myUserDB->myLine->vPos();

    /*
    cout << "my line rank: "<<myUserDB->myLine->rank <<endl;
    cout << "my line ypos: "<<myUserDB->myLine->ypos <<endl;
    cout << "my line number of friends: "<<myUserDB->myLine->num_friends <<endl;
    cout << "my line h: "<<myUserDB->myLine->h <<endl;
     */
    flagAddTag_draw = true;

    
}




