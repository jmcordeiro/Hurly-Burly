//
//  dbConnect.mm
//  HurlyBurly_22_8_2012
//
//  Created by Joao Cordeiro on 8/24/12.
//  Copyright (c) 2012 Portuguese Catholic University. All rights reserved.
//

/*
 This class is one of the moste importante calsses in the program: it does basically the interface between the phone and the server.
 The class might be considered to be devided in two main blocks: SEND DATA TO SERVER and RECEIVE DATA DATA TO SERVER
 
 There are two reasons why we send data to the server: 1) to question it about something, to request information; 2) to upload our own information (tag, etc...)
 
 */


#include <iostream>
#include "dbConnect.h"


using namespace hurlyBurly;


//--------------------------------------------------------------
void dbConnect::setup(User* bridgeUser){
    
    myUserCnt = bridgeUser;
	ofSetVerticalSync(true);
    
    // Adds function "newResponse" as a listner for newResopnseEvent, which receives Notifications of value "response"
	ofAddListener(httpUtils.newResponseEvent,this,&dbConnect::newResponse);
    
    // start the object of type ofxHttpUtils
	httpUtils.start();
    restartTime = true;
    // dbConOnline = false;
    
    a = myUserCnt->getStatus();
    
}


//calls a function that SENDS a message to the server requesting friends data
//--------------------------------------------------------------
void dbConnect::update(){
    
    
    
    if (myUserCnt->txt_ready_for_upload){
        
        // se for "true" significa que o status mudou para online. Manda mensagem para a DB ler o ficheiro.
        //cout << "dbConnect::update() - File is open? (1=yes, 0=no): "<< myUserCnt->fileIsOnep <<endl;
        if (!myUserCnt->fileIsOnep){
            parse_txt_file_to_tag();
            myUserCnt->txt_ready_for_upload = false;
        }
    }
    
    
    if (timerForGetData(10)==1) {
        checkCon_and_askFriends_Inf(); // check connection and ask for update data about frineds;
        
    }
    
   // myUserCnt->myLine->user_status_for_lines=myUserCnt->getStatus();
    
    
    for (int j=0; j<myLinesCollection_.size(); j++) {
    
    myLinesCollection_[j]->offset = off;
    }
    
    
}

//Draws the vector with the friends dots
//--------------------------------------------------------------
void dbConnect::draw(){
    /*
     for (int i=0; i<myDotsCollection_.size(); i++) {
     myDotsCollection_[i]->draw();
     }
     */
    
    // Draws the vector of friends
    for (int i=0; i<myLinesCollection_.size(); i++) {
        myLinesCollection_[i]->setup();
        
        myLinesCollection_[i]->user_status_for_lines = myUserCnt->getStatus();
        //ofSetLineWidth(2);
        myLinesCollection_[i]->whatLineToDraw(false);
        
        /*
         cout << "dbConnect::draw() - tag DO VECTOR: " << myLinesCollection_[i]->dotTag_ << endl;
         cout << "dbConnect::draw() - vol DO VECTOR: " << myLinesCollection_[i]->dotLoudness_ << endl;
         
         cout << "dbConnect::draw() - num of friends DO VECTOR: " << myLinesCollection_[i]->num_friends << endl;
         
         cout << "dbConnect::draw() - rank DO VECTOR: " << myLinesCollection_[i]->rank << endl;
         cout << "dbConnect::draw() - ypos DO VECTOR: " << myLinesCollection_[i]->ypos<<endl;
         cout << "dbConnect::draw() - status DO VECTOR: " << myLinesCollection_[i]->dotStatus_<<endl;
         cout << "dbConnect::draw() - name DO VECTOR: " << myLinesCollection_[i]->dotName_<<endl;
         cout << "dbConnect::draw() - ID DO VECTOR: " << myLinesCollection_[i]->dotID_<<endl;
         */
    }
    
    // Draws the user soundscape
    
    //  myNewTag->dotID_:
    
    
    
}




//newResponse is a method to create the listner for newResponseEvent.
//the first response defines if the user is online or not
//--------------------------------------------------------------
void dbConnect::newResponse(ofxHttpResponse & response){
    
    
    //    if (response.status == -1) {
    //        cout << "Connection not Available \nOFFLINE MODE ACTIVATED";
    // dbConOnline = false;
    // myUserCnt->appConnection_online_ = false;
    
    //    }else{
    //        myUserCnt->appConnection_online_ = true;
    
    //      if (dbConOnline == true) {
    responseStr = ofToString(response.responseBody);
    parseData(responseStr);
    //        }
    //    }
}


