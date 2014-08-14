
#import "KnCCountryPickerTableViewController.h"
#import "RMPhoneFormat.h"
#import "String.h"
#import "KnCCountryTableViewCell.h"

@interface KnCCountryPickerTableViewController ()

@property (nonatomic, strong) RMPhoneFormat *phoneFormat;
@property (nonatomic, strong) NSArray *allCountries;
@property (nonatomic, strong) NSArray *filteredCountries;
@property (nonatomic, strong) KncCountry *defaultCountry;

@end

@implementation KnCCountryPickerTableViewController

static NSString * cellIdentifier = @"CountryCell";

-(id)initWithCountry:(KncCountry*)country
{
    self = [super init];
    if(self){
        self.defaultCountry = [[KncCountry alloc]initWithCountry:country];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCCountryTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.title = [String key:@"PICK_COUNTRY"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    
    self.phoneFormat = [RMPhoneFormat instance];
    
    self.allCountries = [self allCountries];
    self.filteredCountries = [NSArray arrayWithArray:self.allCountries];
    
    [self scrollToDefaultCountry];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(displayName like[c] '*%@*')",searchText]];
    self.filteredCountries = [self.allCountries filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(NSArray*)allCountries
{
    NSMutableArray * countriesArray = [[NSMutableArray alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] ;
    
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    for (NSString *countryCode in countryArray)
    {
        KncCountry *country = [[KncCountry alloc]init];
        country.callingCode = [self.phoneFormat callingCodeForCountryCode:countryCode];
        if(country.callingCode){
            country.displayName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
            country.isoCode = countryCode;
            [countriesArray addObject:country];
        }
        
    }
    
    [countriesArray sortUsingComparator:^NSComparisonResult(KncCountry* obj1, KncCountry* obj2) {
        return [obj1.displayName compare:obj2.displayName];
    }];
    return countriesArray;
}

-(void)scrollToDefaultCountry
{
    
    if(self.defaultCountry){
        int index = [self indexOfCountry:self.defaultCountry];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

-(NSInteger)indexOfCountry:(KncCountry*)country
{
    for(int i=0; i < self.filteredCountries.count; i++){
        KncCountry *other = [self.filteredCountries objectAtIndex:i];
        if([other.isoCode isEqualToString:country.isoCode]){
            return i;
        }
    }
    return 0;
}

-(void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return self.filteredCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCCountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    KncCountry *country = [self.filteredCountries objectAtIndex:indexPath.row];
    
    cell.name.text = country.displayName;
    cell.code.text = [NSString stringWithFormat:@"+%@",country.callingCode];
    
    if([self.defaultCountry.isoCode isEqualToString:country.isoCode]){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KncCountry *country = [self.filteredCountries objectAtIndex:indexPath.row];
    [self.delegate didPickCountry:country];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
