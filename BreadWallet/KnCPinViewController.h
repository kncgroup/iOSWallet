
#import <UIKit/UIKit.h>

@interface KnCPinViewController : UIViewController

typedef enum
{
    PIN_DEFAULT,
    PIN_CURRENT,
    PIN_SET,
    PIN_CONFIRM,
    PIN_CANCELABLE
} PIN_MODE;

@property (nonatomic, weak) IBOutlet UIView *digitsSuperView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIView *digit0;
@property (nonatomic, weak) IBOutlet UIView *digit1;
@property (nonatomic, weak) IBOutlet UIView *digit2;
@property (nonatomic, weak) IBOutlet UIView *digit3;

@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

-(IBAction)deleteCancelButtonPressed:(id)sender;
-(IBAction)pinButtonPressed:(UIButton*)sender;

@property (nonatomic, copy) void (^completionBlock)(BOOL success);

-(id)initConfigureMode;
-(id)initCancelable;

@end
