//
//  user.cpp
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/20/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

#include <iostream>
#include "user.h"
using namespace hurlyBurly;

User::User(){
    myLine = new t_lines;

}


User::~User(){    

    delete myLine;
}


User::User(std::string n, std::string pwd, int i, int st){
    name_ = n;
    password_ = pwd;
    userId_ = i;
    status_ = st;
    appState_foreground_ = true;
    appConnection_online_ = false;
    tempfile.open(ofxiPhoneGetDocumentsDirectory() +"t.txt",ofFile::ReadWrite,false);
    b = 1;
    myLine = new t_lines;
    txt_ready_for_upload = false;

}

void User::setup(){
//    tempfile.open(ofxiPhoneGetDocumentsDirectory() +"t.txt",ofFile::ReadWrite,false);
    
}


void User::update(){
    myLine->user_status_for_lines = getStatus();
}


void User::addTagToFile(Tag* tg){
    // adicionar a tag a um ficheiro;
    cout << "User::addTagToFile() - ESCREVE PARA UM FICHEIRO\n";

        tempfile << ofToString(tg->tagUserID_)<<endl;
        tempfile << ofToString(tg->tagLoudness_)<<endl;
        tempfile << ofToString(tg->tagTag_)<<endl;
        tempfile << tg->tagTimeDate_<<endl;
        tempfile << tg->tagUsername_ <<endl;
}

void User::setName(std::string n){
    name_ = n;
}


void User::setPassword(std::string p){
    password_ = p;
}


void User::setUserId(int uid){
    userId_ = uid;
}


std::string User::getName(){
    return name_;
}


std::string User::getPassword(){
    return password_;
}


int User::getUserId(){
    return userId_;
}


// this method defines user status, based on app state and internet connection
int User::getStatus(){
    
    // app in backgroun (no internet connection) - code: -1
    if (appState_foreground_ == false) {
        status_ = -1;
        return status_;
    }
    
    // app in foreground
    if (appState_foreground_ == true) {
        // if online, code: 1
        if (appConnection_online_ == true) {
            status_ = 1;
            return status_;
        }
        if (appConnection_online_ == false) {
            // if ofline code: -1 
            status_ = -1;
            return status_;
        }
    }
    return status_;
}


// if status changes from online->offline starts a new txt file (erasin the previouse).
// if status changes from offline->online closes the txt file and RETURNS TRUE.
int User::status_changed(int usr_status){
       cout << "User::status_changed() - b: "<< b <<" / actual status: "<<usr_status<<endl;

    if (usr_status < b) { // went ofline
        cout << "User::status_changed() - b: "<< b <<" / actual status: "<<usr_status<<endl;
        cout << "\nUser::status_changed() - STATUS CHANGED - Go OFline / ++++++++++++++++++++++ starts a new txt\n\n";
        //creates a new file (overides the previous)
        fileIsOnep = tempfile.open(ofxiPhoneGetDocumentsDirectory() +"t.txt",ofFile::WriteOnly,false);
        b = usr_status;
        return -1; // returns -1 when the fil
    }
    
    if (usr_status > b) {
        cout << "User::status_changed() - b: "<< b <<" / actual status: "<<usr_status<<endl;
        cout << "User::status_changed() - STATUS CHANGED - Go ONline\n";
        if (tempfile.is_open()){
            cout << "User::status_changed() - +++++++++++++++++++++++++++ closes the txt file\n";
            tempfile.close();};
        fileIsOnep = false;
        b = usr_status;
        txt_ready_for_upload = true;
        return 1;
    }
    return 0;
}

/*
void User::setNumberOfFriendsOnline(int nbr){    
    numberOfFriendsOnline_= nbr;
}
*/


int User::getNumberOfFriendsOnline(){
    return numberOfFriendsOnline_;
}


void User::draw(){
ofSetColor(0, 255, 0);
//ofDrawBitmapString(ofToString(appConnection_online_), 150, 20);

}


void User::exit(){
    if (fileIsOnep) tempfile.close();
}