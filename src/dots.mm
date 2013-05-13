//
//  dots.cpp
//  testing_grpahs
//
//  Created by Joao Cordeiro on 8/16/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

/*
#include <iostream>
#include "dots.h"

using namespace hurlyBurly;

Dots::Dots(){}

Dots::~Dots(){}

void Dots::setup(){}

void Dots::update(){}

//------- Defines position of the circles -------
void Dots::setXandY(){
    
    dotRadius = dotLoudness_/10;
    if (changedTagFalg) {
        
        if (dotTag_ == 4) {
            xpos = ofRandom(170, 280);
            ypos = ofRandom(280, 390);
                }
            ofFill();
            if (dotTag_ == 2) { // env
                xpos = ofRandom(40, 150);
                ypos = ofRandom(280, 390);
            }
            
            if (dotTag_ == 1) { // speech
                xpos = ofRandom(40, 150);
                ypos = ofRandom(150, 260);
            }
            
            if (dotTag_ == 3) { // music
                xpos = ofRandom(170, 280);
                ypos = ofRandom(150, 260);
            }
        }
    }


//------- Draw circles -------
void Dots::draw(){
    
    ofSetColor(255,0,0);
    
    if (dotStatus_== 0) {
        ofNoFill();		// draw "empty shapes"
    } else {
        ofFill();
    }
    
    ofCircle(xpos, ypos, dotRadius);
}

 */
