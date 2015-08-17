#import "PTExampleProtocol.h"
#import "PeerTalkWrapper.h"

static PeerTalkWrapper * sharedInstance = nil;

@interface PeerTalkWrapper () {
	__weak PTChannel *serverChannel_;
	__weak PTChannel *peerChannel_;
	
}
- (void)putLog:(NSString*)message;
- (void)sendDeviceInfo;
@end


@implementation PeerTalkWrapper

#pragma mark - Singleton

+ (PeerTalkWrapper *)sharedInstance {
	
	static dispatch_once_t once;
	dispatch_once( &once, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
	__block id ret = nil;
	
	static dispatch_once_t once;
	dispatch_once( &once, ^{
		sharedInstance = [super allocWithZone:zone];
		ret = sharedInstance;
	});
	
	return  ret;
	
}

- (id)copyWithZone:(NSZone *)zone {
	
	return self;
}


#pragma mark - Lyfecycle

- (id) init {
	
	self = [super init];
	
	if (self) {
		
		PTChannel *channel = [PTChannel channelWithDelegate:self];
		[channel listenOnPort:PTExampleProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
			if (error) {
				[self putLog:[NSString stringWithFormat:@"Failed to listen on 127.0.0.1:%d: %@", PTExampleProtocolIPv4PortNumber, error]];
			} else {
				[self putLog:[NSString stringWithFormat:@"Listening on 127.0.0.1:%d", PTExampleProtocolIPv4PortNumber]];
				serverChannel_ = channel;
			}
		}];
	}
	
	return self;
}

- (void) dealloc {
	if (serverChannel_) {
		[serverChannel_ close];
	}
}


#pragma mark - Message handling

- (void)sendMessage:(NSString*)message {
	
	if (peerChannel_) {
		dispatch_data_t payload = PTExampleTextDispatchDataWithString(message);
		[peerChannel_ sendFrameOfType:PTExampleFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
			if (error) {
				NSLog(@"Failed to send message: %@", error);
			}
		}];
		[self putLog:[NSString stringWithFormat:@"[you]: %@", message]];
	} else {
		[self putLog:@"Can not send message — not connected"];
	}
}

- (void)putLog:(NSString*)message {
	
	//	デバッグ用。
	//	ここのデータをtimestampと一緒に記録しておくべき
	NSLog(@"%@", message);
}


#pragma mark - Communicating (from Example)


- (void)sendDeviceInfo {
	if (!peerChannel_) {
		return;
	}
	
	NSLog(@"Sending device info over %@", peerChannel_);
	
	UIScreen *screen = [UIScreen mainScreen];
	CGSize screenSize = screen.bounds.size;
	NSDictionary *screenSizeDict = (__bridge_transfer NSDictionary*)CGSizeCreateDictionaryRepresentation(screenSize);
	UIDevice *device = [UIDevice currentDevice];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
						  device.localizedModel, @"localizedModel",
						  [NSNumber numberWithBool:device.multitaskingSupported], @"multitaskingSupported",
						  device.name, @"name",
						  (UIDeviceOrientationIsLandscape(device.orientation) ? @"landscape" : @"portrait"), @"orientation",
						  device.systemName, @"systemName",
						  device.systemVersion, @"systemVersion",
						  screenSizeDict, @"screenSize",
						  [NSNumber numberWithDouble:screen.scale], @"screenScale",
						  nil];
	dispatch_data_t payload = [info createReferencingDispatchData];
	[peerChannel_ sendFrameOfType:PTExampleFrameTypeDeviceInfo tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
		if (error) {
			NSLog(@"Failed to send PTExampleFrameTypeDeviceInfo: %@", error);
		}
	}];
}


#pragma mark - PTChannelDelegate

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
	if (channel != peerChannel_) {
		// A previous channel that has been canceled but not yet ended. Ignore.
		return NO;
	} else if (type != PTExampleFrameTypeTextMessage && type != PTExampleFrameTypePing) {
		NSLog(@"Unexpected frame of type %u", type);
		[channel close];
		return NO;
	} else {
		return YES;
	}
}

// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload {
	//NSLog(@"didReceiveFrameOfType: %u, %u, %@", type, tag, payload);
	if (type == PTExampleFrameTypeTextMessage) {
		PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.data;
		textFrame->length = ntohl(textFrame->length);
		NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
		[self putLog:[NSString stringWithFormat:@"[%@]: %@", channel.userInfo, message]];
	} else if (type == PTExampleFrameTypePing && peerChannel_) {
		[peerChannel_ sendFrameOfType:PTExampleFrameTypePong tag:tag withPayload:nil callback:nil];
	}
}

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
	if (error) {
		[self putLog:[NSString stringWithFormat:@"%@ ended with error: %@", channel, error]];
	} else {
		[self putLog:[NSString stringWithFormat:@"Disconnected from %@", channel.userInfo]];
	}
}

// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address {
	// Cancel any other connection. We are FIFO, so the last connection
	// established will cancel any previous connection and "take its place".
	if (peerChannel_) {
		[peerChannel_ cancel];
	}
	
	// Weak pointer to current connection. Connection objects live by themselves
	// (owned by its parent dispatch queue) until they are closed.
	peerChannel_ = otherChannel;
	peerChannel_.userInfo = address;
	[self putLog:[NSString stringWithFormat:@"Connected to %@", address]];
	
	// Send some information about ourselves to the other end
	[self sendDeviceInfo];
}

@end
