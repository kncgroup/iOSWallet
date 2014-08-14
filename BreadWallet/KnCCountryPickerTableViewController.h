

#import <UIKit/UIKit.h>
#import "KncCountry.h"
@protocol KnCCountryPickerDelegate <NSObject>

-(void)didPickCountry:(KncCountry*)country;

@end

@interface KnCCountryPickerTableViewController : UITableViewController <UISearchBarDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<KnCCountryPickerDelegate> delegate;

@property (nonatomic, strong) UISearchBar *searchBar;


-(id)initWithCountry:(KncCountry*)country;

@end
