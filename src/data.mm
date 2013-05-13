//
//  tag.mm
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/20/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//





#include <iostream>
#include "data.h"

using namespace hurlyBurly;


Data::Data(){
    myTag_ = new Tag();
//    myTag_->setInfo("yeah!");
}




Data::~Data(){
    
}



void Data::setTag(Tag* t){
    myTag_ = t;

}

Tag* Data::getTag(){
    return myTag_;
}


void Data::captureAudio(){
  //      myTag_->setInfo("yeah!");
    
}

void Data::draw(){

    }