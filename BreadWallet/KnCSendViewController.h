
#import "KnCMainViewController.h"
#import "KnCExchangeRatesTableViewController.h"
#import "KnCAddressBookTableViewController.h"
#import "KnCAutocompleteTableViewController.h"
#import "KnCDenominationTableViewController.h"
#import "KnCBalanceLabel.h"
#import "KnCTxLabelsTableViewController.h"
#import "BRPaymentRequest.h"

@interface KnCSendViewController : UIViewController <UIAlertViewDelegate, KnCAddressBookDelegate, UITextFieldDelegate, KnCExchangeRatesDelegate, KnCAutocompleteDelegate, KnCDenominationDelegate>

@property (nonatomic, weak) IBOutlet UITextField *addressField;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *btcField;
@property (nonatomic, weak) IBOutlet UITextField *fiatField;
@property (nonatomic, weak) IBOutlet UITextField *labelField;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet KnCBalanceLabel *balanceLabel;
@property (nonatomic, weak) IBOutlet KnCBalanceLabel *localBalanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *sendInfoLabel;
@property (nonatomic, weak) IBOutlet UIButton *contactsButton;
@property (nonatomic, weak) IBOutlet UIButton *btcButton;
@property (nonatomic, weak) IBOutlet UIButton *fiatButton;
@property (nonatomic, weak) IBOutlet UIButton *labelButton;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

-(IBAction)buttonPressed:(id)sender;
-(IBAction)addressBookPressed:(id)sender;
-(IBAction)cameraPressed:(id)sender;
-(IBAction)toggleBalance:(id)sender;

@property (nonatomic, weak) KnCMainViewController *parent;

-(id)initWithParent:(KnCMainViewController*)parent;
-(void)startSendRequest:(BRPaymentRequest*)request;
-(void)emptyWallet;
@end
