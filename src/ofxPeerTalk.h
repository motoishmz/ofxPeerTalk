#pragma once
#include "ofxPeerTalkInterface.h"

class ofxPeerTalk : public ofxPeerTalkInterface {
	
public:
	
	void setup();
	void method1();
	void method2();
	
private:
	
	void *bridge;
};

