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
#include "AppCore.h"
#include "c_externals.h"

//--------------------------------------------------------------
void AppCore::setup(const int numOutChannels, const int numInChannels,
				    const int sampleRate, const int ticksPerBuffer, hurlyBurly::DatabaseManager* dmng) {
    
    dbMng_App = dmng;
     
	ofSetFrameRate(60);
	ofSetVerticalSync(true);
	//ofSetLogLevel(OF_LOG_VERBOSE);
	
	// double check where we are ...
	cout << ofFilePath::getCurrentWorkingDirectory() << endl;
	
	if(!pd.init(numOutChannels, numInChannels, sampleRate, ticksPerBuffer)) {
		ofLog(OF_LOG_ERROR, "Could not init pd");
		OF_EXIT_APP(1);
	}
    
    specCentroid_tilde_setup();
    timbreID_setup();
    atoi_setup();
    date_setup();
    makesymbol_setup();
    tabdump_setup();
    time_setup();
    specCentroid_setup();
    specSpread_setup();
    specFlatness_setup();
    specIrregularity_setup();
    specKurtosis_setup();
    sigmund_tilde_setup();
    featureAccum_setup();
    mean_setup();
    tabletool_setup();
    counter_setup();
    repack_setup();
    sum_setup();
    lp1_t_tilde_setup();


    
    
    midiChan = 1; // midi channels are 1-16
	
	// subscribe to receive source names
	pd.subscribe("to_of_loudness");
	pd.subscribe("to_of_datetime");
    pd.subscribe("to_of_tag");
	pd.subscribe("to_of_timer");
    pd.subscribe("to_of_db");
    pd.subscribe("to_of_addTag");
    
	// add message receiver, disables polling (see processEvents)
	pd.addReceiver(*this);   // automatically receives from all subscribed sources
	//pd.ignore(*this, "env"); // don't receive from "env"
    //pd.ignore(*this);             // ignore all sources
	//pd.receive(*this, "toOF");	// receive only from "toOF"
	
    // add midi receiver
    //pd.addMidiReceiver(*this);  // automatically receives from all channels
    //pd.ignoreMidi(*this, 1);     // ignore midi channel 1
    //pd.ignoreMidi(*this);        // ignore all channels
    //pd.receiveMidi(*this, 1);    // receive only from channel 1
    
	// add the data/pd folder to the search path
	pd.addToSearchPath("pd");
    
	// audio processing on
	pd.start();
    
	
	cout << endl << "BEGIN Patch Test" << endl;
	
	// open patch
	Patch patch = pd.openPatch("combined_patch_16_april_2013.pd");
	cout <<"******** PD PATCH LOADED ************** \n" << patch << endl;
	
    
    // close patch
	//pd.closePatch(patch);
	//cout << patch << endl;
    
	cout << "FINISH Patch Test" << endl;
	
    
    
	
	cout << endl << "BEGIN Message Test" << endl;
	
	// test basic atoms
	pd.sendBang("fromOF");
	pd.sendFloat("fromOF", 100);
	pd.sendSymbol("fromOF", "test string");
    
    // stream interface
    pd << Bang("fromOF")
    << Float("fromOF", 100)
    << Symbol("fromOF", "test string");
	
	// send a list
	pd.startMessage();
    pd.addFloat(1.23);
    pd.addSymbol("a symbol");
	pd.finishList("fromOF");
	
	// send a message to the $0 receiver ie $0-toOF
	pd.startMessage();
    pd.addFloat(1.23);
    pd.addSymbol("a symbol");
	pd.finishList(patch.dollarZeroStr()+"-fromOF");
	
    // send a list using the List object
    List testList;
    testList.addFloat(1.23);
    testList.addSymbol("sent from a List object");
    pd.sendList("fromOF", testList);
    pd.sendMessage("fromOF", "msg", testList);
    
    // stream interface for list
    pd << StartMessage() << 1.23 << "sent from a streamed list" << FinishList("fromOF");
    
	cout << "FINISH Message Test" << endl;
	
	
	cout << endl << "BEGIN MIDI Test" << endl;
	
	// send functions
	pd.sendNoteOn(midiChan, 60);
	pd.sendControlChange(midiChan, 0, 64);
	pd.sendProgramChange(midiChan, 100);    // note: pgm num range is 1 - 128
	pd.sendPitchBend(midiChan, 2000);   // note: ofxPd uses -8192 - 8192 while [bendin] returns 0 - 16383,
    // so sending a val of 2000 gives 10192 in pd
	pd.sendAftertouch(midiChan, 100);
	pd.sendPolyAftertouch(midiChan, 64, 100);
	pd.sendMidiByte(0, 239);    // note: pd adds +2 to the port number from [midiin], [sysexin], & [realtimein]
	pd.sendSysex(0, 239);       // so sending to port 0 gives port 2 in pd
	pd.sendSysRealTime(0, 239);
	
	// stream
	pd << NoteOn(midiChan, 60) << ControlChange(midiChan, 100, 64)
    << ProgramChange(midiChan, 100) << PitchBend(midiChan, 2000)
    << Aftertouch(midiChan, 100) << PolyAftertouch(midiChan, 64, 100)
    << StartMidi(0) << 239 << Finish()
    << StartSysex(0) << 239 << Finish()
    << StartSysRealTime(0) << 239 << Finish();
    
	cout << "FINISH MIDI Test" << endl;
	
	
    /*
     cout << endl << "BEGIN Array Test" << endl;
     
     // array check length
     cout << "array1 len: " << pd.arraySize("array1") << endl;
     
     // read array
     std::vector<float> array1;
     pd.readArray("array1", array1);	// sets array to correct size
     cout << "array1 ";
     for(int i = 0; i < array1.size(); ++i)
     cout << array1[i] << " ";
     cout << endl;
     
     // write array
     for(int i = 0; i < array1.size(); ++i)
     array1[i] = i;
     pd.writeArray("array1", array1);
     
     // ready array
     pd.readArray("array1", array1);
     cout << "array1 ";
     for(int i = 0; i < array1.size(); ++i)
     cout << array1[i] << " ";
     cout << endl;
     
     // clear array
     pd.clearArray("array1", 10);
     
     // ready array
     pd.readArray("array1", array1);
     cout << "array1 ";
     for(int i = 0; i < array1.size(); ++i)
     cout << array1[i] << " ";
     cout << endl;
     
     cout << "FINISH Array Test" << endl;
     
     */
	
	cout << endl << "BEGIN PD Test" << endl;
	pd.sendSymbol("fromOF", "test");
	cout << "FINISH PD Test" << endl << endl;
	
	
	cout << endl << "BEGIN Event Polling Test" << endl;
	
	// clear receivers, enable polling
	pd.clearReceivers();
    pd.clearMidiReceivers();
	
	pd.sendSymbol("fromOF", "test");
	processEvents(); // <-- manually poll for events
	
	// re-add receivers, disable polling
	pd.addReceiver(*this);
    pd.addMidiReceiver(*this);
	pd.ignore(*this, "env");
	
	cout << "FINISH Event Polling Test" << endl << endl;
	
	
	// play a tone by sending a list
	// [list tone pitch 72 (
	pd.startMessage();
    pd.addSymbol("pitch");
    pd.addFloat(72);
	pd.finishList("tone");
	pd.sendBang("tone");
    
}

