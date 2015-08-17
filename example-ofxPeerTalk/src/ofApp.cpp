#include "ofMain.h"
#include "ofxPeerTalk.h"

class ofApp : public ofBaseApp
{
	
	ofxPeerTalk myclass;
	
public:
	
	void setup()
	{
		ofSetFrameRate(60);
		ofSetVerticalSync(true);
		myclass.setup();
	}
};


#pragma mark -
#pragma mark main
int main(){
	ofSetupOpenGL(500, 400, OF_WINDOW);
	ofRunApp(new ofApp());
}
