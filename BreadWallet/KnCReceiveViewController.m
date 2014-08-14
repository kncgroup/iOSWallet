
#import "KnCReceiveViewController.h"

#import "BRWalletManager.h"
#import "BRWallet.h"

#import "CurrencyUtil.h"
#import "String.h"
#import "ImageUtils.h"
#import "SVProgressHUD.h"
#import "KnCAddressProvider.h"
#import "KnCQRImageProvider.h"
#import "KnCAirDropProvider.h"

@interface KnCReceiveViewController ()

@end

@implementation KnCReceiveViewController

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

    self.title = [String key:@"RECEIVE"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(qrTapped:)];
    tap.numberOfTapsRequired = 1;
    [self.qrView addGestureRecognizer:tap];
    
    [self updateQrView];
    [self updateBalance];
}

-(NSString*)tabBarIcon
{
    return @"receive";
}

-(IBAction)buttonPressed:(id)sender
{
    if(sender == self.addressButton){
        [self qrTapped:sender];
    }
}

-(void)updateQrView
{
    NSString *receiveAddress = [[[BRWalletManager sharedInstance]wallet]receiveAddress];
    self.qrView.image = [ImageUtils qrImage:receiveAddress];
    [self.addressButton setTitle:receiveAddress forState:UIControlStateNormal];
}

-(void)updateBalance
{
    [self updateQrView];
}

-(void)qrTapped:(id)sender
{
    NSString *receiveAddress = [[[BRWalletManager sharedInstance]wallet]receiveAddress];

    KnCAddressProvider *k1 = [[KnCAddressProvider alloc]initWithAddress:receiveAddress];
    KnCQRImageProvider *k2 = [[KnCQRImageProvider alloc]initWithUIImage:self.qrView.image];
    KnCAirDropProvider *k3 = [[KnCAirDropProvider alloc]initWithAddress:receiveAddress];
    
    UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:@[k1, k2, k3] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
    [self.parent presentViewController:avc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