//--------------------------------------------------------------
void AppCore::update() {
//	ofBackground(100, 100, 100);
//	ofBackground(177, 181, 180);
	
	// update scope array from pd
	//pd.readArray("scope", scopeArray);
}

//--------------------------------------------------------------
void AppCore::draw() {
    
	// draw scope
//	ofSetColor(0, 255, 0);
	//ofSetRectMode(OF_RECTMODE_CENTER);
	//float x = 0, y = ofGetHeight()/2;
	//float w = ofGetWidth() / (float) scopeArray.size(), h = ofGetHeight()/2;
	/*for(int i = 0; i < scopeArray.size()-1; ++i) {
     ofLine(x, y+scopeArray[i]*h, x+w, y+scopeArray[i+1]*h);
     x += w;
     }*/
    
    //    pd.receive(*this, "env");
	/*
     pd.receive(*this,"to_of_loudness");
     pd.receive(*this,"to_of_datetime");
     pd.receive(*this,"to_of_tag");
     pd.receive(*this,"to_of_timer");
     pd.receive(*this,"to_of_db");
     */
    
    
    
}

//--------------------------------------------------------------
void AppCore::exit() {}

//--------------------------------------------------------------
/*
 void AppCore::playTone(int pitch) {
 pd << StartMessage() << "pitch" << pitch << FinishList("tone") << Bang("tone");
 }
 */
