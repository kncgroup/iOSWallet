
#import "KnCBalanceLabel.h"
#import "CurrencyUtil.h"
#import "KnCColor+UIColor.h"
@implementation KnCBalanceLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency
{
    [self setBalance:balance useLocalCurrency:useLocalCurrency currencyColor:[UIColor teal]];
}

-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency currencyColor:(UIColor*)currencyColor
{
    [self setBalance:balance useLocalCurrency:useLocalCurrency displayFee:NO fee:0 currencyColor:currencyColor mainFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35.0f] extraFont:nil];
}

-(void)setBalance:(uint64_t)balance useLocalCurrency:(BOOL)useLocalCurrency displayFee:(BOOL)displayFee fee:(uint64_t)fee currencyColor:(UIColor*)currencyColor mainFont:(UIFont*)font extraFont:(UIFont*)extraFont
{
    
    [self setFont:font];
    
    KnCDenomination *denomination = [CurrencyUtil denomination];
    NSString *string = @"";
    NSString *unit = @"";
    NSString *extra = @"";
    
    if(useLocalCurrency){
        string = [CurrencyUtil localCurrencyStringForAmount:balance withSymbol:NO];
        unit = [CurrencyUtil localCurrencyCode];
    }else{
        string = [CurrencyUtil stringForBtcAmount:balance withSymbol:NO];
        unit = denomination.name;
    }
    
    if(displayFee){
        
        NSString *feeString = nil;
        if(useLocalCurrency){
            feeString =  [CurrencyUtil localCurrencyStringForAmount:fee withSymbol:NO];
        }else{
            feeString = [CurrencyUtil stringForBtcAmount:fee withSymbol:NO];
        }
        
        extra = [NSString stringWithFormat:@"incl. fee %@", feeString];
        
    }
    
    NSString *fullString = [NSString stringWithFormat:@"%@ %@ %@",string,unit,extra];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:fullString];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:currencyColor range:NSMakeRange(string.length, unit.length+1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(string.length + unit.length + 1, extra.length+1)];
    if(extraFont){
        [attributedString addAttribute:NSFontAttributeName value:extraFont range:NSMakeRange(string.length + unit.length + 1, extra.length+1)];
    }

    self.attributedText = attributedString;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
