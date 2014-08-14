

#import <UIKit/UIKit.h>
@interface KnCContactTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *contactImage;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *address;

-(void)setNameString:(NSString*)name;

@end
