
#import "KnCRestoreBackupTableViewController.h"
#import "String.h"
#import "KnCTextFieldTableViewCell.h"
#import "KnCFileTableViewCell.h"
#import "KnCBackupUtil.h"
#import "SVProgressHUD.h"
#import "BRWalletManager.h"

@interface KnCRestoreBackupTableViewController ()

@property (nonatomic, strong) KnCDocument *document;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *urlContent;
@property (nonatomic, strong) KnCBackupUtil *backupUtil;
@property (nonatomic, strong) NSString *keyInput;

@end

@implementation KnCRestoreBackupTableViewController

static NSString *cellTextFieldIdentifier = @"TextFieldCell";
static NSString *cellFileIdentifier = @"FileCell";

-(id)initWithDocument:(KnCDocument*)document
{
    self = [super init];
    if(self){
        self.document = document;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backupUtil = [[KnCBackupUtil alloc]init];
    
    self.keyInput = @"";
    self.title = [String key:@"BACKUP_RESTORE"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:cellTextFieldIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCFileTableViewCell" bundle:nil] forCellReuseIdentifier:cellFileIdentifier];
    
    if(self.document){
        [self setupDoneButton];
    }
    
    
    
    if(self.url){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSFileManager *fm = [NSFileManager defaultManager];
            NSData *data = [fm contentsAtPath:[self.url path]];
            if(data){
                self.urlContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{

                if(self.urlContent){
                    [self setupDoneButton];
                }else{
                    [SVProgressHUD showErrorWithStatus:[String key:@"BACKUP_OPEN_FAILURE"]];
                }
                
                [self.tableView reloadData];
            });
        });
    }
    
    if(self.navigationController.viewControllers.count < 2){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    }
    
}

-(void)setupDoneButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
}

-(id)initWithUrl:(NSURL*)url
{
    self = [super init];
    if(self){
        self.url = url;
    }
    return self;
}

-(void)done:(id)sender
{
    NSString *result = nil;
    if(self.document){
       result = [self.backupUtil decryptDocumentContent:self.document withKey:self.keyInput];
    }else if(self.urlContent){
        result = [self.backupUtil decrypt:self.urlContent withKey:self.keyInput];
    }
    
    if(!result){
        [SVProgressHUD showErrorWithStatus:[String key:@"BACKUP_WRONG_PASSWORD"]];
    }else{
        NSString *current = [[BRWalletManager sharedInstance]seedPhrase];
        
        if([result isEqualToString:current]){
            [SVProgressHUD showErrorWithStatus:[String key:@"BACKUP_SAME_SEED"]];
        }else{
            [SVProgressHUD showSuccessWithStatus:[String key:@"BACKUP_RESTORE_PROGRESS_STARTED"]];
            [[BRWalletManager sharedInstance]setSeedPhrase:result];
            [self dismiss];
        }
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self done:nil];
    return YES;
}

-(void)inputChanged:(UITextField*)textField
{
    self.keyInput = textField.text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.document || (self.url && self.urlContent)){
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return [String key:@"BACKUP_RESTORE_FILE"];
    }else if(section == 1){
        return [String key:@"BACKUP_RESTORE_ENTER_PASSWORD"];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        KnCFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellFileIdentifier forIndexPath:indexPath];

        cell.name.text = @"";
        
        if(self.document){
            cell.name.text = [self.document.fileURL lastPathComponent];
        }else if(self.url){
            cell.name.text = [self.url lastPathComponent];
        }
        
        return cell;
    }
    
    KnCTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTextFieldIdentifier forIndexPath:indexPath];
    cell.textField.secureTextEntry = YES;
    cell.textField.returnKeyType = UIReturnKeyGo;
    cell.textField.delegate = self;
    [cell.textField addTarget:self action:@selector(inputChanged:) forControlEvents:UIControlEventEditingChanged];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell.textField becomeFirstResponder];
    });

    
    return cell;
}



@end
