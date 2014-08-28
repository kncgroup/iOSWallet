
#import "KnCSettingsTableViewController.h"
#import "SettingsSection.h"
#import "SettingsRow.h"

#import "KnCDirectory.h"
#import "SVProgressHUD.h"
#import "String.h"

#import "KncRestoreViewController.h"
#import "KnCBackupPhraseViewController.h"
#import "KnCAddressBookTableViewController.h"
#import "KnCExchangeRatesTableViewController.h"
#import "KnCPinViewController.h"
#import "KnCPinUtil.h"
#import "KncPinViewController.h"
#import "KnCBackupTableViewController.h"
#import "KnCStorageTableViewController.h"
#import "KnCDenominationTableViewController.h"
#import "KnCAboutTableViewController.h"
#import "KnCLicenseTableViewController.h"
#import "KnCHintsViewController.h"
#import "BRPeerManager.h"
#import "BRAppDelegate.h"
#import "KnCColor+UIColor.h"
#import "KnCViewController+UIViewController.h"

#define ALERT_REMOVE_DETAILS 2
#define ALERT_RESET_BLOCK_CHAIN 3

@interface KnCSettingsTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *sections;

@end

@implementation KnCSettingsTableViewController

static NSString *cellIdentifier = @"SettingsCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCSettingsTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    self.title = [String key:@"SETTINGS"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
    
    self.sections = [NSMutableDictionary dictionary];
    
    [self resetSections];
}