// set a timer for SENDING messages to the server // less time = more updates
//--------------------------------------------------------------
int dbConnect::timerForGetData(int update_buffer_time){
    
    int getData = 0;
    
    if (restartTime) {
        time (&start);
        time (&end);
        restartTime = false;
    }
    
    time(&end);
    dif = difftime (end,start);
    if (dif >= update_buffer_time) {
        restartTime = true;
        getData=1; // 1 means: getData
    }
    
    return getData;
}



// SENDS a form to the server asking if the user is registerd
//--------------------------------------------------------------
void dbConnect::askIfUserIsRegistered(string name, string pass){
    
    requestStr = "message sent: " + name;
    
    // starts a form
    ofxHttpForm form;
    // set the action url
    form.action = "http://labs.artes.ucp.pt/bitradio/hurlyburly/userCertification.php";
    // sets the method: POST or GET
    form.method = OFX_HTTP_POST;
    // creates a field for the form
    form.addFormField("name", name);
    form.addFormField("password", pass);
    // submits the form
    httpUtils.addForm(form); // submits the form
    
    // this method calls a usercertification.php which check if the user is on the database;
    // retrives number "1"
    
    
}


// SENDS a message (form) to the server requesting updated data (status, tag, volume, name, id, timestamp) from all friends
//--------------------------------------------------------------
void dbConnect::askDataToFriends(int userID){
    
    user_id = ofToString(userID);
    
    requestStr = user_id;
    cout << "askDataToFriends - REQUEST_STR: " << requestStr << endl;
    
    // starts a form
    ofxHttpForm form;
    // set the action url
    form.action = "http://labs.artes.ucp.pt/bitradio/hurlyburly/returnDataFromFriends.php";
    // sets the method: POST or GET
    form.method = OFX_HTTP_POST;
    // creates a field for the formdraw
    form.addFormField("myID", user_id);
    // submits the form
    httpUtils.addForm(form); // submits the form
    
}


