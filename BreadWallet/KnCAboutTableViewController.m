
#import "KnCAboutTableViewController.h"
#import "String.h"
#import "KnCTableViewCell.h"

@interface KnCAboutTableViewController ()

@end

@implementation KnCAboutTableViewController

static NSString *cellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [String key:@"SETTINGS_ABOUT_TITLE"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [String key:@"ABOUT_FOOTER"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    cell.detailTextLabel.text = version;
    cell.textLabel.text = [String key:@"ABOUT_VERSION"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
