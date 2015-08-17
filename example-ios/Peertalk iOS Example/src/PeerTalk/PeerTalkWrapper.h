#import <Foundation/Foundation.h>
#import "PTChannel.h"

#define PEERTALK [PeerTalkWrapper sharedInstance]

@interface PeerTalkWrapper : NSObject <PTChannelDelegate>

+ (PeerTalkWrapper *)sharedInstance;
- (void)sendMessage:(NSString*)message;

@end
