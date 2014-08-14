
#import "KncRestoreViewController.h"

#import "BRWalletManager.h"

#import "String.h"

#import "SVProgressHUD.h"

@interface KncRestoreViewController ()

@end

@implementation KncRestoreViewController

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

    self.title = [String key:@"START_RESTORE_WALLET"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth = 1;
    
    self.infoLabel.text = [String key:@"START_RESTORE_TOP_INFO"];
    
    [self.generateButton setTitle:[String key:@"GENERATE_RANDOM_SEED"] forState:UIControlStateNormal];
}

-(IBAction)buttonPressed:(id)sender
{
    if(sender == self.generateButton){
        [self generateRandomSeed];
    }
}

-(void)generateRandomSeed
{
    self.textView.text = [[BRWalletManager sharedInstance]randomSeed];
}

-(void)done:(id)sender
{
    NSString *seedPhrase = self.textView.text;
    
    if(self.textView.text.length == 0){
        [SVProgressHUD showErrorWithStatus:[String key:@"START_RESTORE_NO_PHRASE"]];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [[BRWalletManager sharedInstance]setSeedPhrase:seedPhrase];
    
    
    if([[BRWalletManager sharedInstance]wallet]){
        [SVProgressHUD showSuccessWithStatus:[String key:@"START_RESTORE_SUCCESS"]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
