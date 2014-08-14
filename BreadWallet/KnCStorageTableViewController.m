
#import "KnCStorageTableViewController.h"
#import "BRAppDelegate.h"
#import "KnCBackupUtil.h"
#import "String.h"
#import "KnCFileTableViewCell.h"
#import "SVProgressHUD.h"
#import "KnCRestoreBackupTableViewController.h"
#import "KnCAlertView.h"
#import "BRWalletManager.h"

@interface KnCStorageTableViewController ()

@property (nonatomic, strong) NSMutableArray *seeds;
@property (nonatomic, strong) KnCBackupUtil *backupUtil;

@end

@implementation KnCStorageTableViewController

static NSString *cellIdentifier = @"FileCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCFileTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.seeds = [NSMutableArray array];
    self.title = [String key:@"BACKUP_ICLOUD_FILES"];
    
    self.backupUtil = [[KnCBackupUtil alloc]init];
    
    [self loadFiles];
}

-(void)loadFiles
{
    [SVProgressHUD show];
    [self.backupUtil allBackups:^(BOOL success, NSArray *seeds, NSString *message) {
        
        [SVProgressHUD dismiss];
        
        [self.seeds removeAllObjects];
        
        if(success){
            [self.seeds addObjectsFromArray:seeds];
        }else{
            [self delayedErrorHud:message];
        }
        
        [self.tableView reloadData];
        
    }];
}

-(void)delayedErrorHud:(NSString*)message
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:message];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.seeds.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.name.text = [self.seeds objectAtIndex:indexPath.section];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)restorePhrase:(NSString*)phrase
{
    NSString *current = [[BRWalletManager sharedInstance]seedPhrase];
    
    if([phrase isEqualToString:current]){
        [SVProgressHUD showErrorWithStatus:[String key:@"BACKUP_SAME_SEED"]];
    }else{
        [SVProgressHUD showSuccessWithStatus:[String key:@"BACKUP_RESTORE_PROGRESS_STARTED"]];
        [[BRWalletManager sharedInstance]setSeedPhrase:phrase];
        [self dismiss];
    }
}

-(void)dismiss
{
    if(self.navigationController.viewControllers.count > 1){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didSelectPhrase:(NSString*)phrase
{
    KnCAlertView *alert = [[KnCAlertView alloc]initWithTitle:[String key:@"BACKUP_RESTORE_SELECTED_PHRASE_TITLE"] message:phrase delegate:self cancelButtonTitle:[String key:@"NO"] otherButtonTitles:[String key:@"YES"], nil];
    alert.block = ^{
        [self restorePhrase:phrase];
    };
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView isKindOfClass:[KnCAlertView class]] && buttonIndex == 1){
        ((KnCAlertView*)alertView).block();
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelectPhrase:[self.seeds objectAtIndex:indexPath.section]];
    
}


@end
