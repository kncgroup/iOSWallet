
#import <UIKit/UIKit.h>
#import "KnCDocument.h"

@interface KnCRestoreBackupTableViewController : UITableViewController <UITextFieldDelegate>

-(id)initWithDocument:(KnCDocument*)document;
-(id)initWithUrl:(NSURL*)url;

@end
