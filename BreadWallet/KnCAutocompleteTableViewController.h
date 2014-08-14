
#import <UIKit/UIKit.h>

@protocol KnCAutocompleteDelegate <NSObject>

-(void)didSelectItem:(id)item;

@end

@interface KnCAutocompleteTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) id<KnCAutocompleteDelegate> delegate;

-(void)supplyItems:(NSArray*)items;

@end