-(void)resetSections
{
    
    [self.sections removeAllObjects];
    
    SettingsRow *removeDetails = [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_REMOVE_DETAILS_TITLE"] subtitle:[String key:@"SETTINGS_REMOVE_DETAILS_SUBTITLE"] block:^{ [self removeEntryDetails]; }];
    removeDetails.enabled = [KnCDirectory isRegistred];
    
    SettingsRow *removePin = [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_REMOVE_PIN_TITLE"] subtitle:[String key:@"SETTINGS_REMOVE_PIN_SUBTITLE"] block:^{ [self removePin]; }];
    removePin.enabled = [KnCPinUtil hasPin];
    
    SettingsSection *general = [[SettingsSection alloc]initWithTitle:[String key:@"SETTINGS_GENERAL"]
                                                             andRows:@[[[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_ADDRESS_BOOK_TITLE"] subtitle:[String key:@"SETTINGS_ADDRESS_BOOK_SUBTITLE"] block:^{ [self showAddressBook]; }],
                                                                       [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_ACCESS_PIN_TITLE"] subtitle:[String key:@"SETTINGS_ACCESS_PIN_SUBTITLE"] block:^{ [self showPinCode]; }],
                                                                       removePin,
                                                                       removeDetails,
                                                                       ]];
    
    SettingsSection *prefs = [[SettingsSection alloc]initWithTitle:[String key:@"SETTINGS_PREFERENCES"]
                                                           andRows:@[[[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_DENOMINATION_TITLE"] subtitle:[String key:@"SETTINGS_DENOMINATION_SUBTITLE"] block:^{ [self showDenomination]; }],
                                                                     [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_EXCHANGE_RATES_TITLE"] subtitle:[String key:@"SETTINGS_EXCHANGE_RATES_SUBTITLE"] block:^{ [self showExchangeRates]; }]
                                                                     ]];
    
    SettingsSection *wallet = [[SettingsSection alloc]initWithTitle:[String key:@"SETTINGS_WALLET"]
                                                           andRows:@[[[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_SHOW_BACKUP_PHRASE_TITLE"] subtitle:[String key:@"SETTINGS_SHOW_BACKUP_PHRASE_SUBTITLE"] block:^{ [self showBackupPhrase]; }],
                                                                     [[SettingsRow alloc]initWithTitle:[String key:@"BACKUP_PHRASE_ICLOUD_TITLE"] subtitle:[String key:@"BACKUP_PHRASE_ICLOUD_SUBTITLE"] block:^{ [self iCloudBackup]; }],
                                                                     [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_BACKUP_ICLOUD_TITLE"] subtitle:[String key:@"SETTINGS_BACKUP_ICLOUD_SUBTITLE"] block:^{ [self showBackupStorage]; }],
                                                                     [[SettingsRow alloc]initWithTitle:[String key:@"BACKUP_SEND_EMAIL_TITLE"] subtitle:[String key:@"BACKUP_SEND_EMAIL_SUBTITLE"] block:^{ [self showBackupWallet]; }],
                                                                     ]];
    SettingsSection *about = [[SettingsSection alloc]initWithTitle:[String key:@"SETTINGS_ABOUT"]
                                                           andRows:@[[[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_ABOUT_TITLE"] subtitle:[String key:@"SETTINGS_ABOUT_SUBTITLE"] block:^{ [self showAbout]; }],
                                                                     [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_LICENSE_TITLE"] subtitle:[String key:@"SETTINGS_LICENSE_SUBTITLE"] block:^{ [self showLicenses]; }],
                                                                     [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_HINTS_TITLE"] subtitle:[String key:@"SETTINGS_HINTS_SUBTITLE"] block:^{ [self showHints]; }]
                                                                     ]];
    
    SettingsSection *diagnostics = [[SettingsSection alloc]initWithTitle:[String key:@"SETTINGS_DIAGNOSTICS"]
                                                                 andRows:@[[[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_RESET_BLOCKCHAIN_TITLE"] subtitle:[String key:@"SETTINGS_RESET_BLOCKCHAIN_SUBTITLE"] block:^{ [self askResetBlockChain]; }]]];
    
    SettingsSection *advanced = [[SettingsSection alloc]initWithTitle:[String key:@"SETTINGS_ADVANCED"]
                                                              andRows:@[
                                                                        [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_RESTORE_WALLET_TITLE"] subtitle:[String key:@"SETTINGS_RESTORE_WALLET_SUBTITLE"] block:^{ [self restoreWallet]; }],
                                                                        [[SettingsRow alloc]initWithTitle:[String key:@"SETTINGS_EMPTY_WALLET_TITLE"] subtitle:[String key:@"SETTINGS_EMPTY_WALLET_SUBTITLE"] block:^{ [self emptyWallet]; }]
                                                                        ]];
    
    [self.sections setObject:general forKey:@"0"];
    [self.sections setObject:prefs forKey:@"1"];
    [self.sections setObject:wallet forKey:@"2"];
    [self.sections setObject:about forKey:@"3"];
    [self.sections setObject:diagnostics forKey:@"4"];
    [self.sections setObject:advanced forKey:@"5"];
    
    [self.tableView reloadData];
}

-(void)removePin
{
    [self showSecuredBlock:^{
        
        [KnCPinUtil setNewPin:@""];
        [self resetSections];
        
        [SVProgressHUD showSuccessWithStatus:[String key:@"PIN_REMOVED_SUCCESS"]];
        
    }];
}

-(void)askResetBlockChain
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String key:@"SETTINGS_RESET_BLOCKCHAIN_TITLE"] message:[String key:@"SETTINGS_RESET_BLOCKCHAIN_MESSAGE"] delegate:self cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"YES"], nil];
    alert.tag = ALERT_RESET_BLOCK_CHAIN;
    [alert show];
}

-(void)simpleAlert:(NSString*)title message:(NSString*)message
{
    [[[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
}

-(void)unimplemented
{
    [[[UIAlertView alloc]initWithTitle:@"Unimplemented" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
}
-(void)showDenomination
{
    [self.navigationController pushViewController:[[KnCDenominationTableViewController alloc]init] animated:YES];
}

-(void)showAbout
{
    [self.navigationController pushViewController:[[KnCAboutTableViewController alloc]init] animated:YES];
}

-(void)showHints
{
    [self.navigationController pushViewController:[[KnCHintsViewController alloc]init] animated:YES];
}

-(void)showLicenses
{
    [self.navigationController pushViewController:[[KnCLicenseTableViewController alloc]init] animated:YES];
}

-(void)emptyWallet
{
    [self.delegate settingsInvalidated];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate emptyWallet];
    }];
}

-(void)showBackupWallet
{
    [self.navigationController pushViewController:[[KnCBackupTableViewController alloc]init] animated:YES];
}

-(void)iCloudBackup
{
    [((BRAppDelegate*)[UIApplication sharedApplication].delegate) iCloudBackupWordSeed:^(BOOL success, NSString *message) {
        if(success){
            [SVProgressHUD showSuccessWithStatus:message];
        }else{
            [SVProgressHUD showErrorWithStatus:message];
        }
    }];
}

-(void)showBackupStorage
{
    [self.navigationController pushViewController:[[KnCStorageTableViewController alloc]init] animated:YES];
}

-(void)restoreWallet
{
    [self showSecuredBlock:^{
        [self.navigationController pushViewController:[[KncRestoreViewController alloc]init] animated:YES];
    }];
}

-(void)showBackupPhrase
{
    [self showSecuredBlock:^{
        [self.navigationController pushViewController:[[KnCBackupPhraseViewController alloc]init] animated:YES];
    }];
}

-(void)showSecuredBlock:(void (^)(void))block
{
    if([KnCPinUtil hasPin]){
        
        KnCPinViewController *pin = [[KnCPinViewController alloc]initCancelable];
        __weak KnCPinViewController *pinRef = pin;
        [pin setCompletionBlock:^(BOOL success) {
            [pinRef dismissViewControllerAnimated:YES completion:^{
                if(success){
                    block();
                }
            }];
        }];
        
        [self presentViewController:pin animated:YES completion:nil];
        
    }else{
        block();
    }
}

-(void)showPinCode
{
    KnCPinViewController *vc = [[KnCPinViewController alloc]initConfigureMode];
    __weak KnCPinViewController *ref = vc;
    [vc setCompletionBlock:^(BOOL success) {
        [ref dismissViewControllerAnimated:YES completion:nil];
        [self resetSections];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)showAddressBook
{
    KnCAddressBookTableViewController *vc = [[KnCAddressBookTableViewController alloc]initWithMode:KnCAddressBookModeEdit];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showExchangeRates
{
    [self.navigationController pushViewController:[[KnCExchangeRatesTableViewController alloc]init] animated:YES];
}

-(void)removeEntryDetails
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String key:@"SETTINGS_REMOVE_DETAILS_TITLE"]
                                                   message:[String key:@"SETTINGS_REMOVE_DETAILS_SUBTITLE"]
                                                  delegate:self cancelButtonTitle:[String key:@"CANCEL"]
                                         otherButtonTitles:[String key:@"DELETE"], nil];
    alert.tag = ALERT_REMOVE_DETAILS;
    [alert show];
}

-(void)doRemoveEntryDetails
{
    [SVProgressHUD showWithStatus:[String key:@"SETTINGS_REMOVE_DETAILS_REMOVING"] maskType:SVProgressHUDMaskTypeGradient];
    
    [KnCDirectory removeEntryRequest:^(NSDictionary *response) {
        [KnCDirectory setRegistered:NO];
        [KnCDirectory setRemoved:YES];
        [SVProgressHUD dismiss];
        [self resetSections];
        
        [SVProgressHUD showSuccessWithStatus:[String key:@"SETTINGS_REMOVE_DETAILS_REMOVED"]];
        
    } errorCallback:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self simpleAlert:[String key:@"ALERT_ERROR_TITLE"] message:[error domain]];
    }];
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ALERT_REMOVE_DETAILS && buttonIndex == 1){
        [self doRemoveEntryDetails];
    }else if(alertView.tag == ALERT_RESET_BLOCK_CHAIN && buttonIndex == 1){
        
        [[BRPeerManager sharedInstance] rescan];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}



-(void)dismiss:(id)sender
{
    [self.delegate settingsInvalidated];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.sections allKeys]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self settingsSection:section].rows.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self settingsSection:section].title;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 5){
        return [self dangerousTableViewHeader:[self tableView:tableView titleForHeaderInSection:section]];
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    SettingsSection *settingsSection = [self settingsSectionForIndexPath:indexPath];
    SettingsRow *row = [settingsSection.rows objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.5f];
    
    cell.userInteractionEnabled = row.enabled;
    [cell.detailTextLabel setHighlightedTextColor:nil];
    
    if(row.enabled){
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }else{
        cell.textLabel.textColor = [UIColor disabledGray];
        cell.detailTextLabel.textColor = [UIColor disabledGray];
    }
    
    cell.textLabel.text = row.title;
    
    if(row.subtitle && row.subtitle.length > 0){
        cell.detailTextLabel.text = row.subtitle;
    }else{
        cell.detailTextLabel.text = nil;
    }

    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    
    return cell;
}

-(SettingsSection*)settingsSection:(int)section
{
    return [self.sections objectForKey:[NSString stringWithFormat:@"%i",section]];
}

-(SettingsSection*)settingsSectionForIndexPath:(NSIndexPath *)indexPath
{
    return [self settingsSection:indexPath.section];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsSection *settingsSection = [self settingsSectionForIndexPath:indexPath];
    SettingsRow *row = [settingsSection.rows objectAtIndex:indexPath.row];
    
    if(row.block){
        row.block();
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


@end
