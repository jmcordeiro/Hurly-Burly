//
//  user.h
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/20/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//
/*
 Class to create objects of the type "user".
 */

#ifndef Hurly_Burly_v01_user_h
#define Hurly_Burly_v01_user_h

#include "ofMain.h"
#include "tag.h"
#include "ofxiPhoneExtras.h"
#include "lines.h"

//#include "dots.h"
//#include "dbConnect.h"

namespace hurlyBurly {
    class User {
    
    protected:
        
    public:
        User();
        ~User();
        User(std::string n, std::string pwd, int i, int st);
        
        void setName(std::string n);
        std::string getName();

        void setPassword(std::string p);
        std::string getPassword();
        
        void setUserId(int uid);
        int getUserId();
        
        
        //void setUserStatus(bool, bool);
        int getStatus();
        
        void addTagToFile(Tag* tag);
        void setup();
        void draw();
        void exit();
        void update();
        
        void setNumberOfFriendsOnline(int);
        int getNumberOfFriendsOnline();
        
      //  std::vector<Tag*> myCollectionOfFriendsTags_;
        
        bool appState_foreground_;
        bool appConnection_online_;

        int status_changed(int);
        bool txt_ready_for_upload;
        ofFile tempfile;
        int b;
        bool fileIsOnep;
        
        t_lines* myLine;
        
        
    private:
        std::string name_;
        std::string password_;
        int status_;
        int userId_;
        int numberOfFriendsOnline_;
        
        
        // "myCollection_" is a vector of objects of Tag type; I'm not using it for nothing special; maybe I can use it to save tags wile the application is on background.
        
       // std::vector<Tag*> myCollectionOfTags_;
        
    };
}

#endif