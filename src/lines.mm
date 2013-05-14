//
//  lines.cpp
//  emptyExample
//
//  Created by Joao Cordeiro on 12/31/12.
//
//

#include "lines.h"

t_lines::t_lines(){
    
    //  w =640;
    //  h = 960;
    
    //   cout << "get with: " << ofGetWidth() << endl;
    //    cout << "constructor: " << w << endl;
    
    theta = 0.0;  // Start angle at 0
    thetaSpeech = 0.0;
    
    
}

t_lines::~t_lines(){
    
    
}



//-------------------------------------------------------------
void t_lines::setup(){
    
    
    w = ofGetWindowWidth();
    h = ofGetWindowHeight();
    //    cout << "get window with: " << w << endl;
    
    
    
    dxSpeechMod = (TWO_PI / (w/2));
    periodSpeech = w/45;  // How many pixels before the wave repeats
    dxSpeech = (TWO_PI / (w/45));
    //cout << ">>>>>>>>>>>>>>>>>>>>>*h "<< h <<endl;
    dx = (TWO_PI / (w/10));
    
    offset = 0;

    
    amplitude = dotLoudness_;  // Height of wave
    
    //xspacing = 1;   // How far apart should each horizontal location be spaced
    //theta = 0.0;  // Start angle at 0
    
    //Sine Wave Setup
    //period = 20.0;  // How many pixels before the wave repeats
    
    //cout << ">>>>>>>>>>>>>>>>>>>>>h "<< h <<endl;
    //   dx = (TWO_PI / period) * xspacing;
    
    //Speech Wave Setup
    //   periodSpeech = 320/45;  // How many pixels before the wave repeats
    //   dxSpeech = (TWO_PI / periodSpeech);
    // dxSpeechMod = (TWO_PI / (320/2));
    //  thetaSpeech = 0.0;
    // ofEnableSmoothing();
    
    
    //   top_bar.loadImage("app_top.png");
    //   bottom_bar.loadImage("app_bottom.png");
    //  bottom_bar.setImageType(OF_IMAGE_COLOR);
    
    //num_friends = 4;
    //rank = 3;
    
    //  myfont.loadFont("vag.ttf", w/25.6);
    //  myfont_2.loadFont("vag.ttf", w/30);
    //amplitude = 1.0;
    
    // vPos = (((h-((h*3)/14))/(num_friends+2))*rank)+(h/14);
    
    //cout << "\n\n\nRANK 1: " << (((h-((h*3)/14))/(3+2))*1)+(h/14)<<endl<<endl<<endl;
    
    
    
}



//-------------------------------------------------------------
void t_lines::update(){
    
    amplitude = ofMap(dotLoudness_, 35, 100, 2, 50);

    //cout << "offset "<< offset << endl;
    
   /* if (dotLoudness_ > 85) {
        amplitude = 40;
    }
    
    
    if (dotLoudness_ < 35) {
        amplitude = 2;
    } else {
        amplitude = ofMap(dotLoudness_, 35, 85, 2, 39);

    }
    */
}


//-------------------------------------------------------------
void t_lines::draw(){
    //    ofEnableSmoothing();
    
    //bars
    //ofBackground(177, 181, 180);
    
    //  cout << "h: " << h << endl;
    //  cout << "w: " << w << endl;
    /*
     ofSetColor(115,119,118);
     ofRect(0, h-((h/14)*2), w, h); // bottom
     ofSetColor(115,119,118);
     ofRect(0, 0, w,(h/14)); // top
     */
    //ofDisableAlphaBlending(); // turn off alpha
    
    //   top_bar.draw(0, 0, w, (top_bar.getHeight())*(w/(top_bar.getWidth())));
    //    bottom_bar.draw(0, h-(bottom_bar.getHeight()*(w/bottom_bar.getWidth())), w, h);
    //    bottom_bar.draw(0, h-(bottom_bar.getHeight()/(bottom_bar.getWidth()/w)), w, (bottom_bar.getHeight())*(w/(bottom_bar.getWidth())));
    
    
    
    /*    //print frame rate
     ofSetColor(255, 255, 255);
     string fr = ofToString(ofGetFrameRate());
     */
    
    /*
     ofSetColor(255, 255, 255);
     myfont.drawString("hurly-burly", w/40, h/20);
     
     ofSetColor(90, 90, 90);
     myfont_1.drawString("your friends' soundscapes", w/3.2, h/20);
     
     ofSetColor(255, 255, 255);
     myfont_2.drawString("music   speech  silence  noise   offline", (w/20), h-(h/40));
     */
    
    //  legend();
    
    // whatLineToDraw();
    
    
}

