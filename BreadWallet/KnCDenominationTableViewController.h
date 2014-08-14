
#import <UIKit/UIKit.h>

@protocol KnCDenominationDelegate <NSObject>

-(void)denominationChanged;

@end

@interface KnCDenominationTableViewController : UITableViewController

@property (nonatomic, weak) id<KnCDenominationDelegate> delegate;

@end
