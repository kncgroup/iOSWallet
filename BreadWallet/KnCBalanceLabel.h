
#import <UIKit/UIKit.h>

@interface KnCBalanceLabel : UILabel

-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency;
-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency currencyColor:(UIColor*)currencyColor;
-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency displayFee:(BOOL)displayFee fee:(uint64_t)fee currencyColor:(UIColor*)currencyColor mainFont:(UIFont*)font extraFont:(UIFont*)extraFont;
@end