//-------------------------------------------------------------
void t_lines::legend(){
    
    
    
    /*
     int vertical_p = (h-(h/11));
     
     // ***************************** SINE
     ofSetColor(71, 0, 239);
     float yvalues[w/8];  // Using an array to store height values for the wave
     
     // For every x value, calculate a y value with sine function
     float x = 0;
     for (int i = 0; i < w/8; i++) {
     //       yvalues[w/8-i] = sin(x)*amplitude/2;
     x+=dx;
     }
     // draws the wave
     for (int x = 0; x < w/8-1; x++) {
     ofLine(x+(w/20), yvalues[x]+vertical_p, x+1+(w/20), yvalues[x+1]+vertical_p);
     }
     
     
     // ***************************** Speech
     ofSetColor(74, 76, 75);
     
     float y = 0;
     float ampMod;
     for (int i = 0; i < w/8; i++) {
     ampMod = sin(y)*amplitude/2;
     yvalues[i] = sin(x)*abs(ampMod);
     y+=dxSpeechMod;
     x+=dxSpeech;
     }
     for (int x = 0; x < w/8; x++) {
     ofLine(x+(w/4), yvalues[x]+vertical_p, x+1+(w/4), yvalues[x+1]+vertical_p);
     }
     
     
     // ***************************** Silence
     ofSetColor(249, 117, 121);
     ofLine(w/2.2, vertical_p, (w/2.2)+(w/8), vertical_p);
     
     
     // ***************************** Environemtnal
     ofSetColor(17, 17, 17);
     int add = (w/6);
     ofLine((w/2)+add, vertical_p, (w/2)+4+add, vertical_p+3);
     ofLine((w/2)+4+add, vertical_p+3, (w/2)+8+add, vertical_p-4);
     ofLine((w/2)+8+add, vertical_p-4, (w/2)+12+add, vertical_p+6);
     ofLine((w/2)+12+add, vertical_p+6, (w/2)+14+add, vertical_p-6) ;
     ofLine((w/2)+14+add, vertical_p-6, (w/2)+25+add, vertical_p+3) ;
     ofLine((w/2)+25+add, vertical_p+3, (w/2)+38+add, vertical_p+4) ;
     
     
     // ***************************** Mute
     ofSetColor(220, 224, 223);
     for (int i = 0; i < w/8; i = i+20) {
     ofLine(i+(w-(w/6)), vertical_p, i+10+(w-(w/6)), vertical_p);
     }
     
     */
}




//-------------------------------------------------------------
void t_lines::drawname(bool draw_me){
    
    int rect_high = 14;
    //    int rect_high = amplitude*2;
    //    if (rect_high < 12) rect_high = 12;
    
    //    int rect_width = 320/5;
    int rect_width = dotName_.size()*13;
    
    //rectangle for the name
    //  ofSetColor(82, 82, 82); // others
    //  ofRect(0, vPos-(rect_high/2), rect_width, rect_high);
    
    if (draw_me) {
        ofSetColor(0,174,72); // Me
        ofRect(0, ypos-(rect_high/2), rect_width, rect_high);
        
    } else{
        ofSetColor(140,140,140); // Me
        ofRect(0, ypos-(rect_high/2), rect_width, rect_high);
    }
    
    
    ofSetColor(255, 255, 255);
    ofDrawBitmapString(dotName_, 10, ypos+4);
    
    //   ofDrawBitmapString(dotName_, w/100, ypos+(h/100));
    //    ofDrawBitmapString(ofToString(dotLoudness_), 320/100, ypos+(20));
    
}


