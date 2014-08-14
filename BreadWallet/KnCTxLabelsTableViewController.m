
#import "KnCTxLabelsTableViewController.h"
#import "String.h"
#import "KnCTextFieldTableViewCell.h"
#import "KnCTableViewCell.h"
#import "KnCTxData.h"
#import "NSManagedObject+Sugar.h"
#import "KnCDirectory.h"
#import "AddressBookProvider.h"
#import "BRWallet.h"
#import "BRWalletManager.h"
#import "SVProgressHUD.h"
#import "KnCTxDataUtil.h"

@interface KnCTxLabelsTableViewController ()

@property (nonatomic, strong) NSString *txHash;
@property (nonatomic, strong) BRTransaction *tx;
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSArray *previouslyUsedLabels;
@property (nonatomic, strong) NSString *message;
@end

@implementation KnCTxLabelsTableViewController

static NSString *cellIdentifierTextField = @"TextCell";
static NSString *cellIdentifierRecent = @"Cell";

-(id)initWithBRTransaction:(BRTransaction*)tx
{
    self = [super init];
    if(self){
        self.tx = tx;
        self.txHash = tx.txIdAsString;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierTextField];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierRecent];
    self.title = [String key:@"TX_LABEL_SET"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    KnCTxData *txData = [KnCTxDataUtil txData:self.txHash];
    if(txData.data){
        self.input = [txData.data objectForKey:@"label"];
        self.title = [String key:@"TX_LABEL_EDIT"];
        self.message = [txData.data objectForKey:@"message"];
        
    }else{
        self.input = @"";
    }

    self.previouslyUsedLabels = @[];
    [self loadPreviouslyUsedLabels];
}

-(void)loadPreviouslyUsedLabels
{
    NSArray *all = [KnCTxData allObjects];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *labels = [NSMutableArray array];
        
        NSMutableDictionary *addedLabels = [NSMutableDictionary dictionary];
        
        for(KnCTxData *data in all){
            
            if(data.data && [data.data objectForKey:@"label"]){
                NSString *label = [data.data objectForKey:@"label"];
                if(![label isEqualToString:self.input] && label.length > 0 && ![addedLabels objectForKey:label]){
                    [labels addObject:label];
                    [addedLabels setObject:@"" forKey:label];
                }
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.previouslyUsedLabels = labels;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        
    });
    
    

}

-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)save
{
    [KnCTxDataUtil saveLabel:self.input toTx:self.txHash];
}

-(void)saveOnKnCDirectory:(NSMutableDictionary*)payload
{
    NSString *counterpart = @"";
    
    BRWallet *wallet = [[BRWalletManager sharedInstance]wallet];
    
    uint64_t sent = [wallet amountSentByTransaction:self.tx];
    
    NSString *address = [wallet addressForTransaction:self.tx];
    
    KnCContact *contact = [AddressBookProvider contactByAddress:address];
    
    if(contact && contact.phone){
        counterpart = contact.phone;
    }
    
    [KnCDirectory updateTxRequest:counterpart note:self.input sent:sent>0 txId:self.txHash payload:payload completionCallback:^(NSDictionary *response) {
        
    } errorCallback:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"ERROR_UPLOADING_TX_INFO"];
    }];
    
    
}

-(void)done:(id)sender
{
    [self save];
    [self.labelsDelegate labelWasUpdated];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)inputChanged:(UITextField*)sender
{
    self.input = sender.text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    }else if(section == 1){
        return 1;
    }else if(section == 2){
        return self.previouslyUsedLabels.count;
    }
    return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return [String key:@"MESSAGE"];
    }else if(section == 1){
        return [String key:@"TX_LABEL"];
    }else if(section == 2){
        return [String key:@"TX_LABEL_PREVIOUSLY_USED"];
    }
    return nil;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0){
        return self.message;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0){
        
        KnCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierRecent forIndexPath:indexPath];
        
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = self.message;
        cell.userInteractionEnabled = NO;
        
        return cell;
    }else if(indexPath.section == 1){
        KnCTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTextField forIndexPath:indexPath];
        cell.textField.text = self.input;
        cell.textField.delegate = self;
        [cell.textField becomeFirstResponder];
        [cell.textField addTarget:self action:@selector(inputChanged:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    }else if(indexPath.section == 2){
    
        KnCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierRecent forIndexPath:indexPath];
        
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = [self.previouslyUsedLabels objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    return nil;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2){
        self.input = [self.previouslyUsedLabels objectAtIndex:indexPath.row];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
