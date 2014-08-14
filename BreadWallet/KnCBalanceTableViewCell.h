
#import <UIKit/UIKit.h>
#import "KnCBalanceLabel.h"
@interface KnCBalanceTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet KnCBalanceLabel *label;

+(CGFloat)height;

-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency;

@end
