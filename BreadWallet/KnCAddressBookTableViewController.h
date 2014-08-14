

#import <UIKit/UIKit.h>

#import "AddressBookContact.h"
#import "KncContactTableViewController.h"

typedef NS_ENUM(NSInteger, KnCAddressBookMode) {
    KnCAddressBookModeSelect,
    KnCAddressBookModeEdit
};


@protocol KnCAddressBookDelegate <NSObject>

-(void)didPickAddressBookContact:(AddressBookContact*)contact;

@end


@interface KnCAddressBookTableViewController : UITableViewController <UISearchBarDelegate, UIScrollViewDelegate, KncContactTableViewControllerDelegate>

@property id<KnCAddressBookDelegate> delegate;

@property (nonatomic, strong) UISearchBar* searchBar;

@property (nonatomic) KnCAddressBookMode mode;

-(id)initWithMode:(KnCAddressBookMode)mode;

@end
