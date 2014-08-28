
#import "KnCOneNameViewController.h"
#import "String.h"
#import "UIImageView+WebCache.h"
#import "KnCImageView+UIImageView.h"

@interface KnCOneNameViewController ()

@end

@implementation KnCOneNameViewController

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

    [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [self.addressLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)buttonPressed:(id)sender
{
    if(self.didSelectCallback){
        self.didSelectCallback();
    }
}

-(void)setOneNameHint
{
    [self.imageView setHidden:YES];
    [self.imageActivityIndicator setHidden:YES];
    [self.imageActivityIndicator stopAnimating];
    [self.nameLabel setHidden:YES];
    [self.addressLabel setHidden:YES];
    
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
    
    [self.statusLabel setHidden:NO];
    [self.statusLabel setText:[String key:@"ONENAME_SEARCH_FOR_USERNAME"]];
}

-(void)setSearchingFor:(NSString*)username
{
    [self.imageView setHidden:YES];
    [self.imageActivityIndicator setHidden:YES];
    [self.imageActivityIndicator stopAnimating];
    [self.nameLabel setHidden:YES];
    [self.addressLabel setHidden:YES];
    
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    [self.statusLabel setHidden:NO];
    [self.statusLabel setText:[NSString stringWithFormat:[String key:@"ONENAME_SEARCHING_FOR_USERNAME"],username]];
}
-(void)setResult:(NSString*)name address:(NSString*)address imageUrl:(NSString*)imageUrl
{
    [self.imageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.addressLabel setHidden:NO];
    
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
    
    [self.statusLabel setHidden:YES];
    
    [self.nameLabel setText:name];
    [self.addressLabel setText:address];
    
    [self.imageView setImage:[UIImage imageNamed:@"contact"]];
    
    [self.imageActivityIndicator setHidden:YES];
    [self.imageActivityIndicator stopAnimating];
    
    if(imageUrl){
        
        [self.imageActivityIndicator setHidden:NO];
        [self.imageActivityIndicator startAnimating];
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"contact"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            [self.imageView applyCircleMask];
            [self.imageActivityIndicator setHidden:YES];
            [self.imageActivityIndicator stopAnimating];
        }];
    }
    
    
}
-(void)setNoUserFound:(NSString*)username
{
    [self.imageView setHidden:YES];
    [self.imageActivityIndicator setHidden:YES];
    [self.imageActivityIndicator stopAnimating];
    [self.nameLabel setHidden:YES];
    [self.addressLabel setHidden:YES];
    
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];

    [self.statusLabel setHidden:NO];
    [self.statusLabel setText:[NSString stringWithFormat:[String key:@"ONENAME_USER_NOT_FOUND"],username]];
    
}

@end
