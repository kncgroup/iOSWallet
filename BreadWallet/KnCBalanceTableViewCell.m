

#import "KnCBalanceTableViewCell.h"
#import "CurrencyUtil.h"
#import "KnCColor+UIColor.h"
@implementation KnCBalanceTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency
{
    [self.label setBalance:balance useLocalCurrency:useLocalCurrency];
}

+(CGFloat)height
{
    return 100.0f;
}

@end
