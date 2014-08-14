
#import "KnCBackupPhraseViewController.h"

#import "String.h"

#import "BRWalletManager.h"

@interface KnCBackupPhraseViewController ()

@end

@implementation KnCBackupPhraseViewController

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
    
    self.title = [String key:@"BACKUP_PHRASE"];
    
    NSString *phrase = [[BRWalletManager sharedInstance]seedPhrase];
    
    self.label.text = phrase;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
