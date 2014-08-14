
#import <UIKit/UIKit.h>

#import "KnCCountryPickerTableViewController.h"

@interface KnCWelcomeViewController : UIViewController <UIAlertViewDelegate, KnCCountryPickerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *phoneNumberField;
@property (nonatomic, weak) IBOutlet UITextField *countryNumberField;
@property (nonatomic, weak) IBOutlet UIButton *submitButton;
@property (nonatomic, weak) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, weak) IBOutlet UIButton *countryButton;

@property (nonatomic, weak) IBOutlet UITextField *codeField;
@property (nonatomic, weak) IBOutlet UIButton *submitCodeButton;
@property (nonatomic, weak) IBOutlet UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UILabel *waitingLabel;
@property (nonatomic, weak) IBOutlet UILabel *waitingPhoneNumberLabel;

-(IBAction)submit:(id)sender;
-(IBAction)selectCountry:(id)sender;
-(IBAction)submitCode:(id)sender;

@end
