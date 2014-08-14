
#import "KnCWelcomeViewController.h"

#import "UIViewController+KnC.h"

#import "KnCDirectory.h"

#import "BRWalletManager.h"
#import "BRWallet.h"

#import "String.h"
#import "SVProgressHUD.h"

#import "RMPhoneFormat.h"
#import "KnCColor+UIColor.h"
#import "AddressBookProvider.h"

#define ALERT_CONFIRM_NUMBER 10
#define ALERT_RESEND 11

@interface KnCWelcomeViewController ()

@property (nonatomic, strong) KncCountry *defaultCountry;

@property (nonatomic) NSInteger state;

@property (nonatomic) NSInteger secondsLeft;

@property (nonatomic, strong) RMPhoneFormat *phoneFormat;

@property (nonatomic) BOOL active;

@end

@implementation KnCWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self appendKnCLogo];
    
    self.phoneFormat = [RMPhoneFormat instance];
    
    [self.codeField setAlpha:0];
    [self.timerLabel setAlpha:0];
    [self.submitCodeButton setAlpha:0];
    [self.waitingLabel setAlpha:0];
    [self.waitingPhoneNumberLabel setAlpha:0];
    self.waitingPhoneNumberLabel.textColor = [UIColor teal];
    
    [self.waitingPhoneNumberLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    
    [self.phoneNumberField becomeFirstResponder];
    
    [self.welcomeLabel setText:[String key:@"WIZARD_WELCOME_TEXT"]];
    
    [self.waitingLabel setText:[String key:@"WIZARD_SMS_SENT_TO"]];
    
    [self.submitButton setTitle:[String key:@"WIZARD_LET_ME_IN"] forState:UIControlStateNormal];
    [self.submitButton setTitle:[String key:@"WIZARD_LET_ME_IN"] forState:UIControlStateHighlighted];
    
    [self.submitCodeButton setTitle:[String key:@"WIZARD_SUBMIT_CODE"] forState:UIControlStateNormal];
    [self.submitCodeButton setTitle:[String key:@"WIZARD_SUBMIT_CODE"] forState:UIControlStateHighlighted];
    
    self.defaultCountry = [[KncCountry alloc]init];
    self.defaultCountry.displayName = @"United Kingdom";
    self.defaultCountry.callingCode = @"44";
    self.defaultCountry.isoCode = @"GB";
    
    [self didPickCountry:self.defaultCountry];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timerLabelTapped:)];
    tap.numberOfTapsRequired = 1;
    [self.timerLabel addGestureRecognizer:tap];
    self.active = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.active = NO;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.active = YES;
}

-(void)timerLabelTapped:(id)sender
{
    if(self.secondsLeft < 1){
        [self askResendCode];
    }

}

-(IBAction)selectCountry:(id)sender
{
    KnCCountryPickerTableViewController *vc = [[KnCCountryPickerTableViewController alloc]initWithCountry:self.defaultCountry];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(IBAction)submit:(id)sender;
{
    if([self validatePhoneNumberInput]){
        [self promptConfirmNumber];
    }else{
        [SVProgressHUD showErrorWithStatus:[String key:@"WIZARD_INVALID_PHONE_NUMBER"]];
    }
}

-(IBAction)submitCode:(id)sender
{
    if([self validateCode]){
        
        [self fadeOut:self.timerLabel];
        [self fadeOut:self.submitCodeButton];
        [self fadeOut:self.codeField];
        [self fadeOut:self.waitingPhoneNumberLabel];
        [self fadeOut:self.waitingLabel];
        [self submitValidation:self.codeField.text];
    }
}

-(BOOL)validatePhoneNumberInput
{
    if(self.countryNumberField.text.length > 0 && self.phoneNumberField.text.length > 0){
        
        NSString *phoneNumber = [NSString stringWithFormat:@"%@%@",self.countryNumberField.text,self.phoneNumberField.text];
        return [self.phoneFormat isPhoneNumberValid:phoneNumber];
        
    }
    
    return NO;
}

-(BOOL)validateCode
{
    return self.codeField.text.length > 0;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_CONFIRM_NUMBER && buttonIndex == 1){
        [self didConfirmNumber];
    }else if(alertView.tag == ALERT_RESEND && buttonIndex == 1){
        [self requestResend];
    }
}


-(NSString*)phoneNumber
{
    return [NSString stringWithFormat:@"%@%@",self.countryNumberField.text,self.phoneNumberField.text];
}

-(NSString*)fixedPhoneNumber
{
    NSString *telephoneNumber = [self phoneNumber];
    return [telephoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
}

-(void)promptConfirmNumber
{
    NSString *phoneNumber = [self phoneNumber];
    NSString *message = [NSString stringWithFormat:[String key:@"WIZARD_PHONE_NUMBER_MESSAGE_PATTERN"],phoneNumber];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String key:@"WIZARD_PHONE_NUMBER_CONFIRMATION_TITLE"] message:message delegate:self cancelButtonTitle:[String key:@"EDIT"] otherButtonTitles:[String key:@"YES"], nil];
    alert.tag = ALERT_CONFIRM_NUMBER;
    [alert show];
}

-(void)didConfirmNumber
{
    [self fadeOut:self.phoneNumberField];
    [self fadeOut:self.countryNumberField];
    [self fadeOut:self.submitButton];
    [self fadeOut:self.welcomeLabel];
    [self fadeOut:self.countryButton];
    [self submitRegistration:[self phoneNumber]];
}