// RECEIVES and Parses the retrieved data and print it on console
//--------------------------------------------------------------
void dbConnect::parseData(string response_string) {
    
    // this char is ment to hold the number of the function sending a message from PHP
    char checkFunctionNumber[50];
    
    // prints the response string on the console for debugging
    //    cout << "RESPONSE STRING(parseData): " <<responseStr << endl;
    // comentei em cima para não ter muito lixo na consola
    
    // parsing the responseStr to obtain which functins is sending data
    stringstream parsing(response_string, ios_base::in);
    parsing.getline(checkFunctionNumber, 20);
    cout << endl <<"(dbConnect::parseData(string response_string)) SERVER: What do you want? : "<< checkFunctionNumber << endl;
    
    
    
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // Check for Errors (E)
    if (checkFunctionNumber[0]=='E'){
        cout << "(dbConnect::parseData(string response_string)) SORRY: DEAD CONNECTION"<<endl;
    }
    
    
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // Return Data From Friends (4) - and updates the vector that will hold the information to be displays (lines or dots)
    if (checkFunctionNumber[0] == '4') {
        
        char frdUser_id[50];
        //char frdDate_time[50];
        char frdTag[50];
        char frdName[50];
        char frdVolume[50];
        char frdStatus[50];
        char dummy[50];
        //        char numberOfFriends[50];
        
        parsing.getline(dummy, 20);
        parsing.getline(numberOfFriends, 20);
        
        cout << "(dbConnect::parseData(string response_string)) SERVER: You asked for data from friends. \nNumber of friends : "<< numberOfFriends<<endl;
        //   numberOfFrdsRetrieved = ofToInt(numberOfFriends); // ERRADO!!! CORRECT PLEASE!!!!!!
        //   myUserCnt->setNumberOfFriendsOnline(numberOfFrdsRetrieved);// ERRADO!!! CORRECT PLEASE!!!!!!
        
        
        
        for (int i=0; i< ofToInt(numberOfFriends); i++) {
            parsing.getline(dummy, 20);
            //      cout<< "dumy(RESOULTS)::::: "<< dummy << endl;
            parsing.getline(frdUser_id, 20);
            //      cout<< "frdUser_id::::: "<< frdUser_id << endl;
            parsing.getline(frdStatus, 20);
            //      cout<< "frd status::::: "<< frdStatus << endl;
            parsing.getline(frdTag, 20);
            //      cout<<"frdTag:::::: " << frdTag << endl;
            parsing.getline(frdVolume, 20);
            //      cout<<"frdVol:::::: " << frdVolume << endl<<endl;
            parsing.getline(frdName, 20);
            //      cout<<"frdName:::::: " << frdName << endl<<endl;
            
            // if vector of dots (myLinesCollection_) is not empty check if user is or not part of it
            if (myLinesCollection_.size() > 0) {
                bool isPresent = false;
                // if freind is on the dotcollection_ then updates his tag/volume/status
                for (int j=0; j<myLinesCollection_.size(); j++) {
                    myLinesCollection_[j]->num_friends = ofToInt(numberOfFriends);
                    myLinesCollection_[j]->rank = j+1;
                    myLinesCollection_[j]->vPos();
                    myLinesCollection_[j]->changedTagFalg = false;
                    myLinesCollection_[j]->dotStatus_=ofToInt(frdStatus);
                    
                    if (myLinesCollection_[j]->dotID_ == ofToInt(frdUser_id)){
                        myLinesCollection_[j]->dotLoudness_ = ofToInt(frdVolume);
                        myLinesCollection_[j]->dotStatus_=ofToInt(frdStatus);
                        if (myLinesCollection_[j]->dotTag_ != ofToInt(frdTag)){
                            myLinesCollection_[j]->changedTagFalg = true;
                            myLinesCollection_[j]->dotTag_ = ofToInt(frdTag);
                        };
                        myLinesCollection_[j]->dotStatus_ = ofToInt(frdStatus);
                        myLinesCollection_[j]->vPos();
                        isPresent = true;
                    }
                }
                if (isPresent != true) {
                    // if friend is not on the mydotcollection_ add it to the vector:
                    t_lines* tempLine;
                    tempLine = new t_lines();
                    tempLine->num_friends = ofToInt(numberOfFriends);
                    tempLine->changedTagFalg = true;
                    tempLine->rank = myLinesCollection_.size()+1;
                    tempLine->dotTag_ = ofToInt(frdTag);
                    tempLine->dotStatus_ = ofToInt(frdStatus);
                    tempLine->dotLoudness_ = ofToInt(frdVolume);
                    tempLine->dotName_ = frdName;
                    tempLine->dotID_ = ofToInt(frdUser_id);
                    tempLine->vPos();
                    myLinesCollection_.push_back(tempLine);
                }
                
            } else {
                
                // if vector of dots (myLinesCollection_) is empty add the user
                t_lines* tempLine;
                tempLine = new t_lines();
                tempLine->num_friends = ofToInt(numberOfFriends);
                tempLine->changedTagFalg = true;
                tempLine->rank = 1;
                tempLine->dotTag_ = ofToInt(frdTag);
                tempLine->dotStatus_ = ofToInt(frdStatus);
                tempLine->dotLoudness_ = ofToInt(frdVolume);
                tempLine->dotName_ = frdName;
                tempLine->dotID_ = ofToInt(frdUser_id);
                tempLine->vPos();
                myLinesCollection_.push_back(tempLine);
            }
        }
    }
    
    
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // User Certification (1)
    if (checkFunctionNumber[0] == '1') {
        char dummy[20];
        cout << "(dbConnect::parseData(string response_string)) SERVER: you asked for a certification" << endl;
        // parsing the responseStr to obtain all the data
        stringstream parsingForCertification(response_string, ios_base::in);
        parsingForCertification.getline(dummy, 20);
        cout << "(dbConnect::parseData(string response_string)) DUMMY (parsedata): "<< dummy << endl;
        parsingForCertification.getline(check, 10); // this line tells if the user is on the database
        cout << "(dbConnect::parseData(string response_string)) CHECK (parsedata): "<< check << endl;
        
        
        if (check[0] == '1') {
            cout << "(dbConnect::parseData(string response_string)) SERVER: Congrats, you are on the database"<<endl;
            user_on_the_system = true;
            parsingForCertification.getline(message, 20);
            parsingForCertification.getline(userID, 10);
        }
        if (check[0]=='0') {
            cout << "(dbConnect::parseData(string response_string)) SERVER: sorry you are not on the list"<<endl;
            parsingForCertification.getline(message, 20);
            user_on_the_system = false;

        }
        
    }
    
    
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    // upload tag report (5)
    
    if (checkFunctionNumber[0] == '5') {
        
        char dummy[20];
        cout << "(dbConnect::parseData(string response_string)) SERVER: Yes, you tag was uploaded! Check values below" << endl;
        // parsing the responseStr to obtain all the data
        stringstream parsingUploadTag(response_string, ios_base::in);
        parsingUploadTag.getline(dummy, 20);
        for (int i=0; i<5; i++) {
            parsingUploadTag.getline(dummy, 20);
            cout << "(dbConnect::parseData(string response_string)) TAG (parsed data): "<< dummy << endl;
        }
        
    }
}


