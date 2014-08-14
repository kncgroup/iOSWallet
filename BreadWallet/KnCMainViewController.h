

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"
#import "KnCSettingsTableViewController.h"
#import "KnCTxLabelsTableViewController.h"
@interface KnCMainViewController : UIViewController <UIScrollViewDelegate, UITabBarDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, KncSettingsDelegate, TxLabelsDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITabBar *tabBar;

@property (nonatomic, strong) id syncStartedObserver, syncFinishedObserver, syncFailedObserver, balanceObserver, reachabilityObserver;

@property (nonatomic, strong) ZBarReaderViewController *zbarController;

-(void)startSendRequestForAddress:(NSString*)address;
-(void)scanQR;
-(void)handleBitcoinUrl:(NSURL*)url;

@end
