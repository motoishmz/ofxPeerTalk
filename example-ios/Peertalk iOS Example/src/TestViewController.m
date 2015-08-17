#import "TestViewController.h"
#import "PeerTalkWrapper.h"

@implementation TestViewController

- (IBAction)testAction:(id)sender {
	
	UIButton *ui = (UIButton *)sender;
	NSString *value = [NSString stringWithFormat:@"%d", ui.tag];
	
	[PEERTALK sendMessage:value];
}

- (IBAction)valueChanged:(id)sender {
	
	UISlider *ui = (UISlider *)sender;
	NSString *value = [NSString stringWithFormat:@"%f", ui.value];
	
	[PEERTALK sendMessage:value];
}
@end
