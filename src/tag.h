//
//  tag.h
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/22/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

/*
 
class of Tag objects. A user creates tags (by tagging his  audio) and uploads responsible for tagging the audio. No longer in use. Was susbstituted by the th PD patch.
 
 */


#ifndef Hurly_Burly_v01_tag_h
#define Hurly_Burly_v01_tag_h

#include "ofMain.h"


namespace hurlyBurly{
    
    class Tag{
        
    public:
        Tag();
        ~Tag();
        
        Tag(int, float, float, string, string);

      //  Tag(int uID, int tag, int vol, int sts);

        void draw();
        void update();

            
        float tagLoudness_; // FIX - getter e setter
        string tagTimeDate_; // FIX - getter e setter
        float tagTag_; // FIX - getter e setter
        int tagUserID_;
        int tagStatus_;
        string tagUsername_;

        
        int dotTag_;
        std::string dotName_;
        int dotStatus_;
        int dotLoudness_;
        int dotID_;
        int xpos;
        int ypos;
        int dotRadius;
        
        
    private:

    };
}


#endif
