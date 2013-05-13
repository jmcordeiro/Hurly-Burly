//
//  tag.mm
//  Hurly-Burly_v01
//
//  Created by Joao Cordeiro on 7/22/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

#include <iostream>
#include "tag.h"

using namespace hurlyBurly;

Tag::Tag(){
    tagLoudness_ = 0;
    tagTag_ = 0;
    tagTimeDate_ = "000000000000000";
    tagUsername_ = "User";

}

Tag::~Tag(){
}


Tag::Tag(int usr, float loud, float tag, string timeDate, string username){
    tagUserID_ = usr;
    tagLoudness_ = loud;
    tagTag_ = tag;
    tagTimeDate_ = timeDate;
    tagUsername_ = username;

}


void Tag::update(){

}


void Tag::draw(){
    std::cout <<"Tag::draw() - loudness >>> " <<tagLoudness_ << std::endl;
    std::cout <<"Tag::draw() - tag >>> " <<tagTag_ << std::endl;
    std::cout <<"Tag::draw() - timedate >>> " <<tagTimeDate_ << std::endl << std::endl;
    std::cout <<"Tag::draw() - username >>> " <<tagUsername_<< std::endl << std::endl;

 }

