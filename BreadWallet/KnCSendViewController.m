
#import "KnCSendViewController.h"

#import "BRWallet.h"
#import "BRWalletManager.h"
#import "BRPaymentProtocol.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"

#import "CurrencyUtil.h"
#import "String.h"
#import "NSString+Base58.h"
#import "SVProgressHUD.h"

#import "KnCDirectory.h"
#import "KnCAlertView.h"
#import "AddressBookProvider.h"
#import "NSManagedObject+Sugar.h"
#import "KnCKnownAddress.h"
#import "KnCDenomination.h"
#import "KnCViewController+UIViewController.h"
#import "KnCTxDataUtil.h"
#import "KnCColor+UIColor.h"
#import "KnCOneName.h"
#import "KnCOneNameViewController.h"
#import "SDWebImageManager.h"

#define ALERT_CONFIRM_FEE 2
#define ALERT_CONTACT_NEW_ADDRESS 3
#define ALERT_REQUEST_NEW_CONTACT 4

#define AMOUNT_PLACEHOLDER @"0.00"

typedef enum
{
    DEFAULT,
    SYNCING,
    FAILED,
} SEND_STATE;


@interface KnCSendViewController ()

@property (nonatomic, strong) BRTransaction *currentTx;
@property (nonatomic, weak) UITextField *currentTextfieldFocus;

@property (nonatomic, strong) AddressBookContact *selectedContact;

@property (nonatomic, strong) KnCAutocompleteTableViewController *autocompleteView;

@property (nonatomic) BOOL displayBalanceInLocalCurrency;

@property (nonatomic, strong) KnCOneNameViewController *oneNameView;

@property (nonatomic) SEND_STATE sendState;

@end

