#import "ofxPeerTalkInterface.h"
#import <Foundation/foundation.h>
#import "PTChannel.h"

@interface ofxPeerTalkBridge : NSObject <PTChannelDelegate>
{
	__strong ofxPeerTalkInterface *interface_;
}

- (instancetype) initWithInterface:(ofxPeerTalkInterface *)interface;
- (void)sendMessage:(NSString*)message;
@end