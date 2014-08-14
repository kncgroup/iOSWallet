
#import <UIKit/UIKit.h>
#import "AddressBookProvider.h"

@protocol KncContactTableViewControllerDelegate <NSObject>

-(void)contactTableViewControllerDelegate:(id)sender updatedContact:(KnCContact*)contact;

@end

@interface KncContactTableViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

-(id)initWithAddress:(NSString*)address;

@property (nonatomic,weak) id<KncContactTableViewControllerDelegate> delegate;

@end