@implementation KnCSendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithParent:(KnCMainViewController*)parent
{
    self = [super init];
    if(self){
        self.parent = parent;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [String key:@"SEND"];
    
    [self.btcField addTarget:self
                  action:@selector(btcFieldChanged:)
        forControlEvents:UIControlEventEditingChanged];
    
    [self.fiatField addTarget:self
                      action:@selector(fiatFieldChanged:)
            forControlEvents:UIControlEventEditingChanged];
    
    [self.nameField setHidden:YES];
    [self localCurrencyDidChange];
    [self denominationChanged];
    
    [self.addressField addTarget:self action:@selector(addressFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.autocompleteView = [[KnCAutocompleteTableViewController alloc]init];
    self.autocompleteView.delegate = self;
    self.autocompleteView.view.layer.borderWidth = 1;
    self.autocompleteView.view.layer.borderColor = [UIColor grayColor].CGColor;
    [self.autocompleteView.view setAutoresizingMask:UIViewAutoresizingNone];
    [self setAutocompleteBoxHidden:YES];
    [self.scrollView addSubview:self.autocompleteView.view];
    
    [self validateInput];
    
    self.nameField.textColor = [UIButton appearance].tintColor;
    
    [self.scrollView setContentSize:CGSizeMake(0, self.sendButton.frame.origin.y+50)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    self.displayBalanceInLocalCurrency = NO;
    self.localBalanceLabel.alpha = 0;
    
    
    [self.contactsButton setTintColor:[UIColor teal]];
    [self.contactsButton setImage:[[UIImage imageNamed:@"contact"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self.labelButton setTintColor:[UIColor teal]];
    
    [self.sendInfoLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [self.sendInfoLabel setTextColor:[UIColor disabledGray]];
    
    self.oneNameView = [[KnCOneNameViewController alloc]init];
    [self setOneNameBoxHidden:YES];
    self.oneNameView.view.layer.borderWidth = self.autocompleteView.view.layer.borderWidth;
    self.oneNameView.view.layer.borderColor = self.autocompleteView.view.layer.borderColor;
    [self.scrollView addSubview:self.oneNameView.view];
    
    self.sendState = DEFAULT;
}

-(void)setAutocompleteBoxHidden:(BOOL)hidden
{
    [self fadeToggle:self.autocompleteView.view hidden:hidden];
}

-(void)syncWasStarted
{
    self.sendState = SYNCING;
    [self validateInput];
}

-(void)syncWasFinished
{
    self.sendState = DEFAULT;
    [self validateInput];
}

-(void)syncFailed
{
    self.sendState = FAILED;
    [self validateInput];
}


-(void)setOneNameBoxHidden:(BOOL)hidden
{
    [self fadeToggle:self.oneNameView.view hidden:hidden];
}

-(IBAction)toggleBalance:(id)sender
{
    [sender setEnabled:NO];
    
    if(self.displayBalanceInLocalCurrency){
        [self crossFadeIn:self.balanceLabel viewOut:self.localBalanceLabel];
    }else{
        [self crossFadeIn:self.localBalanceLabel viewOut:self.balanceLabel];
    }
    
    self.displayBalanceInLocalCurrency = !self.displayBalanceInLocalCurrency;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender setEnabled:YES];
    });
}

-(void)crossFadeIn:(UIView*)viewIn viewOut:(UIView*)viewOut
{
    [UIView animateWithDuration:0.25 animations:^{
        viewIn.alpha = 1;
        viewOut.alpha = 0;
    }];
}

-(void)updateBalance
{
    BRWallet *wallet = [[BRWalletManager sharedInstance]wallet];
    
    uint64_t totalBalance = [wallet balance];
    uint64_t balance = [wallet spendableBalance];
    
    if(totalBalance - balance != 0){
        [self.balanceInfoLabel setText:[String key:@"SEND_SPENDABLE_BALANCE"]];
    }else{
        [self.balanceInfoLabel setText:@""];
    }
    
    [self.balanceLabel setBalance:balance useLocalCurrency:NO];
    [self.localBalanceLabel setBalance:balance useLocalCurrency:YES];
}


-(void)keyboardWillShow:(NSNotification*)notification
{
    [self setScrollViewFrame:YES withSender:notification];
}
-(void)keyboardWillHide:(NSNotification*)notification
{
    [self setScrollViewFrame:NO withSender:notification];
}

-(void)didSelectOneNameUser:(NSString*)username json:(NSDictionary*)response
{
    [self setOneNameBoxHidden:YES];

    NSString *name = [[response objectForKey:@"name"]objectForKey:@"formatted"];
    
    if(!name){
        name = username;
    }
    
    NSString *address = [[response objectForKey:@"bitcoin"]objectForKey:@"address"];

    AddressBookContact *contact = [[AddressBookContact alloc]init];
    contact.address = address;
    contact.name = [NSString stringWithFormat:@"+%@",name];
    
    [self didPickAddressBookContact:contact];
    
    KnCContact *knownContact = [AddressBookProvider contactByAddress:address];
    
    if(!knownContact){
        NSString *title = [NSString stringWithFormat:[String key:@"SAVE_CONTACT_TITLE_PATTERN"],name];
        KnCAlertView *alertView = [[KnCAlertView alloc]initWithTitle:title message:address delegate:self cancelButtonTitle:[String key:@"NO"] otherButtonTitles:[String key:@"YES"], nil];
        alertView.block = ^{
            
            KnCContact *contact = [AddressBookProvider saveOneNameContact:name address:address username:username];
            
            if(contact){
                [self didPickAddressBookContact:[contact createAddressBookContactObject]];
                
                NSString *imageUrl = [[response objectForKey:@"avatar"]objectForKey:@"url"];
                if(imageUrl){
                    
                    __strong NSString *blockAddress = [NSString stringWithString:address];
                    
                    [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        
                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        if(image){
                            KnCContact *savedContact = [AddressBookProvider contactByAddress:blockAddress];
                            if(savedContact){
                                [AddressBookProvider setImage:image toContact:savedContact];
                            }
                        }
                    }];
                }
            }
            
        };
        [alertView show];
    }else{
        [self didPickAddressBookContact:[knownContact createAddressBookContactObject]];
    }
    
}

-(void)addressFieldDidChange:(id)sender
{
    BOOL show = NO;
    BOOL showOneName = NO;

    if([self.addressField.text rangeOfString:@"+"].location == 0){
        
        self.oneNameView.view.frame = CGRectMake(20, 142, 280, 44);
        
        NSString *username = [self.addressField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
        if(username.length > 0){
            
            showOneName = YES;
            
            [self.oneNameView setSearchingFor:username];
            self.oneNameView.didSelectCallback = nil;
            
            
            [KnCOneName lookupUsername:username completionCallback:^(NSString *responseUsername, NSDictionary *response) {
                
                NSString *inputUsername = [self.addressField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
                
                if([inputUsername isEqualToString:responseUsername]){
                
                    NSString *name = [[response objectForKey:@"name"]objectForKey:@"formatted"];
                    
                    if(!name){
                        name = responseUsername;
                    }
                    
                    NSString *address = [[response objectForKey:@"bitcoin"]objectForKey:@"address"];
                    
                    if(!address){
                        self.oneNameView.didSelectCallback = nil;
                        [self.oneNameView setNoUserFound:username];
                    }else{
                    
                        NSString *imageUrl = [[response objectForKey:@"avatar"]objectForKey:@"url"];
                        
                        [self.oneNameView setResult:name address:address imageUrl:imageUrl];

                        __weak id weakSelf = self;                    
                        [self.oneNameView setDidSelectCallback:^{
                            [weakSelf didSelectOneNameUser:responseUsername json:response];
                        }];
                    
                    }
                }
            } errorCallback:^(NSString *responseUsername, NSError *error) {
                self.oneNameView.didSelectCallback = nil;                
                NSString *inputUsername = [self.addressField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
                if([inputUsername isEqualToString:responseUsername]){
                    [self.oneNameView setNoUserFound:username];
                }
            }];
        }else if(self.addressField.text.length == 1){
            showOneName = YES;
            [self.oneNameView setOneNameHint];
        }
        
    }else if(self.addressField.text.length > 1){
        
        NSMutableArray *items = [NSMutableArray array];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(label like[c] '*%@*')",self.addressField.text]];
        
        NSArray *labels = [KnCContact objectsMatchingPredicate:predicate];
        
        [items addObjectsFromArray:labels];
        
        NSArray *knownAddresses = [KnCKnownAddress objectsMatching:@"address contains %@", self.addressField.text];
        
        for(KnCKnownAddress *knownAddress in knownAddresses){
            
            BOOL itemsHasContact = NO;
            
            for(KnCContact *contact in items){
                if([contact.address objectForKey:knownAddress.address]){
                    itemsHasContact = YES;
                    break;
                }
            }
            
            if(!itemsHasContact){
                [items addObject:knownAddress.contact];
            }
        }
        
        show = items.count > 0;
    
        [self.autocompleteView supplyItems: items];
    
        int frameHeight = 44;
        if([self isTallScreen] && items.count > 1){
            frameHeight *=2;
        }
        self.autocompleteView.view.frame = CGRectMake(20, 142, 280, frameHeight);
    }
    
    [self setAutocompleteBoxHidden:!show];
    [self setOneNameBoxHidden:!showOneName];
    [self validateInput];
}



-(void)didSelectItem:(id)item
{
    if([item isKindOfClass:[KnCContact class]]){
        KnCContact *contact = (KnCContact*)item;
        [self didPickAddressBookContact:[contact createAddressBookContactObject]];
    }
    [self.addressField resignFirstResponder];
    [self setAutocompleteBoxHidden:YES];
    
    [self.btcField becomeFirstResponder];
}

-(NSString*)tabBarIcon
{
    return @"send";
}

-(IBAction)buttonPressed:(id)sender
{
    if(sender == self.sendButton){
        [self send];
    }else if(sender == self.fiatButton){
        [self showExchangeRates];
    }else if(sender == self.btcButton){
        [self showDenominations];
    }else if(sender == self.labelButton){
        [self informLabel];
    }
}

-(void)informLabel
{
    NSString *title = @"";
    NSString *message = @"";
    
    if([self.labelField.placeholder isEqualToString:[String key:@"MESSAGE"]]){
        title = [String key:@"SEND_INFO_MESSAGE_TITLE"];
        message = [String key:@"SEND_INFO_MESSAGE_MESSAGE"];
    }else{
        title = [String key:@"SEND_INFO_NOTE_TITLE"];
        message = [String key:@"SEND_INFO_NOTE_MESSAGE"];
    }
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
}

-(void)showDenominations
{
    KnCDenominationTableViewController *vc = [[KnCDenominationTableViewController alloc]init];
    vc.delegate = self;
    [self presentViewControllerInNavigationController:vc];
}

-(void)showExchangeRates
{
    KnCExchangeRatesTableViewController *vc = [[KnCExchangeRatesTableViewController alloc]init];
    vc.delegate = self;
    [self presentViewControllerInNavigationController:vc];
}

-(void)presentViewControllerInNavigationController:(UIViewController*)vc
{
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.parent presentViewController:nav animated:YES completion:nil];
}

-(void)localCurrencyDidChange
{
    NSString *localCurrencyCode = [CurrencyUtil localCurrencyCode];
    [self.fiatButton setTitle:localCurrencyCode forState:UIControlStateNormal];
    [self.fiatButton setTitle:localCurrencyCode forState:UIControlStateHighlighted];
    [self fiatFieldChanged:self.fiatField];
}

-(void)denominationChanged
{
    KnCDenomination *denomination = [CurrencyUtil denomination];
    [self.btcButton setTitle:denomination.name forState:UIControlStateNormal];
    [self updateBalance];
    [self btcFieldChanged:self.btcField];
}

-(void)settingsInvalidated
{
    [self localCurrencyDidChange];
    [self denominationChanged];
    [self setupLabelFieldInput];
}

-(void)setupLabelFieldInput
{
    NSString *image = @"message";
    if([KnCDirectory isRegistred] && ((!self.selectedContact || (self.selectedContact && [self.selectedContact.source isEqualToString:SOURCE_DIRECTORY])))){
        self.labelField.placeholder = [String key:@"MESSAGE"];
    }else{
        self.labelField.placeholder = [String key:@"LABEL"];
        image = @"note";
    }
    
    [self.labelButton setImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupLabelFieldInput];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField == self.nameField){
        [self clearSelectedContact];
    }
    return YES;
}

-(void)clearSelectedContact
{
    self.nameField.text = nil;
    self.addressField.text = nil;
    self.selectedContact = nil;
    
    [self.nameField setHidden:YES];
    [self.addressField setHidden:NO];
    
    [self validateInput];
    
    [self setupLabelFieldInput];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.nameField){
        return NO;
    }
    return YES;
}

-(IBAction)cameraPressed:(id)sender
{
    [self.parent scanQR];
}

-(IBAction)addressBookPressed:(id)sender
{
    KnCAddressBookTableViewController *vc = [[KnCAddressBookTableViewController alloc]initWithMode:KnCAddressBookModeSelect];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.parent presentViewController:nav animated:YES completion:nil];
}

-(void)didPickAddressBookContact:(AddressBookContact *)contact
{
    self.selectedContact = [[AddressBookContact alloc]initWithContact:contact];
    self.addressField.text = contact.address;
    self.nameField.text = contact.name;
    
    [self.addressField setHidden:YES];
    [self.nameField setHidden:NO];
    
    [self validateInput];
    
    [self setupLabelFieldInput];
}

-(void)send
{
    [self createRequest:YES];
}

-(BOOL)isEmptyWalletRequest
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRWallet *wallet = [manager wallet];
    uint64_t balance = [wallet spendableBalance];
    uint64_t inputAmount = [self inputBtcAmount];
    
    return [[CurrencyUtil stringForBtcAmount:balance withSymbol:NO] isEqualToString:[CurrencyUtil stringForBtcAmount:inputAmount withSymbol:NO]];
}

-(void)createRequest:(BOOL)confirmFee
{
    
    if(![self.addressField.text isValidBitcoinAddress]){
        
        [self alertError:[String key:@"SEND_INVALID_ADDRESS"]];
        
        return;
    }
    
    
    BRWalletManager *m = [BRWalletManager sharedInstance];
    BRWallet *wallet = [m wallet];
    
    BOOL emptyWalletRequest = [self isEmptyWalletRequest];
    
    BRPaymentRequest *request = [BRPaymentRequest requestWithString:self.addressField.text];
    
    request.amount = [self inputBtcAmount];
    
    if(request.amount <= 0){
        return;
    }
    
    if(emptyWalletRequest){
        request.amount = [wallet spendableBalance];
    }
    
    if ([wallet containsAddress:request.paymentAddress]) {
        [self alertError:[String key:@"ERROR_SENDING_MONEY_TO_YOURSELF"]];
        return;
    }
    
    self.currentTx = [m.wallet transactionFor:request.amount to:request.paymentAddress withFee:NO];

    if(emptyWalletRequest){
        
        request.amount = [wallet spendableBalance] - self.currentTx.standardFee;
        
        self.currentTx = [m.wallet transactionFor:request.amount to:request.paymentAddress withFee:YES];
        
    }
    
    __block BOOL amountWithFeeOk = YES;
    
    self.currentTx = [m.wallet transactionFor:request.amount to:request.paymentAddress withFee:YES errorCallback:^(uint64_t balance, uint64_t amount, uint64_t standardFee) {
        
        NSLog(@"call back error. %llu is less than transaction amount:%llu", balance, amount + standardFee);
        
        amountWithFeeOk = NO;
        
        return;
    }];

    if(!amountWithFeeOk){
        
        [[[UIAlertView alloc]initWithTitle:[String key:@"TX_IMPOSSIBLE_FEE_TITLE"] message:[String key:@"TX_IMPOSSIBLE_FEE_MESSAGE"] delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
        
        return;
    }
    
    [self.btcField resignFirstResponder];
    [self.addressField resignFirstResponder];
    [self.fiatField resignFirstResponder];
    [self.labelField resignFirstResponder];
    
    [SVProgressHUD showWithStatus:[String key:@"SIGNING"] maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        BOOL signedTx = [wallet signTransaction:self.currentTx];
        [SVProgressHUD dismiss];
        
        if(!signedTx){
            [self alertError:[String key:@"ERROR_SENDING_SIGNING"]];
        }else{
            if(confirmFee){
                [self confirmFee:self.currentTx];
            }else{
                [self validateAddress:self.currentTx];
            }
        }
    });
    
}

-(void)setScrollViewFrame:(BOOL)hasKeyboard withSender:(NSNotification*)notification
{
    CGRect frame = self.scrollView.frame;
    if(hasKeyboard){
        
        NSDictionary *info  = notification.userInfo;
        NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
        
        CGRect rawFrame      = [value CGRectValue];
        CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
        
        frame.size.height = self.view.frame.size.height - keyboardFrame.size.height + self.parent.navigationController.navigationBar.frame.size.height + 5;
        __weak KnCSendViewController *weakSelf = self;
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.scrollView.frame = frame;
        }];
        
    }else{
        frame.size.height = self.view.frame.size.height;
        self.scrollView.frame = frame;
    }
    

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(!textField.inputAccessoryView){
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];

        UIBarButtonItem *prev = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"previous"] style:UIBarButtonItemStylePlain target:self action:@selector(previousField:)];
        [prev setEnabled:textField != self.addressField];
        UIBarButtonItem *prevNextSpacing = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [prevNextSpacing setWidth:15.0f];
        UIBarButtonItem *next = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"next"] style:UIBarButtonItemStylePlain target:self action:@selector(nextField:)];
        [next setEnabled:textField != self.labelField];
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelKeyboard:)];

        UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolbar setItems:@[prev, prevNextSpacing, next, flex, done]];
        textField.inputAccessoryView = toolbar;
    }
    
    self.currentTextfieldFocus = textField;
    
    if([self isTallScreen]){
        [self.scrollView setContentOffset:CGPointMake(0, 82) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y+50) animated:YES];
    }
    
}

