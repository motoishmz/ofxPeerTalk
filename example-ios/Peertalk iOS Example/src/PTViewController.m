#import "PTViewController.h"
#import "PeerTalkWrapper.h"

@implementation PTViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];

}

- (void)viewDidUnload {
  [super viewDidUnload];
}


#pragma mark - IBActions

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
- (IBAction)firstViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
	NSLog(@"First view return action invoked.");
}
@end