//--------------------------------------------------------------
void AppCore::keyPressed (int key) {
    /*
     switch(key) {
     
     case 'a':
     playTone(60);
     break;
     case 'w':
     playTone(61);
     break;
     case 's':
     playTone(62);
     break;
     case 'e':
     playTone(63);
     break;
     case 'd':
     playTone(64);
     break;
     case 'f':
     playTone(65);
     break;
     case 't':
     playTone(66);
     break;
     case 'g':
     playTone(67);
     break;
     case 'y':
     playTone(68);
     break;
     case 'h':
     playTone(69);
     break;
     case 'u':
     playTone(70);
     break;
     case 'j':
     playTone(71);
     break;
     case 'k':
     playTone(72);
     break;
     
     case ' ':
     if(pd.isReceiving(*this, "env")) {
     pd.ignore(*this, "env");
     cout << "ignoring env" << endl;
     }
     else {
     pd.receive(*this, "env");
     cout << "receiving from env" << endl;
     }
     break;
     
     default:
     break;
     }
     
     */
}

//--------------------------------------------------------------
void AppCore::audioReceived(float * input, int bufferSize, int nChannels) {
	pd.audioIn(input, bufferSize, nChannels);
}

//--------------------------------------------------------------
void AppCore::audioRequested(float * output, int bufferSize, int nChannels) {
	pd.audioOut(output, bufferSize, nChannels);
}

//--------------------------------------------------------------
void AppCore::print(const std::string& message) {
	cout <<  message << endl;
}



//--------------------------------------------------------------	
//--------------------------------------------------------------	
//--------------------------------------------------------------	


void AppCore::receiveBang(const std::string& dest) {
	//cout << "OF: bang " << dest << endl;
    
    if (dest == "to_of_addTag") {
        //dbMng_App->flagAddTag = true;
        dbMng_App->newTagEvent();
        cout << "OF receives a Bang from PD ''" << dest << "'' to add a new Tag"<<endl;
    };
    
}


void AppCore::receiveFloat(const std::string& dest, float value) {
	//cout << "OF: float " << dest << ": " << value << endl;
    //FIXME: fazer parsing do endereço !!!!!
    
    
    if (dest == "to_of_db") {
        dbMng_App->dbFromPd = value;
        //cout << "OF: float - Class AppCore" << dest << ": " << value <<" (valor db instantaneo): " <<endl;
        
    };
    
    if (dest == "to_of_tag") {
        
      
        
        if (isMoving) {
            dbMng_App->tagFromPd = value+10;
        }else{
        dbMng_App->tagFromPd = value;
        }
        cout << "OF receives a Tag (float) from PD ''" << dest << "'' with value: " << value << endl;
        isMoving = false;
    };
    
    
    if (dest == "to_of_loudness") {
        dbMng_App->loudnessFromPd = value;
        cout << "AppCore::receiveFloat() - OF receives Loudness (float) from PD ''" << dest << "'' with value: " << value << endl;
    };
    
    
    if (dest == "to_of_timer") {
         //  cout << "OF receives a Timmer (float) from PD ''" << dest << "'' with value: " << value << endl;
        dbMng_App->timer = value;
        
        // *************************
        if (dbMng_App->timer >= 1 && dbMng_App->timer <= 3) {
            float f1 = ofxAccelerometer.getRawAcceleration().x;
            float f3 = f2-f1;
            f2 = f1;
            
            if (f3 >= 0.1) {
                cout << "!!!IS MOVINGGGG !!!!" << endl;
                isMoving = true;
            };
            
        }
    };
    
    
}


void AppCore::receiveSymbol(const std::string& dest, const std::string& symbol) {    
    if (dest == "to_of_datetime") {
        cout << "OF receives Timestamp (symbol) from PD ''" << symbol << "'' (aaaammddhhmmss) " << endl;
        dbMng_App->timeDateStringFromPd = symbol;
        dbMng_App->timeDateFromPd = ofToString(symbol);
    };
}



