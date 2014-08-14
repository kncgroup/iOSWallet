
#import "KnCMainViewController.h"
#import "KncContactTableViewController.h"
#import "KnCTxLabelsTableViewController.h"

@interface KnCHomeTableViewController : UITableViewController <UIActionSheetDelegate, KncContactTableViewControllerDelegate, TxLabelsDelegate>

@property (nonatomic, weak) KnCMainViewController *parent;
-(id)initWithParent:(KnCMainViewController*)parent;

@end
