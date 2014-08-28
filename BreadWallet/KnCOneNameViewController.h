
#import <UIKit/UIKit.h>

@interface KnCOneNameViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *imageActivityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, copy) void (^didSelectCallback)(void);

-(IBAction)buttonPressed:(id)sender;

-(void)setSearchingFor:(NSString*)username;
-(void)setResult:(NSString*)name address:(NSString*)address imageUrl:(NSString*)imageUrl;
-(void)setNoUserFound:(NSString*)username;
-(void)setOneNameHint;
@end