-(void)nextField:(id)sender
{
    [self goNext:self.currentTextfieldFocus];
}

-(void)previousField:(id)sender
{
    [self goPrevious:self.currentTextfieldFocus];
}

-(void)cancelKeyboard:(id)sender
{
    [self.currentTextfieldFocus resignFirstResponder];
    [self setAutocompleteBoxHidden:YES];
}
-(void)dismissKeyboard:(id)sender
{
    [self textFieldShouldReturn:self.currentTextfieldFocus];

    [self setAutocompleteBoxHidden:YES];
}

-(uint64_t)inputBtcAmount
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    KnCDenomination *denomination = [CurrencyUtil denomination];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    
    NSNumber *number = [numberFormatter numberFromString:self.btcField.text];
    
    uint64_t amount = 0;
    
    if(denomination.shift == 0){
        amount = [manager amountForDouble:[number doubleValue] withMaximumFractionDigits:8];
    }else{
        amount = [CurrencyUtil convertAmountWithDenomiationToBits:[manager amountForDouble:[number doubleValue]]];
    }
    return amount;
}

-(void)btcFieldChanged:(id)sender
{
    uint64_t amount = [self inputBtcAmount];
    
    NSString *localString = [CurrencyUtil localCurrencyStringForAmount:amount withSymbol:NO];
    if([AMOUNT_PLACEHOLDER isEqualToString:localString]){
        self.fiatField.text = nil;
    }else{
        self.fiatField.text = localString;
    }
    [self validateInput];
}

