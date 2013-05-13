//
//  lines.h
//  emptyExample
//
//  Created by Joao Cordeiro on 12/31/12.
//
//

#ifndef emptyExample_lines_h
#define emptyExample_lines_h

#include "ofMain.h"
#include "tag.h"
#include "ofxiPhone.h"

//#include "drawingFunctions.h"


class t_lines {
    int line_type;
    
public:
    t_lines();
    ~t_lines();
    
    void setup();
    void update();
    void draw();
    
    void whatLineToDraw (bool is_me);
    void drawSineWave (int);
    void drawSpeechWave (int);
    void drawSilenceLine (int);
    void drawNoiseWave (int);
    void drawOfflineLine ();

    void drawname(bool draw_me);
    void legend();
    
    void printMoving();
    
    int user_status_for_lines;
    int rank;
    int dotTag_;
    std::string dotName_;
    int dotStatus_;
    int dotLoudness_;
    int dotID_;
    int xpos;
    int ypos;
    int dotRadius;
    bool changedTagFalg;
    int draw_x;
    int draw_y;

    void vPos();
    
    int xspacing;   // How far apart should each horizontal location be spaced
    int w, h;              // Width of entire wave
    int screen_w, screen_h;

    int offset;
    int amp_max = 50;

    
    float thetaSpeech;
    float theta;  // Start angle at 0
    float amplitude;  // Height of wave
    float scaled_amplitude;
    int period;  // How many pixels before the wave repeats
    int periodSpeech;  // How many pixels before the wave repeats
    float dx, dxSpeech, dxSpeechMod;  // Value for incrementing X, a function of period and xspacing
   // float yvalues[w/xspacing];  // Using an array to store height values for the wave
    
   /* ofTrueTypeFont myfont;
    ofTrueTypeFont myfont_1;

    ofTrueTypeFont myfont_2;
*/
  
//    ofImage top_bar;
//    ofImage bottom_bar;
    
    int num_friends;
    
};


#endif
