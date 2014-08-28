
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
@property (nonatomic, strong) NSString *selectedPhrase;

@end

@implementation KnCStorageTableViewController

#define TAG_SEED_SHEET 1

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

-(void)deletePhrase:(NSString*)phrase
{
    [SVProgressHUD show];
    
    [self.backupUtil deleteBackupPhrase:phrase callback:^(BOOL success, NSString *message) {
       
        [SVProgressHUD dismiss];
        
        if(success){
            
            [SVProgressHUD showSuccessWithStatus:message];
            
            NSInteger index = [self.seeds indexOfObject:phrase];
            if(index >= 0 && index < self.seeds.count){
                //[self.seeds removeObjectAtIndex:index];
            }
            
        }else{
            [SVProgressHUD showErrorWithStatus:message];
        }
        
        [self.tableView reloadData];
        
    }];
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
    self.selectedPhrase = [NSString stringWithString:phrase];
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:phrase delegate:self cancelButtonTitle:[String key:@"CANCEL"] destructiveButtonTitle:[String key:@"DELETE"] otherButtonTitles:[String key:@"BACKUP_RESTORE_SHEET_BUTTON_TITLE"], nil];
    sheet.tag = TAG_SEED_SHEET;
    [sheet showInView:self.view];
}

-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    [self.tableView reloadData];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == TAG_SEED_SHEET){
        
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[String key:[String key:@"BACKUP_RESTORE_SHEET_BUTTON_TITLE"]]]){
            KnCAlertView *alert = [[KnCAlertView alloc]initWithTitle:[String key:@"BACKUP_RESTORE_SELECTED_PHRASE_TITLE"] message:self.selectedPhrase delegate:self cancelButtonTitle:[String key:@"NO"] otherButtonTitles:[String key:@"YES"], nil];
            alert.block = ^{
                [self restorePhrase:self.selectedPhrase];
            };
            [alert show];
        }else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[String key:[String key:@"DELETE"]]]){
            KnCAlertView *alert = [[KnCAlertView alloc]initWithTitle:[String key:@"BACKUP_DELETE_PHRASE"] message:self.selectedPhrase delegate:self cancelButtonTitle:[String key:@"NO"] otherButtonTitles:[String key:@"YES"], nil];
            alert.block = ^{
                [self deletePhrase:self.selectedPhrase];
            };
            [alert show];
        }
        
    }
    
    [self.tableView reloadData];
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
