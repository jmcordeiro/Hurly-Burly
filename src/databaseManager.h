//
//  databaseManager.h
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/20/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//
/*
 
 A variable was created to receive floats from the AppCore. I have to tweek it to serve my needs.

 */

#pragma once
#include "ofMain.h"
#include "user.h"
#include "tag.h"
#include "lines.h"
#include "dbConnect.h"



namespace hurlyBurly {
    
    class DatabaseManager {
        
    protected:
        User* myUserDB;
        dbConnect* myDBC;
        
    public:
        DatabaseManager(User* bridgeUser, dbConnect* dbc);
        ~DatabaseManager();
        
        
        void setup();
        void update();
        void draw();
        
        //void setUser(string, string, int);
        //void setUser(User* bridgeUser);
        //void setTag(float, float, float);
        void newTagEventServer(int usr, float loud, float tag, string timeDate, string username);
        void newTagEventFile(int usr, float loud, float tag, string timeDate, string username);
        void newTagEvent();

        
        float dbFromPd; //FIXME: Bad name !!! getters e setters !!!!
        float loudnessFromPd; // é inicializada no AppCore.cpp (dbMng_App->loudnessFromPd = value;)
        float tagFromPd; // é inicializada no AppCore.cpp (dbMng_App->tagFromPd = value;)
        string timeDateFromPd;
        std::string timeDateStringFromPd;
        
        float timer;
        bool flagAddTag;
        bool flagAddTag_draw;
        
        bool background;
        bool offline;
        
        
    private:
        Tag* myTag_;
        bool lock;
        
    };
}


//#endif
