
#import <UIKit/UIKit.h>

@interface KncRestoreViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UIButton *generateButton;

-(IBAction)buttonPressed:(id)sender;

@end