//-------------------------------------------------------------
void t_lines::printMoving(){
    int rect_high = 14;
    int rect_width = dotName_.size()*13;
    
    ofSetColor(255,0,0); // Me
    //ofTriangle(0, ypos-(rect_high/2), 7, ypos, 7, ypos-(rect_high));
    ofTriangle(0, ypos, 7, ypos+(rect_high/2), 7, ypos-(rect_high/2));
    ofTriangle(rect_width, ypos, rect_width-7, ypos+(rect_high/2), rect_width-7, ypos-(rect_high/2));
}




//-------------------------------------------------------------
void t_lines::whatLineToDraw (bool is_me){
 
    int line_color;
    
    if (user_status_for_lines==-1){
        line_color = -1;
    }else{
        line_color = dotStatus_;
    }
        
    //  setup();
    update();
    vPos();

 
    if (dotTag_ > 5) {
        
        switch (dotTag_) {
            case 10:
                //            ofEnableSmoothing();
                drawNoiseWave(line_color);
                drawname(is_me);
                printMoving();
                break;
            case 11:
                //            ofEnableSmoothing();
                drawSpeechWave(line_color);
                drawname(is_me);
                printMoving();
                break;
            case 12:
                //            ofEnableSmoothing();
                drawNoiseWave(line_color);
                drawname(is_me);
                printMoving();
                break;
            case 13:
                //            ofEnableSmoothing();
                drawSineWave(line_color);
                drawname(is_me);
                printMoving();
                break;
            case 14:
                drawSilenceLine(line_color);
                drawname(is_me);
                printMoving();
                break;
            default:
                break;
        }

    }else{
        
        switch (dotTag_) {
            case 0:
                //            ofEnableSmoothing();
                drawNoiseWave(line_color);
                drawname(is_me);
                
                break;
            case 1:
                //            ofEnableSmoothing();
                drawSpeechWave(line_color);
                drawname(is_me);
                break;
            case 2:
                //            ofEnableSmoothing();
                drawNoiseWave(line_color);
                drawname(is_me);
                break;
            case 3:
                //            ofEnableSmoothing();
                drawSineWave(line_color);
                drawname(is_me);
                break;
            case 4:
                drawSilenceLine(line_color);
                drawname(is_me);
                break;
            default:
                break;
        }

    }
    
}





//-------------------------------------------------------------
void t_lines::drawSineWave (int st){ // ranking
    
    // float vPos;
    
    //vPos = (((h-((h*3)/14))/(num_friends+2))*rank)+(h/14);
    
    //cout << "t_lines::drawSineWave() - vPost: " << vPos<<endl;
    
    if (st==1) {
        ofSetColor(71, 0, 239);
    }else{
        ofSetColor(235, 235, 235);
    }
    float yvalues[w];  // Using an array to store height values for the wave
    
    // Increment theta (try different values for 'angular velocity' here
    theta += 0.4;
    
    // For every x value, calculate a y value with sine function
    float x = theta;
    for (int i = 0; i < w; i++) {
        yvalues[i] = sin(x)*amplitude;
        x+=dx;
    }
    
    // draws the wave
    for (int x = 0; x < w-1; x++) {
        ofLine(x, yvalues[x]+ypos, x+1, yvalues[x+1]+ypos);
    }
    
    /*
     
     
     ofSetColor(71, 0, 239);
     float yvalues[w/xspacing];  // Using an array to store height values for the wave
     
     // Increment theta (try different values for 'angular velocity' here
     theta += 0.4;
     
     // For every x value, calculate a y value with sine function
     float x = theta;
     for (int i = 0; i < w/xspacing; i++) {
     yvalues[w/xspacing-i] = sin(x)*amplitude;
     x+=dx;
     }
     
     // draws the wave
     for (int x = 0; x < w/xspacing-1; x++) {
     ofLine(x*xspacing, yvalues[x]+ypos, x*xspacing+1, yvalues[x+1]+ypos);
     }
     */
    
}





