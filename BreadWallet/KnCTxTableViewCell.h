
#import <UIKit/UIKit.h>
#import "SSPieProgressView.h"
#import "KnCBalanceLabel.h"

@interface KnCTxTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet KnCBalanceLabel *head;
@property (nonatomic, weak) IBOutlet UILabel *middle;
@property (nonatomic, weak) IBOutlet UILabel *sub;
@property (nonatomic, weak) IBOutlet UIImageView *contact;
@property (nonatomic, weak) IBOutlet UILabel *subSub;
@property (nonatomic, weak) IBOutlet UIView *separator;
@property (nonatomic, weak) IBOutlet SSPieProgressView *confirmsView;

+(CGFloat)height;

-(void)setAmount:(uint64_t)amount withFee:(int64_t)fee usingLocalCurrency:(BOOL)usingLocalCurrency;
-(void)setToName:(NSString*)name fromToLabel:(NSString*)fromTo;
-(void)setDateString:(NSString*)dateString;
-(void)setTxLabel:(NSString*)label andMessage:(NSString*)message;
-(void)setConfirmationsProgress:(CGFloat)progress;
+(CGFloat)calculateCellHeightWithLabel:(NSString*)label andMessage:(NSString*)message;

@end
