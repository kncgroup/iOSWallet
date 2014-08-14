
#import <UIKit/UIKit.h>
#import "BRTransaction.h"

@protocol TxLabelsDelegate <NSObject>

-(void)labelWasUpdated;

@end

@interface KnCTxLabelsTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<TxLabelsDelegate> labelsDelegate;

-(id)initWithBRTransaction:(BRTransaction*)tx;


@end
