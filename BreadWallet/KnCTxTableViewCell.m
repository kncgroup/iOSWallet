
#import "KnCTxTableViewCell.h"
#import "CurrencyUtil.h"
#import "KnCColor+UIColor.h"
@implementation KnCTxTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

static CGFloat normalSize = 15.0f;
static CGFloat subSize = 12.0f;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setAmount:(uint64_t)amount withFee:(int64_t)fee usingLocalCurrency:(BOOL)usingLocalCurrency
{
    [self.head setBalance:amount useLocalCurrency:usingLocalCurrency displayFee:fee>0 fee:fee currencyColor:[UIColor blackColor] mainFont:[UIFont fontWithName:@"HelveticaNeue" size:normalSize] extraFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    
}
-(void)setToName:(NSString*)name fromToLabel:(NSString*)fromTo
{
    self.middle.font = [UIFont fontWithName:@"HelveticaNeue" size:normalSize];
    
    NSString *fullString = [NSString stringWithFormat:@"%@ %@",fromTo, name];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:fullString];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:normalSize] range:NSMakeRange(0, fromTo.length)];
    
    NSArray *names = [name componentsSeparatedByString:@" "];
    
    NSInteger location = fromTo.length+1;
    
    
    if(names.count>0){
        NSString *lastName = names.lastObject;
        NSString *firstNames = [name substringToIndex:name.length-lastName.length];
        NSInteger locationNext = location + firstNames.length;
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:normalSize] range:NSMakeRange(location, locationNext - location)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:normalSize] range:NSMakeRange(locationNext, lastName.length)];
    }else{
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:normalSize] range:NSMakeRange(location, name.length)];
    }
    
    self.middle.attributedText = attributedString;

}
-(void)setDateString:(NSString*)dateString
{
    self.sub.text = dateString;
    self.sub.font = [UIFont fontWithName:@"HelveticaNeue" size:subSize];
}

-(void)setTxLabel:(NSString*)label andMessage:(NSString*)message
{
    
    if(!label && !message){
        self.subSub.attributedText = nil;
    }else{
        if(!message){
            message = @"";
        }
        if(!label){
            label = @"";
        }else{
            label = [label stringByAppendingString:@"\n"];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",label,message]];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor teal] range:NSMakeRange(0, label.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(label.length, message.length)];

        
        self.subSub.attributedText = attributedString;
        self.subSub.font = [UIFont fontWithName:@"HelveticaNeue" size:subSize];
            
    }
}

-(void)setConfirmationsProgress:(CGFloat)progress
{
    UIColor *color = [UIColor colorWithRed:198.0f/255.0f green:198.0f/255.0f blue:203.0f/255.0f alpha:1.0];
    
    [self.confirmsView setPieBorderColor:color];
    [self.confirmsView setPieBorderWidth:1.0f];
    [self.confirmsView setPieFillColor:color];
    [self.confirmsView setProgress:progress];
    
    [self.confirmsView setHidden: progress >= 1.0];
    
}

+(CGFloat)calculateCellHeightWithLabel:(NSString*)label andMessage:(NSString*)message
{
    return [KnCTxTableViewCell calculateHeightForLabel:label andMessage:message] + [KnCTxTableViewCell height];
}

+(int)linesForStrings:(NSString*)string
{
    if(string && string.length>0){
        return MAX(1, string.length / 30);
    }
    return 0;
}

+(CGFloat)calculateHeightForLabel:(NSString*)label andMessage:(NSString*)message
{
    int lines = 0;
    if(label){
        lines += [self linesForStrings:label];
    }
    if(message){
        lines += [self linesForStrings:message];
    }
    
    return 12.0f * lines;
}

+(CGFloat)height
{
    return 70.0f;
}

@end