-(void)fiatFieldChanged:(id)sender
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t localAmount = [manager amountForString:self.fiatField.text];
    uint64_t bitsAmount = [CurrencyUtil bitsAmountForLocalAmount:localAmount];
    
    if(bitsAmount == 0){
        self.btcField.text = nil;
    }else{
        self.btcField.text = [CurrencyUtil stringForBtcAmount:bitsAmount withSymbol:NO];
    }
    [self validateInput];
}

-(void)validateInput
{
    
    self.sendInfoLabel.text = @"";
    
    BOOL valid = NO;
    
    BOOL isEmptyWalletRequest = [self isEmptyWalletRequest];
    
    BOOL validAddress = [self.addressField.text isValidBitcoinAddress];
    
    if(self.addressField.text.length > 20 && !validAddress){
        self.sendInfoLabel.text = [String key:@"SEND_INVALID_ADDRESS"];
    }
    
    if(validAddress && ([self validateAmount] || isEmptyWalletRequest)){
        self.sendInfoLabel.text = @"";
        valid = YES;
    }
    
    if(isEmptyWalletRequest){
        [self.sendButton setTitle:[String key:@"EMPTY_WALLET"] forState:UIControlStateNormal];
        [self.sendButton setTitle:[String key:@"EMPTY_WALLET"] forState:UIControlStateDisabled];
    }else{
        [self.sendButton setTitle:[String key:@"SEND"] forState:UIControlStateNormal];
        [self.sendButton setTitle:[String key:@"SEND"] forState:UIControlStateDisabled];
    }

    [self.sendButton setEnabled:valid];
    
    
    if(self.sendState != DEFAULT){
        
        if(self.sendState == SYNCING){
            [self.sendButton setTitle:[String key:@"SEND_WAIT_FOR_SYNC"] forState:UIControlStateNormal];
            [self.sendButton setTitle:[String key:@"SEND_WAIT_FOR_SYNC"] forState:UIControlStateDisabled];
            self.sendInfoLabel.text = [String key:@"SEND_WAIT_FOR_SYNC_SUBTITLE"];
        }else if(self.sendState == FAILED){
            [self.sendButton setTitle:[String key:@"SEND_SYNC_FAILED"] forState:UIControlStateNormal];
            [self.sendButton setTitle:[String key:@"SEND_SYNC_FAILED"] forState:UIControlStateDisabled];
            self.sendInfoLabel.text = [String key:@"SEND_SYNC_FAILED_SUBTITLE"];
        }
        
        [self.sendButton setEnabled:NO];
        return;
    }
}

