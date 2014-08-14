
#import "KnCDenominationTableViewController.h"
#import "KnCDenominationTableViewCell.h"
#import "KnCDenomination.h"
#import "String.h"
#import "CurrencyUtil.h"

@interface KnCDenominationTableViewController ()

@property (nonatomic, strong) NSArray *denominations;
@property (nonatomic) KnCDenomination *currentDenomination;

@end

@implementation KnCDenominationTableViewController

static NSString *cellIdentifier = @"DenominationCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCDenominationTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.denominations = [KnCDenomination supportedDenominations];
    
    self.title = [String key:@"DENOMINATION"];
    
    if(self.navigationController.viewControllers.count == 1){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    }
    
    [self updateDenomination];
}

-(void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateDenomination
{
    self.currentDenomination = [CurrencyUtil denomination];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.denominations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCDenominationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    KnCDenomination *denomination = [self.denominations objectAtIndex:indexPath.row];
    
    cell.leftLabel.text = denomination.name;
    
    cell.rightLabel.text = [NSString stringWithFormat:@"%i %@",denomination.precision,[String key:@"DIGITS"]];
    
    if([denomination isEqualToDenomination:self.currentDenomination]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCDenomination *denomination = [self.denominations objectAtIndex:indexPath.row];
    [CurrencyUtil setDenomination:denomination];
    [self.delegate denominationChanged];
    [self updateDenomination];
}

@end
