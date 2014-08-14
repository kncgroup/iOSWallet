
#import <UIKit/UIKit.h>

@interface KnCAlertView : UIAlertView

@property (nonatomic, copy) void (^block)(void);

@end