-(BOOL)validateAmount
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t balance = [[manager wallet]spendableBalance];
    uint64_t amount = [self inputBtcAmount];
    
    if(amount < 5460){
        if(amount > 0) self.sendInfoLabel.text = [String key:@"SEND_TOO_SMALL_AMOUNT"];
        return NO;
    }
    
    if(amount <= balance){
        return YES;
    }else{
        self.sendInfoLabel.text = [String key:@"SEND_TOO_LARGE_AMOUNT"];
        return NO;
    }
}

-(void)goPrevious:(UITextField*)textField
{
    if(textField == self.addressField){
        [textField resignFirstResponder];
    }else if(textField == self.btcField){
        [self.addressField becomeFirstResponder];
    }else if(textField == self.fiatField){
        [self.btcField becomeFirstResponder];
    }else if(textField == self.labelField){
        [self.fiatField becomeFirstResponder];
    }
}

-(void)goNext:(UITextField*)textField
{
    if(textField == self.addressField){
        [self.btcField becomeFirstResponder];
    }else if(textField == self.btcField){
        [self.fiatField becomeFirstResponder];
    }else if(textField == self.fiatField){
        [self.labelField becomeFirstResponder];
    }else if(textField == self.labelField){
        [textField resignFirstResponder];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self goNext:textField];
    
    return YES;
}

