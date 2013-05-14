//
//  dbConnect.h
//  HurlyBurly_22_8_2012
//
//  Created by Joao Cordeiro on 8/24/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

#ifndef HurlyBurly_22_8_2012_dbConnect_h
#define HurlyBurly_22_8_2012_dbConnect_h

#include "ofMain.h"
//#include "ofxiPhone.h"
//#include "ofxiPhoneExtras.h"
#include "ofxHttpUtils.h"
#include "time.h"
//#include "dots.h"
#include "lines.h"
#include "user.h"
#include "tag.h"
//#include "databaseManager.h"
#include "ofxiPhoneFile.h"

namespace hurlyBurly {
 
    class dbConnect {
    
    protected:
        //creates a pointer of User type
         User* myUserCnt;

        
    public:
        
        void setup(User* bridgeUser);
     //   void setup();
        void update();
        void draw();
        void exit();
        
        void newResponse(ofxHttpResponse & response);

        void uploadNewTag(string t_ID, string t_l, string t_t, string t_td, string t_n);
        void uploadNewTag(Tag* myNewTag);
        void askIfUserIsRegistered(string, string);
        int timerForGetData(int);
        void askDataToFriends(int); //
        void parseData(string); // calls "askDataToFriends()" and parses that data;
        void updateStatus(int);
        void checkCon_and_askFriends_Inf();
        void checkCon();

        void parse_txt_file_to_tag();
        
        ofxHttpUtils httpUtils; // criado um objecto!!
        
        int counter;
        bool user_on_the_system;
        
        string responseStr;
        string responseStrStatus_; // string with the connection status;
        string requestStr; // string with user data
        string updateStatusStr; // string with status update
        string action_url;
        
        string user_id;
        string date_time;
        string tag;
        string volume;
        string status;

        time_t start,end;
        double dif;
        bool restartTime;
        
        int a, b; // variables to update status only whene it changes
        int numberOfFrdsRetrieved;
        
      //  bool dbConOnline;
        
        
        char check[10];
        char message[20];
        char userID[10];
        char numberOfFriends[50];
        
        /*
        string frdUser_id;
        string frdDate_time;
        string frdTag;
        string frdVolume;
        string frdStatus;
         */
    
        
        //---------------------------------------------------------
        // INFORMATION VISUALIZATION
        
        bool bSmooth;
//        vector<Dots*> myDotsCollection_;
        vector<t_lines*> myLinesCollection_;
        
        //---------------------------------------------------------
        
    
    };
    
    
}

#endif
