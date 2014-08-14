
#import "KnCLicenseFileViewController.h"

@interface KnCLicenseFileViewController ()

@property (nonatomic, strong) KnCLicense *license;

@end

@implementation KnCLicenseFileViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithLicense:(KnCLicense*)license
{
    self = [super init];
    if(self){
        self.license = license;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:self.license.license
                                                     ofType:@"txt"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];

    self.title = self.license.title;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"compass"] style:UIBarButtonItemStylePlain target:self action:@selector(openWeb:)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)openWeb:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.license.url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
