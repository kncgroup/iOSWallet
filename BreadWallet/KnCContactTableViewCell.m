
#import "KnCContactTableViewCell.h"

@implementation KnCContactTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNameString:(NSString*)name
{
    
    NSArray *names = [name componentsSeparatedByString:@" "];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
    
    int location = name.length - ((NSString*)names.lastObject).length;

    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:14.0f] range:NSMakeRange(location, name.length-location)];

    self.name.attributedText = attributedString;
    
}

@end