-(void)confirmFee:(BRTransaction*)tx
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    
    uint64_t amount = [m.wallet amountSentByTransaction:self.currentTx] - [m.wallet amountReceivedFromTransaction:self.currentTx];
    uint64_t fee = [m.wallet feeForTransaction:self.currentTx];
    
    NSString *message = [NSString stringWithFormat:[String key:@"SEND_FEE_CONFIRMATION_PATTERN"],[CurrencyUtil stringForBtcAmount:amount], [CurrencyUtil stringForBtcAmount:fee]];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String key:@"CONFIRM_FEE_TITLE"]
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:[String key:@"CANCEL"]
                                         otherButtonTitles:[String key:@"SEND"], nil];
    alert.tag = ALERT_CONFIRM_FEE;
    [alert show];
    
}

-(void)validateAddress:(BRTransaction*)tx
{
    KnCContact *contact = [AddressBookProvider contactByAddress:self.addressField.text];
    
    if([KnCDirectory isRegistred] && contact && contact.phone){
        
        NSString *savedAddress = [NSString stringWithString:self.addressField.text];
        NSString *savedPhoneNumber = [NSString stringWithString:contact.phone];
        
        [SVProgressHUD showWithStatus:[String key:@"VERIFYING_ADDRESS"] maskType:SVProgressHUDMaskTypeGradient];
        
        NSArray *requestArray = @[savedPhoneNumber];
        [KnCDirectory contactsRequest:requestArray completionCallback:^(NSDictionary *response) {
            
            [SVProgressHUD dismiss];
            
            BOOL hasNewAddress = NO;
            NSString *newAddress = nil;
            BOOL ok = NO;
            if(response && [response objectForKey:@"data"]){
                
                NSArray *data = [response objectForKey:@"data"];
                for(NSDictionary *contactData in data){
                    
                    NSString *telephone = [contactData objectForKey:@"telephoneNumber"];
                    NSString *bitcoinWalletAddress = [contactData objectForKey:@"bitcoinWalletAddress"];
                    
                    if(telephone && bitcoinWalletAddress && [telephone isEqualToString:savedPhoneNumber]
                       && [bitcoinWalletAddress isEqualToString:savedAddress]){
                        ok = YES;
                    }else if(telephone && bitcoinWalletAddress && [telephone isEqualToString:savedPhoneNumber]){
                        hasNewAddress = YES;
                        newAddress = [NSString stringWithString:bitcoinWalletAddress];
                    }
                }
            }
            
            if(ok){
                [self doSendTx:tx];
            }else if(hasNewAddress){
                [self contactHasNewAddress:newAddress oldAddress:savedAddress];
            }else{
                [self errorVerifyingContactsAddress:tx];
            }
            
            
        } errorCallback:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self errorVerifyingContactsAddress:tx];
        }];
        
    }else if(contact && contact.source && [contact oneNameUsername]){
        
        NSString *username = [contact oneNameUsername];
        NSString *savedAddress = [NSString stringWithString:self.addressField.text];
        
        [SVProgressHUD showWithStatus:[String key:@"VERIFYING_ADDRESS"] maskType:SVProgressHUDMaskTypeGradient];
        
        [KnCOneName lookupUsernameNotUsingCache:username completionCallback:^(NSString *username, NSDictionary *response) {
            
            [SVProgressHUD dismiss];
            
            BOOL ok = NO;
            BOOL hasNewAddress = NO;
            NSString *newAddress = nil;
            
            if(response && [response objectForKey:@"bitcoin"]){
            
                NSString *address = [[response objectForKey:@"bitcoin"]objectForKey:@"address"];
                
                if(address && [address isEqualToString:savedAddress]){
                    ok = YES;
                }else if(address){
                    hasNewAddress = YES;
                    newAddress = [NSString stringWithString:address];
                }
            
            }
            
            if(ok){
                [self doSendTx:tx];
            }else if(hasNewAddress){
                [self contactHasNewAddress:newAddress oldAddress:savedAddress];
            }else{
                [self errorVerifyingContactsAddress:tx];
            }
            
            
        } errorCallback:^(NSString *username, NSError *error) {
            [SVProgressHUD dismiss];
            [self errorVerifyingContactsAddress:tx];
        }];
        
        
    }else{
        [self doSendTx:tx];
    }
}

