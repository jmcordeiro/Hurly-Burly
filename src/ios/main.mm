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
#include "ofMain.h"
#include "testApp.h"

//========================================================================
int main() {
/*
	ofSetupOpenGL(960, 640, OF_FULLSCREEN);			// <-------- setup the GL context

	ofRunApp(new testApp);
  */
    /*
    ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
	
	iOSWindow->enableDepthBuffer();
	//iOSWindow->enableAntiAliasing(4);
	
	//iOSWindow->enableRetinaSupport();
	
	ofSetupOpenGL(iOSWindow, 480, 320, OF_FULLSCREEN);
	ofRunApp(new testApp);

*/
    
    ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
    iOSWindow->enableRetinaSupport();
    ofSetupOpenGL(iOSWindow, 640,960, OF_FULLSCREEN);
    
	ofRunApp(new testApp);

    
    
}
