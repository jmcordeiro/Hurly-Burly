//
//  tag.h
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/20/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//


/*
 
Class formerly created to capture and draw audio. No longer in use. It was substritued by pd fucntions.
 
 */

#ifndef Hurly_Burly_v01_data_h
#define Hurly_Burly_v01_data_h


#include "ofMain.h"
#include "tag.h"


namespace hurlyBurly {
    
    class Data {
        
    public:
        Data();
        ~Data();
        
        void setTag(Tag* t);
        Tag* getTag();
        
        void captureAudio();
        
        void draw();
        
        
    private:
        Tag* myTag_;

};
}

#endif