-(void)emptyWallet
{
    [self clearSelectedContact];

    BRWallet *wallet = [[BRWalletManager sharedInstance]wallet];
    
    uint64_t balance = [wallet spendableBalance];
    
    self.btcField.text = [CurrencyUtil stringForBtcAmount:balance withSymbol:NO];
    
    [self btcFieldChanged:self.btcField];
    
    [self validateInput];
}

-(void)askSaveContactFromRequest:(BRPaymentRequest*)request
{
    
    NSString *address = [NSString stringWithString:request.paymentAddress];
    NSString *label = [NSString stringWithString:request.label];
    NSString *title = [NSString stringWithFormat:[String key:@"SAVE_CONTACT_TITLE_PATTERN"],label];
    KnCAlertView *alertView = [[KnCAlertView alloc]initWithTitle:title message:address delegate:self cancelButtonTitle:[String key:@"NO"] otherButtonTitles:[String key:@"YES"], nil];
    alertView.block = ^{
        
        KnCContact *contact = [AddressBookProvider saveContact:label address:address];
        if(contact){
            [self didPickAddressBookContact:[contact createAddressBookContactObject]];
        }
        
    };
    alertView.tag = ALERT_CONTACT_NEW_ADDRESS;
    [alertView show];
}

-(void)startSendRequest:(BRPaymentRequest*)request
{
    [self clearSelectedContact];
    
    KnCContact *contact = [AddressBookProvider contactByAddress:request.paymentAddress];
    if(contact){
        AddressBookContact *abc = [contact createAddressBookContactObject];
        if(abc){
            [self didPickAddressBookContact:abc];
        }else{
            self.addressField.text = request.paymentAddress;
        }
    }else{
        
        if(request.label){
            [self askSaveContactFromRequest:request];
        }
        
        self.addressField.text = request.paymentAddress;
    }
    
    if(request.amount > 0){
        
        KnCDenomination *denomination = [CurrencyUtil denomination];
        
        self.btcField.text = [CurrencyUtil formatValue:request.amount withPrecision:denomination.precision andShift:denomination.shift];
        
        [self btcFieldChanged:self.btcField];
    }
    
    if(request.message){
        self.labelField.text = request.message;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.btcField becomeFirstResponder];
    });

    [self validateInput];
}