//-------------------------------------------------------------
void t_lines::drawSpeechWave (int st){
    //   float vPos;
    
    //  vPos = (((h-((h*3)/14))/(num_friends+2))*rank)+(h/14);
    
    if (st==1) {
        ofSetColor(74, 76, 75);
    }else{
        ofSetColor(235, 235, 235);
    }
    
    float yvalues[w];  // Using an array to store height values for the wave
    
    // Increment theta (try different values for 'angular velocity' here
    thetaSpeech += 0.1;
    
    // For every x value, calculate a y value with sine function
    float x = theta;
    float y = thetaSpeech;
    float ampMod;
    for (int i = 0; i < w; i++) {
        ampMod = sin(y)*amplitude;
        yvalues[i] = sin(x)*abs(ampMod);
        y+=dxSpeechMod;
        x+=dxSpeech;
    }
    
    for (int x = 0; x < w; x++) {
        ofLine(x, yvalues[x]+ypos, x+1, yvalues[x+1]+ypos);
        
    }
    
    
    
    /*
     
     ofSetColor(74, 76, 75);
     float yvalues[w/xspacing];  // Using an array to store height values for the wave
     
     // Increment theta (try different values for 'angular velocity' here
     
     thetaSpeech += 0.1;
     
     // For every x value, calculate a y value with sine function
     float x = theta;
     float y = thetaSpeech;
     float ampMod;
     for (int i = 0; i < w/xspacing; i++) {
     ampMod = sin(y)*amplitude;
     yvalues[i] = sin(x)*abs(ampMod);
     y+=dxSpeechMod;
     x+=dxSpeech;
     }
     
     for (int x = 0; x < w/xspacing; x++) {
     ofLine(x*xspacing, yvalues[x]+ypos, x*xspacing+1, yvalues[x+1]+ypos);
     
     }
     
     */
    
}



//-------------------------------------------------------------
void t_lines::drawSilenceLine (int st){
    //   float vPos;
    
    //    vPos = (((h-((h*3)/14))/(num_friends+2))*rank)+(h/14);
    
    if (st==1) {
        ofSetColor(249, 117, 121);
    }else{
        ofSetColor(235, 235, 235);
    }

    
    ofLine(0, ypos, w, ypos);
    /*
     
     ofSetColor(249, 117, 121);
     ofLine(0, ypos, ofGetWidth(), ypos);
     */
}



//-------------------------------------------------------------
void t_lines::drawNoiseWave (int st){
    //  float vPos;
    
    //vPos = (((h-((h*3)/14))/(num_friends+2))*rank)+(h/14);
    
    if (st==1) {
        ofSetColor(17, 17, 17);
    }else{
        ofSetColor(235, 235, 235);
    }

    
    float yvalues[w/4];  // Using an array to store height values for the wave
    // amplitude = 1.0;
    
    // For every x value, calculate a y
    for (int i = 0; i < w/4; i++) {
        yvalues[i] = ofRandom (-amplitude, amplitude);
    }
    
    // draw
    int add = 0;
    for (int x = 0; x < w/4-1; x++) {
        ofLine(add, yvalues[x]+ypos, add+4, yvalues[x+1]+ypos);
        add+=4;
    }
    
    /*
     ofSetColor(17, 17, 17);
     float yvalues[w/4];  // Using an array to store height values for the wave
     
     // For every x value, calculate a y value with sine function
     for (int i = 0; i < w/4; i++) {
     yvalues[i] = ofRandom(-amplitude, amplitude);
     }
     
     // draw
     int add = 0;
     for (int x = 0; x < w/4-1; x++) {
     ofLine(add, yvalues[x]+ypos, add+4, yvalues[x+1]+ypos);
     add+=4;
     }
     
     */
    
}



//-------------------------------------------------------------
void t_lines::drawOfflineLine (){
    // float vPos;
    
    // vPos = (((h-((h*3)/14))/(num_friends+2))*rank)+(h/14);
    
    ofSetColor(220, 224, 223);
    for (int i = 0; i < w; i = i+20) {
        ofLine(i, ypos, i+10, ypos);
    }
    /*
     
     ofSetColor(220, 224, 223);
     for (int i = 0; i < ofGetWidth(); i = i+20) {
     ofLine(i, ypos, i+10, ypos);
     }
     
     */
}


void t_lines::vPos(){
    
//    ypos = ((((h-((h*3)/14))/(num_friends+2))*rank)+(h/14)+offset); !!!! estou aqui
   // (h*0.10) +
      ypos = (h*0.05)+(rank*(amp_max*2)+15)+offset;
    
}

//--------------------------------------------------------------
void t_lines::touchDown(ofTouchEventArgs &touch) {
 
   
    cout << " DOWN DONW DOWN DOWN DOWN " << endl;
    
}
