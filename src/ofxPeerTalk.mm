#include "ofxPeerTalk.h"
#import "ofxPeerTalkBridge.h"
#include <iostream>
using namespace std;


void ofxPeerTalk::setup() {
	
	cout << __PRETTY_FUNCTION__ << endl;
	bridge = (__bridge void*)[[ofxPeerTalkBridge alloc] initWithInterface:this];

}

void ofxPeerTalk::method1() {
	cout << __PRETTY_FUNCTION__ << endl;
}

void ofxPeerTalk::method2() {
	cout << __PRETTY_FUNCTION__ << endl;
}