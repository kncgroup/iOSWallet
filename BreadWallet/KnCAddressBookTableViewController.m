
#import "KnCAddressBookTableViewController.h"
#import "NSManagedObject+Sugar.h"
#import "AddressBookProvider.h"
#import "KnCContactTableViewCell.h"
#import "String.h"
#import "ImageUtils.h"
#import "KnCImageView+UIImageView.h"
#import "BRWalletManager.h"
#import "BRWallet.h"

@interface KnCAddressBookTableViewController ()

@property NSMutableArray *allContacts;
@property NSArray *filteredContacts;

@property (nonatomic, weak) AddressBookContact *selected;

@property (nonatomic, strong) NSMutableDictionary *imageCache;

@end

@implementation KnCAddressBookTableViewController

static NSString *cellIdentifier = @"ContactCell";

-(id)initWithMode:(KnCAddressBookMode)mode
{
    self = [super init];
    if(self){
        self.mode = mode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [String key:@"ADDRESS_BOOK"];
    
    self.imageCache = [NSMutableDictionary dictionary];
    
    if(self.mode == KnCAddressBookModeSelect){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        [self updateRightBarButton];
    }else if(self.mode == KnCAddressBookModeEdit){
        
        if(self.navigationController.viewControllers.count < 2){
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel:)];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCContactTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    [self loadContacts];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
}

-(void)updateRightBarButton
{
    if(self.mode == KnCAddressBookModeSelect){
        if(self.selected){
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
        }else{
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        }
    }
}

-(void)add:(id)sender
{
    KncContactTableViewController *vc = [[KncContactTableViewController alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)loadContacts
{
    self.allContacts = [NSMutableArray array];
    
    BRWallet *wallet = [[BRWalletManager sharedInstance]wallet];
    
    NSArray *coreDataContacts = [KnCContact allObjects];
    
    for(KnCContact *contact in coreDataContacts){
        
        AddressBookContact *abc = [contact createAddressBookContactObject];
        if(abc){
            
            if(self.mode == KnCAddressBookModeEdit || (self.mode == KnCAddressBookModeSelect && ![wallet containsAddress:abc.address])){
                [self.allContacts addObject:abc];
            }
        }
    }
    
    self.filteredContacts = [self.allContacts sortedArrayUsingComparator:^NSComparisonResult(AddressBookContact* obj1, AddressBookContact* obj2) {
        return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([self.searchBar isFirstResponder]){
        [self.searchBar resignFirstResponder];
    }
}

-(void)search:(id)sender
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(name like[c] '*%@*')",searchText]];
    self.filteredContacts = [[self.allContacts filteredArrayUsingPredicate:predicate] sortedArrayUsingComparator:^NSComparisonResult(AddressBookContact* obj1, AddressBookContact* obj2) {
        return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
    }];
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}


-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismiss:(id)sender
{
    if(self.selected){
        
        
        
        [self.delegate didPickAddressBookContact:self.selected];
        [self dismissViewControllerAnimated:YES completion:nil];        
    }else{
        [self cancel:sender];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    AddressBookContact *abc = [self.filteredContacts objectAtIndex:indexPath.row];
    
    UIImage *image = [self imageForAddresBookContact:abc];
    if(image){
        cell.contactImage.image = image;
        [cell.contactImage applyCircleMask];
    }else{
        [cell.contactImage setImage:[UIImage imageNamed:@"contact-inverted-big"]];
        [cell.contactImage clearMask];
    }
    
    [cell setNameString:abc.name];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.mode == KnCAddressBookModeSelect){
        if(self.selected && self.selected == [self.filteredContacts objectAtIndex:indexPath.row]){
            [self dismiss:nil];
        }else{
            self.selected = [self.filteredContacts objectAtIndex:indexPath.row];
        }
        
        [self updateRightBarButton];
        
    }else if(self.mode == KnCAddressBookModeEdit){
        AddressBookContact *abc = [self.filteredContacts objectAtIndex:indexPath.row];
        KncContactTableViewController *detail = [[KncContactTableViewController alloc]initWithAddress:abc.address];
        detail.delegate = self;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

-(void)contactTableViewControllerDelegate:(id)sender updatedContact:(KnCContact*)contact
{
    [self.imageCache removeObjectForKey:[contact createAddressBookContactObject].address];
    [self loadContacts];
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
}

-(UIImage*)imageForAddresBookContact:(AddressBookContact*)abc
{
    if(!abc) return nil;
    
    UIImage *image = [self.imageCache objectForKey:abc.address];
    if(!image){
        
        UIImage *contactImage = [AddressBookProvider imageForAddress:abc.address];
        if(contactImage){
            image = [ImageUtils imageWithImage:contactImage fit:CGSizeMake(30, 30)];
            [self.imageCache setObject:image forKey:abc.address];
            
        }else{
            [self.imageCache setObject:@"" forKey:abc.address];
        }
        
    }
    
    if(image && [image isKindOfClass:[UIImage class]]){
        return image;
    }
    
    
    return nil;
}

@end