// SENDS/uploads new record (Tag) to "data" table (is called on the databaseManager.mm)
//--------------------------------------------------------------
void dbConnect::uploadNewTag(Tag* myNewTag){
    
    string t_l; // loudness
    string t_ID; // user ID
    string t_t; // sound classification
    string t_td; // timedate
    string t_n; // username
    
    
    t_l = ofToString(myNewTag->tagLoudness_);
    cout << "dbConnect::uploadNewTag(Tag* myNewTag) - loudness: " << t_l<<endl;
    
    t_t = ofToString(myNewTag->tagTag_);
    cout << "dbConnect::uploadNewTag(Tag* myNewTag) - tag: " << t_t<<endl;
    
    t_td = ofToString(myNewTag->tagTimeDate_);
    cout << "dbConnect::uploadNewTag(Tag* myNewTag) - ts: " << t_td<<endl;
    
    t_ID = ofToString(myNewTag->tagUserID_);
    cout << "dbConnect::uploadNewTag(Tag* myNewTag) - user id: " << t_ID<<endl;
    
    t_n = ofToString(myNewTag->tagUsername_);
    cout << "dbConnect::uploadNewTag(Tag* myNewTag) - username: " << t_n<<endl;
    
    requestStr = user_id;
    cout << "dbConnect::uploadNewTag(Tag* myNewTag) - uploadNewTag - REQUEST_STR: " << requestStr << endl<<endl;
    
    // starts a form
    ofxHttpForm form;
    // set the action url
    form.action = "http://labs.artes.ucp.pt/bitradio/hurlyburly/uploadNewTag.php";
    // sets the method: POST or GET
    form.method = OFX_HTTP_POST;
    // creates a field for the formdraw
    form.addFormField("user_id", t_ID);
    form.addFormField("date_time", t_td);
    form.addFormField("tag", t_t);
    form.addFormField("volume", t_l);
    form.addFormField("username", t_n);
    
    // submits the form
    httpUtils.addForm(form); // submits the form
    
}


void dbConnect::uploadNewTag(string t_ID, string t_l, string t_t, string t_td, string t_n){
    
    cout << "\ndbConnect::uploadNewTag(s, s, s, s, s) - loudness: " << t_l<<endl;
    cout << "dbConnect::uploadNewTag(s, s, s, s, s) - tag: " << t_t<<endl;
    cout << "dbConnect::uploadNewTag(s, s, s, s, s) - ts: " << t_td<<endl;
    cout << "dbConnect::uploadNewTag(s, s, s, s, s) - user id: " << t_ID<<endl;
    cout << "dbConnect::uploadNewTag(s, s, s, s, s) - username: " << t_n<<endl;
    
    requestStr = user_id;
    cout << "dbConnect::uploadNewTag (s, s, s, s, s) - uploadNewTag - REQUEST_STR: " << requestStr << endl;
    
    // starts a form
    ofxHttpForm form;
    // set the action url
    form.action = "http://labs.artes.ucp.pt/bitradio/hurlyburly/uploadNewTag.php";
    // sets the method: POST or GET
    form.method = OFX_HTTP_POST;
    // creates a field for the formdraw
    form.addFormField("user_id", t_ID);
    form.addFormField("date_time", t_td);
    form.addFormField("tag", t_t);
    form.addFormField("volume", t_l);
    form.addFormField("username", t_n);
    
    // submits the form
    httpUtils.addForm(form); // submits the form
    
}


// -- checks user status and updates the database accordinglly
void dbConnect::updateStatus(int u_id){
    
    requestStr = user_id;
    cout << "(dbConnect::updateStatus()) CHANGE STATUS WHENE QUITS: " << requestStr << endl;
    
    // starts a form
    ofxHttpForm form;
    // set the action url
    form.action = "http://labs.artes.ucp.pt/bitradio/hurlyburly/updateStatus.php";
    // sets the method: POST or GET
    form.method = OFX_HTTP_POST;
    // creates a field for the formdraw
    form.addFormField("user_id", ofToString(u_id));
    form.addFormField("status", ofToString(myUserCnt->getStatus()));
    // submits the form
    httpUtils.addForm(form); // submits the form
}



