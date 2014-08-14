
#import <UIKit/UIKit.h>

@protocol KnCExchangeRatesDelegate <NSObject>

-(void)localCurrencyDidChange;

@end

@interface KnCExchangeRatesTableViewController : UITableViewController

@property (nonatomic, weak) id<KnCExchangeRatesDelegate> delegate;

@end