-(void)contactHasNewAddress:(NSString*)newAddress oldAddress:(NSString*)oldAddress
{
    KnCContact *contact = [AddressBookProvider contactByAddress:oldAddress];
    NSString *title = [NSString stringWithFormat:[String key:@"SEND_CONTACT_HAS_NEW_ADDRESS_PATTERN"],contact.label];
    NSString *message = [NSString stringWithFormat:[String key:@"SEND_CONTACT_HAS_NEW_ADDRESS_MESSAGE_PATTERN"],newAddress, oldAddress];
    KnCAlertView *alert = [[KnCAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"SEND_SAVE_AND_SEND"], nil];

    alert.block = ^{
      
        KnCContact *contact = [AddressBookProvider contactByAddress:oldAddress];
        self.selectedContact.address = [NSString stringWithString:newAddress];
        self.addressField.text = newAddress;
        [AddressBookProvider saveAddress:newAddress toContact:contact];
        [self createRequest:NO];
    };
    
    alert.tag = ALERT_CONTACT_NEW_ADDRESS;
    [alert show];
}

-(void)errorVerifyingContactsAddress:(BRTransaction*)tx
{
    KnCAlertView *alertView = [[KnCAlertView alloc]initWithTitle:[String key:@"SEND_ERROR_VERIFY_CONTACT_ADDRESS"] message:[String key:@"SEND_ERROR_VERIFY_CONTACT_ADDRESS_MESSAGE"] delegate:nil cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"SEND_TO_UNVALIDATED_ADDRESS"], nil];
    alertView.block = ^{
        [self doSendTx:tx];
    };
    [alertView show];
}


-(void)doSendTx:(BRTransaction*)tx
{
    [SVProgressHUD showWithStatus:[String key:@"SENDING"] maskType:SVProgressHUDMaskTypeGradient];
    
    [[BRPeerManager sharedInstance] publishTransaction:tx completion:^(NSError *error) {
        
        
        [SVProgressHUD dismiss];
        
        if(!error){
            [SVProgressHUD showSuccessWithStatus:[String key:@"SENT"]];
            
            [self uploadTx:tx];
            
            if(self.labelField.text.length > 0)
            {
                
                if([self.labelField.placeholder isEqualToString:[String key:@"MESSAGE"]]){
                    [KnCTxDataUtil saveMessage:self.labelField.text toTx:tx.txIdAsString];
                }else{
                    [KnCTxDataUtil saveLabel:self.labelField.text toTx:tx.txIdAsString];
                }
                [self.parent labelWasUpdated];
            }
            
            self.addressField.text = @"";
            self.btcField.text = @"";
            self.fiatField.text = @"";
            self.labelField.text = @"";
            [self clearSelectedContact];
            
            [self updateBalance];
            
        }else{
            
            NSLog(@"error sending %@",error);
            [self alertError:[String key:@"ERROR_SENDING"]];
            
        }
        
        self.currentTx = nil;
        
    }];
}

-(void)askLabel:(BRTransaction*)tx
{
    KnCAlertView *alertView = [[KnCAlertView alloc]initWithTitle:[String key:@"ALERT_NEW_TX_LABEL_TITLE"] message:[String key:@"ALERT_NEW_TX_LABEL_MESSAGE"] delegate:nil cancelButtonTitle:[String key:@"NO"] otherButtonTitles:[String key:@"YES"], nil];
    [alertView setBlock:^{
        [self labelTx:tx];
    }];
    alertView.delegate = self;
    [alertView show];
}

-(void)labelTx:(BRTransaction*)tx
{
    KnCTxLabelsTableViewController *vc = [[KnCTxLabelsTableViewController alloc]initWithBRTransaction:tx];
    vc.labelsDelegate = self.parent;
    [self.parent presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:YES completion:nil];
}

-(void)uploadTx:(BRTransaction*)tx
{
    NSString *counterpart = @"";
    if(self.selectedContact){
        counterpart = self.selectedContact.phone;
    }
    
    [KnCDirectory submitTxRequest:counterpart message:self.labelField.text sent:YES txId:tx.txIdAsString payload:nil completionCallback:^(NSDictionary *response) {
        
    } errorCallback:^(NSError *error) {
        
    }];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_CONFIRM_FEE && buttonIndex == 1){
        [self validateAddress:self.currentTx];
    }else if([alertView isKindOfClass:[KnCAlertView class]] && buttonIndex == 1){
        KnCAlertView *kAlert = (KnCAlertView*)alertView;
        if(kAlert.block){
            kAlert.block();
        }
    }
}

-(void)alertError:(NSString*)message
{
    [[[UIAlertView alloc]initWithTitle:[String key:@"SEND_ERROR_TITLE"] message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
