
#import <UIKit/UIKit.h>
#import "KnCMainViewController.h"
#import <MessageUI/MessageUI.h>

@interface KnCReceiveViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *qrView;
@property (nonatomic, weak) IBOutlet UIButton *addressButton;

@property (nonatomic, weak) KnCMainViewController *parent;

-(id)initWithParent:(KnCMainViewController*)parent;

-(IBAction)buttonPressed:(id)sender;

@end
