

#import "KnCBackupTableViewController.h"
#import "KnCSettingsTableViewCell.h"
#import "KnCTextFieldTableViewCell.h"
#import "String.h"
#import "KnCBackupUtil.h"
#import "BRAppDelegate.h"
#import "SVProgressHUD.h"

@interface KnCBackupTableViewController ()

@property (nonatomic, strong) NSString *inputPassword;

@end

@implementation KnCBackupTableViewController

#define SECTION_ICLOUD 1
#define SECTION_EMAIL 2

static NSString *cellIdentifierSettings = @"SettingsCell";
static NSString *cellIdentifierTextField = @"TextCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCSettingsTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierSettings];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierTextField];

    self.title = [String key:@"BACKUP"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[String key:@"SEND"] style:UIBarButtonItemStyleDone target:self action:@selector(emailBackup)];
    
}

-(BOOL)checkPassword
{
    if(self.inputPassword && self.inputPassword.length > 0){
        return YES;
    }
    
    [SVProgressHUD showErrorWithStatus:[String key:@"BACKUP_NEED_BETTER_PASSWORD"]];
    
    return NO;
}

-(void)dismiss
{
    if(self.navigationController.viewControllers.count > 1){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)emailBackup
{
    if(![self checkPassword]) return;
    
    if(![((BRAppDelegate*)[UIApplication sharedApplication].delegate) emailBackup:self.inputPassword delegate:self]){
        [SVProgressHUD showErrorWithStatus:[String key:@"BACKUP_CAN_NOT_SEND_MAIL"]];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(result == MFMailComposeResultSent){
        [SVProgressHUD showSuccessWithStatus:[String key:@"BACKUP_MAIL_SENT"]];
        [self dismiss];
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
    return 1;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)passwordDidChange:(UITextField*)sender
{
    self.inputPassword = sender.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==0) {
        KnCTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTextField forIndexPath:indexPath];
    
        cell.textField.text = self.inputPassword;
        cell.textField.placeholder = [String key:@"BACKUP_ENTER_PASSWORD"];
        cell.textField.delegate = self;
        [cell.textField addTarget:self action:@selector(passwordDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    }else{
        
        KnCSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSettings forIndexPath:indexPath];
        
        NSString *title = [String key:@"BACKUP_SEND_EMAIL_TITLE"];
        NSString *subtitle = [String key:@"BACKUP_SEND_EMAIL_SUBTITLE"];
        
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subtitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SECTION_EMAIL){
        [self emailBackup];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