// checks if there is a connection with the server and
// -----------------------------------------------------------
void dbConnect::checkCon_and_askFriends_Inf(){
    
    ofURLFileLoader checkConnect;
    ofHttpResponse ConnectedResponse;
    
    //it is here for precaution. really wanna open/close the txt file coorectly;
    myUserCnt->status_changed(myUserCnt->getStatus());
    
    ConnectedResponse=checkConnect.get("http://labs.artes.ucp.pt/bitradio/hurlyburly/checkconnection.php");
    if (ConnectedResponse.status == -1) {
        myUserCnt->appConnection_online_ = false;
        cout << "\n(dbConnect::checkCon_and_askFriends_Inf()) NO CONNECTION WITH THE SERVER\n";
        //  dbConOnline = false;
    } else {
        cout << "\n(dbConnect::checkCon_and_askFriends_Inf()) CONNECTED WITH THE SERVER\n";
        myUserCnt->appConnection_online_ = true;
        // dbConOnline = true;
        
        b = myUserCnt->getStatus();
        if (b != a){
            updateStatus(myUserCnt->getUserId());
            a = myUserCnt->getStatus();
            cout <<"\n(dbConnect::checkCon_and_askFriends_Inf()) USER STATUS (user.mm): "<< a << endl;
            
        }
        
        cout << "dbConnect::checkCon_and_askFriends_Inf() - user: "<< myUserCnt->getName() <<" ID: " << myUserCnt->getUserId() << " - SENT a request to the server asking for frinds info" << endl;
        
        // asks data to by sending a form
        askDataToFriends(myUserCnt->getUserId());
        
    };
    
    
}


// checks if there is a connection with the server
// -----------------------------------------------------------
void dbConnect::checkCon(){
    
    ofURLFileLoader checkConnect;
    ofHttpResponse ConnectedResponse;
    
    //it is here for precaution. really wanna open/close the txt file coorectly;
    myUserCnt->status_changed(myUserCnt->getStatus());
    
    ConnectedResponse=checkConnect.get("http://labs.artes.ucp.pt/bitradio/hurlyburly/checkconnection.php");
    
    if (ConnectedResponse.status == -1) {
        myUserCnt->appConnection_online_ = false;
        cout << "\ndbConnect::checkCon() - NO CONNECTION WITH THE SERVER\n";
        // dbConOnline = false;
    } else {
        cout << "\ndbConnect::checkCon() - CONNECTED WITH THE SERVER\n";
        myUserCnt->appConnection_online_ = true;
        // dbConOnline = true;
        
        b = myUserCnt->getStatus();
        if (b != a){
            updateStatus(myUserCnt->getUserId());
            a = myUserCnt->getStatus();
            cout <<"\ndbConnect::checkCon() - USER STATUS: "<< a << endl;
            
        }
        
    };
}


// this function parses the txt file into several tags and uploads it into the server
// -----------------------------------------------------------
void dbConnect::parse_txt_file_to_tag(){
    
    ofBuffer mybuffer;
    mybuffer = ofBufferFromFile(ofxiPhoneGetDocumentsDirectory() +"t.txt");
    string complete;
    complete = mybuffer;
    istringstream iss(complete);
    string teststring;
    
    
    string l;
    string u;
    string t;
    string ts;
    string n;
    string test_last_line;
    

    
    /*
     while (iss) {
     iss >> teststring;
     cout << teststring << endl;
     };
     */
    
    int i = 0;
    while (iss) {
        
              switch (i) {
            case 0:
                iss >> test_last_line;
                cout << "\ndbConnect::parse_txt_file_to_tag() - TEST LAST LINE: " << test_last_line << endl;
                if (iss.eof()) {
                    cout << "dbConnect::parse_txt_file_to_tag() - Last line of the text file";
                    break;
                }
                u = test_last_line;
                cout << "dbConnect::parse_txt_file_to_tag() - user ID: " << u << endl;
                
                break;
            case 1:
                iss >> l;
                cout << "dbConnect::parse_txt_file_to_tag() - loudness: " << l << endl;

                break;
            case 2:
                iss >> t;
                cout << "dbConnect::parse_txt_file_to_tag() - tag: " << t << endl;
                break;
            case 3:
                iss >> ts;
                cout << "dbConnect::parse_txt_file_to_tag() - timestamp: " << ts << endl;
                break;
            case 4:
                iss >> n;
                cout << "dbConnect::parse_txt_file_to_tag() - username: " << n << endl;
                break;
                
            default:
                break;
        }
        i++;
        if (i==5) {
            cout << "dbConnect::parse_txt_file_to_tag() - DUMP tag from file to server\n";
            uploadNewTag(u, l, t, ts, n);
            i = 0;
        }
    }
    
    //não há necessidade de limpar o fichiro because it overwrites every time is created
    //myUserCnt->tempfile.clear();
    
    
    
}
