
#import <UIKit/UIKit.h>
#import "KnCLicense.h"
@interface KnCLicenseFileViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;

-(id)initWithLicense:(KnCLicense*)license;

@end
