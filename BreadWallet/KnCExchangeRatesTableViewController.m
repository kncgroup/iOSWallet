
#import "KnCExchangeRatesTableViewController.h"
#import "BRWalletManager.h"
#import "String.h"

@interface KnCExchangeRatesTableViewController ()

@property (nonatomic, strong) NSMutableArray *rates;

@property (nonatomic, strong) NSString *selectedLocalCurrency;

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation KnCExchangeRatesTableViewController

static NSString *cellIdentifier = @"RatesCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCExchangeRateTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    if(self.navigationController.viewControllers.count < 2){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    }
    
    self.numberFormatter = [[NSNumberFormatter alloc]init];
    [self.numberFormatter setMaximumFractionDigits:2];
    
    self.rates = [NSMutableArray array];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    NSDictionary *data = [manager currencyExchangeRates];
    
    NSArray *sortedKeys = [[data allKeys]sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj1 compare:obj2];
    }];
    
    for(NSString *key in sortedKeys){
        NSDictionary *values = [data objectForKey:key];
        NSMutableDictionary *rate = [NSMutableDictionary dictionaryWithDictionary:values];
        [rate setObject:key forKey:@"code"];
        [self.rates addObject:rate];
    }

    self.selectedLocalCurrency = [manager currencyCode];
    
    self.title = [String key:@"EXCHANGE_RATES"];
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
    return self.rates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *rate = [self.rates objectAtIndex:indexPath.row];
    
    NSString *code = [rate objectForKey:@"code"];
    
    cell.textLabel.text = [rate objectForKey:@"code"];
    cell.detailTextLabel.text =  [self.numberFormatter stringFromNumber:[rate objectForKey:@"last"]];
    
    if([self.selectedLocalCurrency isEqualToString:code]){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
        
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rate = [self.rates objectAtIndex:indexPath.row];
    NSString *code = [rate objectForKey:@"code"];
    self.selectedLocalCurrency = code;
    [[BRWalletManager sharedInstance]setLocalCurrency:code withData:rate];
    [self.delegate localCurrencyDidChange];
    [self.tableView reloadData];
}

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
