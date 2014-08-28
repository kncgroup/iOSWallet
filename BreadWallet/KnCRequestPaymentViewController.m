
#import "KnCRequestPaymentViewController.h"
#import "BRWalletManager.h"
#import "BRWallet.h"
#import "ImageUtils.h"
#import "String.h"

@interface KnCRequestPaymentViewController ()

@property (nonatomic, strong) UITextField *currentTextfieldFocus;

@end

@implementation KnCRequestPaymentViewController

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

    [self.btcField addTarget:self
                      action:@selector(btcFieldChanged:)
            forControlEvents:UIControlEventEditingChanged];
    
    [self.fiatField addTarget:self
                       action:@selector(fiatFieldChanged:)
             forControlEvents:UIControlEventEditingChanged];
    
    [self.nameField addTarget:self action:@selector(updateQrView) forControlEvents:UIControlEventEditingChanged];
    
    [self updateQrView];
    
    self.title = [String key:@"REQUEST_PAYMENT_TITLE"];
    
}

-(void)btcFieldChanged:(id)sender
{
    
   [self updateQrView];
}

-(void)fiatFieldChanged:(id)sender
{
    
    [self updateQrView];
}

-(void)updateQrView
{
    NSString *receiveAddress = [[[BRWalletManager sharedInstance]wallet]receiveAddress];
    
    NSString *amount = @"0.1";
    
    NSMutableString *uriString = [NSMutableString stringWithFormat:@"bitcoin:%@?amount=%@",receiveAddress,amount];
    
    if(self.nameField.text.length > 0){
        [uriString appendFormat:@"&label=%@",self.nameField.text];
    }
    
    self.qrImageView.image = [ImageUtils qrImage:uriString];
    
    NSLog(@"%@",uriString);
}




-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(!textField.inputAccessoryView){
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        
        UIBarButtonItem *prev = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"previous"] style:UIBarButtonItemStylePlain target:self action:@selector(previousField:)];
        [prev setEnabled:textField != self.btcField];
        UIBarButtonItem *prevNextSpacing = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [prevNextSpacing setWidth:15.0f];
        UIBarButtonItem *next = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"next"] style:UIBarButtonItemStylePlain target:self action:@selector(nextField:)];
        [next setEnabled:textField != self.nameField];
        
        UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelKeyboard:)];
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [toolbar setItems:@[prev, prevNextSpacing, next, flex, done]];
        textField.inputAccessoryView = toolbar;
    }
    
    self.currentTextfieldFocus = textField;
}

-(void)cancelKeyboard:(id)sender
{
    [self.currentTextfieldFocus resignFirstResponder];
}

-(void)previousField:(id)sender
{
    if(self.currentTextfieldFocus == self.nameField){
        [self.fiatField becomeFirstResponder];
    }else if(self.currentTextfieldFocus == self.fiatField){
        [self.btcField becomeFirstResponder];
    }else{
        [self.currentTextfieldFocus resignFirstResponder];
    }
}

-(void)nextField:(id)sender
{
    if(self.currentTextfieldFocus == self.btcField){
        [self.fiatField becomeFirstResponder];
    }else if(self.currentTextfieldFocus == self.fiatField){
        [self.nameField becomeFirstResponder];
    }else{
        [self.currentTextfieldFocus resignFirstResponder];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
