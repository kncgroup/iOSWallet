

#import "KnCHintsViewController.h"
#import "String.h"
@interface KnCHintsViewController ()

@end

@implementation KnCHintsViewController

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
    
    self.title = [String key:@"HINTS_TITLE"];
    
    [self.label setText:[String key:@"HINTS_LONG_TEXT"]];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGSize size = self.label.frame.size;
    size.height += self.label.frame.origin.y;
    [self.scrollView setContentSize:size];
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
