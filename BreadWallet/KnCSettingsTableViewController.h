
#import <UIKit/UIKit.h>

@protocol KncSettingsDelegate <NSObject>

-(void)settingsInvalidated;
-(void)emptyWallet;

@end

@interface KnCSettingsTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, weak) id<KncSettingsDelegate> delegate;

@end