void AppCore::receiveList(const std::string& dest, const List& list) {
	cout << "OF: list " << dest << ": ";
	
	// step through the list
	for(int i = 0; i < list.len(); ++i) {
		if(list.isFloat(i))
			cout << list.getFloat(i) << " ";
		else if(list.isSymbol(i))
			cout << list.getSymbol(i) << " ";
	}
    
    // you can also use the built in toString function or simply stream it out
    // cout << list.toString();
    // cout << list;
	
    // print an OSC-style type string
	cout << list.types() << endl;
}

void AppCore::receiveMessage(const std::string& dest, const std::string& msg, const List& list) {
	cout << "OF: message " << dest << ": " << msg << " " << list.toString() << list.types() << endl;
}

//--------------------------------------------------------------
void AppCore::receiveNoteOn(const int channel, const int pitch, const int velocity) {
	cout << "OF MIDI: note on: " << channel << " " << pitch << " " << velocity << endl;
}

void AppCore::receiveControlChange(const int channel, const int controller, const int value) {
	cout << "OF MIDI: control change: " << channel << " " << controller << " " << value << endl;
}

// note: pgm nums are 1-128 to match pd
void AppCore::receiveProgramChange(const int channel, const int value) {
	cout << "OF MIDI: program change: " << channel << " " << value << endl;
}

void AppCore::receivePitchBend(const int channel, const int value) {
	cout << "OF MIDI: pitch bend: " << channel << " " << value << endl;
}

void AppCore::receiveAftertouch(const int channel, const int value) {
	cout << "OF MIDI: aftertouch: " << channel << " " << value << endl;
}

void AppCore::receivePolyAftertouch(const int channel, const int pitch, const int value) {
	cout << "OF MIDI: poly aftertouch: " << channel << " " << pitch << " " << value << endl;
}

// note: pd adds +2 to the port num, so sending to port 3 in pd to [midiout],
//       shows up at port 1 in ofxPd
void AppCore::receiveMidiByte(const int port, const int byte) {
	cout << "OF MIDI: midi byte: " << port << " " << byte << endl;
}

//--------------------------------------------------------------
void AppCore::processEvents() {
	
	cout << "Number of waiting messages: " << pd.numMessages() << endl;
	
	while(pd.numMessages() > 0) {
		Message& msg = pd.nextMessage();
        
		switch(msg.type) {
                
			case PRINT:
				cout << "OF: " << msg.symbol << endl;
				break;
                
                // events
			case BANG:
				cout << "OF: bang " << msg.dest << endl;
				break;
			case FLOAT:
				cout << "OF: float " << msg.dest << ": " << msg.num << endl;
				break;
			case SYMBOL:
				cout << "OF: symbol " << msg.dest << ": " << msg.symbol << endl;
				break;
			case LIST:
				cout << "OF: list " << msg.list << msg.list.types() << endl;
				break;
			case MESSAGE:
				cout << "OF: message " << msg.dest << ": " << msg.symbol << " " 
                << msg.list << msg.list.types() << endl;
				break;
                
                // midi
			case NOTE_ON:
				cout << "OF MIDI: note on: " << msg.channel << " "
                << msg.pitch << " " << msg.velocity << endl;
				break;
			case CONTROL_CHANGE:
				cout << "OF MIDI: control change: " << msg.channel
                << " " << msg.controller << " " << msg.value << endl;
				break;
			case PROGRAM_CHANGE:
				cout << "OF MIDI: program change: " << msg.channel << " "
                << msg.value << endl;
				break;
			case PITCH_BEND:
				cout << "OF MIDI: pitch bend: " << msg.channel << " "
                << msg.value << endl;
				break;
			case AFTERTOUCH:
				cout << "OF MIDI: aftertouch: " << msg.channel << " "
                << msg.value << endl;
				break;
			case POLY_AFTERTOUCH:
				cout << "OF MIDI: poly aftertouch: " << msg.channel << " "
                << msg.pitch << " " << msg.value << endl;
				break;
			case BYTE:
				cout << "OF MIDI: midi byte: " << msg.port << " 0x"
                << hex << (int) msg.byte << dec << endl;
				break;
                
			case NONE:
				cout << "OF: NONE ... empty message" << endl;
				break;
		}
	}
}
