/*
 * Copyright (c) 2011 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/ofxPd for documentation
 *
 */


/*
This class is used to bridge OF and PD toghether.
An object of this class (called core) is created in the testApp claas when the app starts
 */


#pragma once

#include "ofMain.h"
#include "ofxPd.h"
#include "databaseManager.h"



// a namespace for the Pd types
using namespace pd;

class AppCore : public PdReceiver, public PdMidiReceiver {
protected:
    
    //creates a pointer of Databasemanager type
    hurlyBurly::DatabaseManager* dbMng_App;
    hurlyBurly::User* user_update_line;

    
public:
    
    // main
    void setup(const int numOutChannels, const int numInChannels,
               const int sampleRate, const int ticksPerBuffer, hurlyBurly::DatabaseManager* dmng);
    void update();
    void draw();
    void exit();
    
    
    bool isMoving;
    float f2 = 0;
    
    // do something
    //void playTone(int pitch);
    
    // input callbacks
    void keyPressed(int key);
    
    // audio callbacks
    void audioReceived(float * input, int bufferSize, int nChannels);
    void audioRequested(float * output, int bufferSize, int nChannels);
    
    // pd message receiver callbacks
    void print(const std::string& message);
    
    void receiveBang(const std::string& dest);
    void receiveFloat(const std::string& dest, float value);
    void receiveSymbol(const std::string& dest, const std::string& symbol);
    void receiveList(const std::string& dest, const List& list);
    void receiveMessage(const std::string& dest, const std::string& msg, const List& list);
    
    // pd midi receiver callbacks
    void receiveNoteOn(const int channel, const int pitch, const int velocity);
    void receiveControlChange(const int channel, const int controller, const int value);
    void receiveProgramChange(const int channel, const int value);
    void receivePitchBend(const int channel, const int value);
    void receiveAftertouch(const int channel, const int value);
    void receivePolyAftertouch(const int channel, const int pitch, const int value);
    
    void receiveMidiByte(const int port, const int byte);
    
    // demonstrates how to manually poll for messages
    void processEvents();
    
    ofxPd pd;
    //vector<float> scopeArray;
    
    int midiChan;
};
