
#import "KnCAutocompleteTableViewController.h"
#import "KnCContactTableViewCell.h"
#import "AddressBookProvider.h"
#import "ImageUtils.h"
#import "KnCImageView+UIImageView.h"

@interface KnCAutocompleteTableViewController ()

@end

@implementation KnCAutocompleteTableViewController

static NSString *cellIdentifier = @"ContactCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCContactTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
}


-(void)supplyItems:(NSArray*)items
{
    self.items = [NSArray arrayWithArray:items];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *name = @"";
    NSString *address = @"";
    
    id item = [self.items objectAtIndex:indexPath.row];
    
    if([item isKindOfClass:[KnCContact class]]){
        KnCContact *contact = (KnCContact*)item;
        name = contact.label;
        address = [contact mostRecentAddress];
    }
    
    UIImage *image = [ImageUtils imageWithImage:[AddressBookProvider imageForAddress:address] fit:CGSizeMake(30, 30)];
    if(!image){
        image = [UIImage imageNamed:@"contact-inverted-big"];
    }
    cell.contactImage.image = image;
    [cell.contactImage applyCircleMask];
    [cell setNameString:name];
    
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didSelectItem:[self.items objectAtIndex:indexPath.row]];
}


@end