-(void)submitValidation:(NSString*)code
{
    [SVProgressHUD show];
    
    [KnCDirectory validateRegistrationRequest:code completionCallback:^(NSDictionary *response) {
        [SVProgressHUD dismiss];
        [self validationDone];
    } errorCallback:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self errorOnRegistration:error];
    }];
}

-(void)requestResend
{
    [SVProgressHUD show];
    
    [KnCDirectory requestResendCodeRequest:[self fixedPhoneNumber] completionCallback:^(NSDictionary *response) {
        
        [SVProgressHUD dismiss];
        [self registrationDone:response];
        
    } errorCallback:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self errorOnRegistration:error];
        
    }];
    
}

-(void)submitRegistration:(NSString*)telephoneNumber
{
    NSString *walletAddress = [[[BRWalletManager sharedInstance]wallet] receiveAddress];
    NSString *phoneID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *callingCode = [self.countryNumberField.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:callingCode forKey:@"COUNTRY_CALLING_CODE"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.waitingPhoneNumberLabel setText:telephoneNumber];
    
    [SVProgressHUD show];
    
    NSString *fixedNumber = [telephoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    [KnCDirectory registrationRequest:fixedNumber bitcoinWalletAddress:walletAddress phoneID:phoneID completionCallback:^(NSDictionary *response) {
        
        [self registrationDone:response];
        
        [KnCDirectory saveRegistrationRequest:response];
        
        [SVProgressHUD dismiss];
        
    } errorCallback:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self errorOnRegistration:error];
    }];
}

-(void)validationDone
{
    [KnCDirectory setRegistered:YES];
    [AddressBookProvider lookupContacts];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)fadeOutEnterCodeView
{
    [self fadeOut:self.codeField];
    [self fadeOut:self.submitCodeButton];
    [self fadeOut:self.timerLabel];
    [self fadeOut:self.waitingPhoneNumberLabel];
    [self fadeOut:self.waitingLabel];
}

-(void)fadeInEnterCodeView
{
    [self fadeIn:self.codeField];
    [self fadeIn:self.submitCodeButton];
    [self fadeIn:self.timerLabel];
    [self fadeIn:self.waitingPhoneNumberLabel];
    [self fadeIn:self.waitingLabel];
}

-(void)fadeInWelcomeView
{
    [self fadeIn:self.phoneNumberField];
    [self fadeIn:self.countryNumberField];
    [self fadeIn:self.submitButton];
    [self fadeIn:self.welcomeLabel];
    [self fadeIn:self.countryButton];
}

-(void)registrationDone:(NSDictionary*)response
{
    
    [self fadeInEnterCodeView];
    
    [self.codeField becomeFirstResponder];
    
    [self startTimer];
    
    if([response objectForKey:@"data"]){
        
        NSString *code = [[response objectForKey:@"data"] objectForKey:@"code"];
        if(!code){
            code = [[response objectForKey:@"data"] objectForKey:@"authToken"];
        }
        
        [self.codeField setText:code];
    }
    
}

-(void)timerTick:(NSTimer*)timer
{
    if(self.secondsLeft > 0 ){
        self.secondsLeft -- ;
        self.timerLabel.textColor = [UIColor blackColor];
        int minutes = (self.secondsLeft % 3600) / 60;
        int seconds = (self.secondsLeft %3600) % 60;
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
    }else{
        [timer invalidate];
        [self askResendCode];
        
        self.timerLabel.text = [NSString stringWithFormat:@"%@ 0:00",[String key:@"SMS_VERIFICATION_FAILED_TITLE"]];
        self.timerLabel.textColor = [UIColor teal];
    }
}

-(void)askResendCode
{
    if(!self.active) return;
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String key:@"SMS_VERIFICATION_FAILED_TITLE"] message:[String key:@"SMS_VERIFICATION_FAILED_MESSAGE"] delegate:self cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"SMS_RESEND"], nil];
    alert.tag = ALERT_RESEND;
    [alert show];
}

-(void)startTimer
{
    self.secondsLeft = 10;//60 * 2;
    [self timerTick:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

-(void)errorOnValidation:(NSError*)error
{
    [self fadeInEnterCodeView];
    [self displayError:error];
}

-(void)didPickCountry:(KncCountry*)country
{
    self.countryNumberField.text = [NSString stringWithFormat:@"+%@",country.callingCode];
    [self.countryButton setTitle:country.displayName forState:UIControlStateNormal];
    [self.countryButton setTitle:country.displayName forState:UIControlStateHighlighted];
    
    self.defaultCountry = [[KncCountry alloc]initWithCountry:country];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.phoneNumberField becomeFirstResponder];
    });
    
    
}

-(void)errorOnRegistration:(NSError*)error
{
    [self fadeInWelcomeView];
    [self fadeOutEnterCodeView];
    [self displayError:error];
}

-(void)displayError:(NSError*)error
{
    NSString *message = [String key:@"UNKNOWN_ERROR"];
    if(error && [error userInfo]){
        
        if([[error userInfo]objectForKey:@"error"] && [[[error userInfo]objectForKey:@"error"]objectForKey:@"message"]){
            message = [[[error userInfo]objectForKey:@"error"]objectForKey:@"message"];
        }
        
    }
    [[[UIAlertView alloc]initWithTitle:[String key:@"ALERT_ERROR_TITLE"] message:message delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
}

-(void)fadeOut:(UIView*)view
{
    [self fade:view alpha:0];
}

-(void)fadeIn:(UIView*)view
{
    [self fade:view alpha:1];
}

-(void)fade:(UIView*)view alpha:(CGFloat)alpha
{
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = alpha;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
