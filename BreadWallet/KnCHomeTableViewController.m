
#import "KnCHomeTableViewController.h"
#import "KnCBalanceTableViewCell.h"
#import "KnCTxTableViewCell.h"

#import "BRWalletManager.h"
#import "BRWallet.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "KnCDirectory.h"
#import "CurrencyUtil.h"
#import "String.h"

#import "AddressBookProvider.h"
#import "KnCImageView+UIImageView.h"
#import "ImageUtils.h"
#import "KnCBalanceTableViewCell.h"
#import "KnCDateUtil.h"
#import "KnCTxData.h"
#import "NSManagedObject+Sugar.h"
#import "KnCTxDataUtil.h"

#define SHEET_TX 1

@interface KnCHomeTableViewController ()

@property (nonatomic) int64_t balance;
@property (nonatomic) BOOL displayLocalCurrency;
@property (nonatomic, strong) NSMutableArray *transactions;
@property (nonatomic, strong) NSMutableArray *filteredTransactions;
@property (nonatomic) NSInteger filter;
@property (nonatomic, strong) NSMutableDictionary *txDates;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSMutableDictionary *nameCache;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSMutableDictionary *txDataCache;
@property (nonatomic, strong) NSMutableDictionary *rowHeights;
@end

@implementation KnCHomeTableViewController

static NSString *cellIdentifierTx = @"TxCell";
static NSString *cellIdentifierBalance = @"BalanceCell";


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [String key:@"HOME"];
    self.filter = 1;
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTxTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierTx];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCBalanceTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifierBalance];
    self.txDates = [NSMutableDictionary dictionary];
    self.nameCache = [NSMutableDictionary dictionary];
    self.imageCache = [NSMutableDictionary dictionary];
    self.txDataCache = [NSMutableDictionary dictionary];
    self.rowHeights = [NSMutableDictionary dictionary];
    self.displayLocalCurrency = NO;
    [self updateBalance];
}

-(void)updateBalance
{
    self.balance = [[[BRWalletManager sharedInstance]wallet]balance];
    
    [self updateTransactions];
    [self labelWasUpdated];
}

-(id)initWithParent:(KnCMainViewController*)parent
{
    self = [super init];
    if(self){
        self.parent = parent;
    }
    
    return self;
}

-(void)contactTableViewControllerDelegate:(id)sender updatedContact:(id)contact
{
    [self settingsInvalidated];
}

-(void)labelWasUpdated
{
    [self.rowHeights removeAllObjects];
    [self.txDataCache removeAllObjects];
    [self.tableView reloadData];
}

-(void)settingsInvalidated
{
    [self.rowHeights removeAllObjects];
    [self.txDataCache removeAllObjects];
    [self.nameCache removeAllObjects];
    [self.imageCache removeAllObjects];
    [self.tableView reloadData];
}

-(NSString*)tabBarIcon
{
    return @"home";
}

-(void)updateTransactions
{
    BRWalletManager *m = [BRWalletManager sharedInstance];
    NSArray *recent = [m.wallet recentTransactions];
    self.transactions = [NSMutableArray arrayWithArray:recent];
    self.filteredTransactions = [NSMutableArray array];
    [self updateFilter];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if(section == 1){
        UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        [head setBackgroundColor:[UIColor whiteColor]];

        int pad = 7;

        UISegmentedControl * seg = [[UISegmentedControl alloc]initWithFrame:CGRectMake(pad, pad, self.tableView.frame.size.width - pad * 2, 30)];
        [seg insertSegmentWithTitle:[String key:@"HOME_SEG_SENT"] atIndex:0 animated:YES];
        [seg insertSegmentWithTitle:[String key:@"HOME_SEG_ALL"] atIndex:1 animated:YES];
        [seg insertSegmentWithTitle:[String key:@"HOME_SEG_RECEIVED"] atIndex:2 animated:YES];

        [seg addTarget:self action:@selector(segmentFilterChanged:) forControlEvents:UIControlEventValueChanged];

        [seg setSelectedSegmentIndex:self.filter];

        [head addSubview:seg];

        return head;
    }
    return nil;
}

-(void)segmentFilterChanged:(UISegmentedControl*)seg
{
    [self.rowHeights removeAllObjects];
    self.filter = seg.selectedSegmentIndex;
    [self updateFilter];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)updateFilter
{
    [self.filteredTransactions removeAllObjects];
    if(self.filter == 1){
        [self.filteredTransactions addObjectsFromArray:self.transactions];
    }else{
        BRWalletManager *m = [BRWalletManager sharedInstance];
        for(BRTransaction *tx in self.transactions){
            BOOL sent = [m.wallet amountSentByTransaction:tx] > 0;
            
            if(self.filter == 0 && sent){
                [self.filteredTransactions addObject:tx];
            }else if(self.filter == 2 && !sent){
                [self.filteredTransactions addObject:tx];
            }
        }
    }
    
    [self.tableView reloadData];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        return 44;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else if(section == 1){
        return MAX(1,self.filteredTransactions.count);
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return [KnCBalanceTableViewCell height];
    }else if(indexPath.section == 1 && self.filteredTransactions.count > 0){
        
        NSDictionary *data = [self dataForIndexPath:indexPath withAddress:nil];
        
        NSString *key = [NSString stringWithFormat:@"%li",(long)indexPath.row];
        if(data && ([data objectForKey:@"label"] || [data objectForKey:@"message"])){
            
            NSString *label = [data objectForKey:@"label"];
            NSString *message = [data objectForKey:@"message"];
            
            [self.rowHeights setObject:[NSNumber numberWithFloat:[KnCTxTableViewCell calculateCellHeightWithLabel:label andMessage:message]] forKey:key];
        }else{
            [self.rowHeights setObject:[NSNumber numberWithFloat:[KnCTxTableViewCell height]] forKey:key];
        }
        return [[self.rowHeights objectForKey:key] floatValue];
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        
        KnCBalanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierBalance forIndexPath:indexPath];
        
        [cell setBalance:self.balance useLocalCurrency:self.displayLocalCurrency];
        
        return cell;
        
    }else if(indexPath.section == 1){
        KnCTxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierTx forIndexPath:indexPath];
        
        if(self.filteredTransactions.count > 0){
            BRTransaction *tx = [self.filteredTransactions objectAtIndex:indexPath.row];
            
            BRWalletManager *m = [BRWalletManager sharedInstance];
            uint64_t received = [m.wallet amountReceivedFromTransaction:tx];
            uint64_t sent = [m.wallet amountSentByTransaction:tx];
            uint32_t height = [[BRPeerManager sharedInstance] lastBlockHeight],
            confirms = (tx.blockHeight == TX_UNCONFIRMED) ? 0 : (height - tx.blockHeight) + 1;
            int64_t fee = [m.wallet feeForTransaction:tx];
            NSString *address = [m.wallet addressForTransaction:tx];
            
            UIImage *image = [self imageForAddress:address];
            if(!image){
                image = [UIImage imageNamed:@"contact-inverted-big"];
                [cell.contact setContentMode:UIViewContentModeScaleAspectFill];
            }else{
                [cell.contact setContentMode:UIViewContentModeCenter];
            }
            cell.contact.image = image;
            
            uint64_t amount = received;
            NSString *fromTo = [String key:@"HOME_FROM"];
            if(sent > 0){
                fromTo = [String key:@"HOME_TO"];
                amount = received - sent;
            }
            
            NSString *toName = [String key:@"HOME_UNKNOWN_COUNTERPART"];
            
            NSString *name = [self nameForAddress:address inTx:tx];
            if(name){
                toName = name;
            }else if(address){
                toName = address;
            }
            
            [cell setAmount:amount withFee:fee usingLocalCurrency:self.displayLocalCurrency];
            [cell setToName:toName fromToLabel:fromTo];
            [cell setDateString:[self dateForTx:tx]];
            [cell.contact applyCircleMask];
            [cell.contact setHidden:NO];
            [cell setConfirmationsProgress:confirms/(TX_CONFIRMS+0.0f)];
            
            NSDictionary *data = [self dataForIndexPath:indexPath withAddress:address];
            if(data){
                [cell setTxLabel:[data objectForKey:@"label"] andMessage:[data objectForKey:@"message"]];
            }else{
                [cell setTxLabel:nil andMessage:nil];
            }
            [cell setUserInteractionEnabled:YES];
            
        }else{
            cell.head.text = @"";
            cell.sub.text = @"";
            cell.middle.text = [String key:@"NO_TRANSACTIONS"];
            cell.subSub.text = @"";
            [cell.contact setHidden:YES];
            [cell.confirmsView setHidden:YES];
            [cell setUserInteractionEnabled:NO];
        }
        
        [cell.separator setHidden: indexPath.row == 0];
        
        return cell;
    }
    
    return nil;
}

-(NSDictionary*)dataForIndexPath:(NSIndexPath*)indexPath withAddress:(NSString*)address
{
    BRTransaction *tx = [self.filteredTransactions objectAtIndex:indexPath.row];
    NSString *txHash = tx.txIdAsString;
    NSDictionary *data = [self.txDataCache objectForKey:txHash];

    if(data) return data;
    
    
    NSArray *search = [KnCTxData objectsMatching:@"txHash == %@", txHash];
    if(search.count > 0){
        KnCTxData *data = search.firstObject;
        if(data.data){
            NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:data.data];
            [self.txDataCache setObject:dictionary forKey:txHash];
            return dictionary;
        }
        
    }else if(address){
        [self lookup:address forTx:tx];
        [self.txDataCache setObject:[NSDictionary dictionary] forKey:txHash];
    }

    return [NSDictionary dictionary];
}

- (NSString *)dateForTx:(BRTransaction *)tx
{
    
    NSString *dateString = self.txDates[tx.txHash];
    
    if (dateString) return dateString;
    
    NSTimeInterval t = [[BRPeerManager sharedInstance] timestampForBlockHeight:tx.blockHeight];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:t-5*60];
    
    NSString *daySuffix = [KnCDateUtil daySuffix:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:[NSString stringWithFormat:@"d'%@' 'of' MMMM h:mm a",daySuffix]];
    
    dateString = [formatter stringFromDate:date];
    
    self.txDates[tx.txHash] = dateString;
    return dateString;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        
        self.displayLocalCurrency = !self.displayLocalCurrency;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
    }else if(indexPath.section == 1 && self.filteredTransactions.count > 0){
        BRTransaction *tx = [self.filteredTransactions objectAtIndex:indexPath.row];
    
        BRWalletManager *m = [BRWalletManager sharedInstance];
        uint64_t received = [m.wallet amountReceivedFromTransaction:tx];
        uint64_t sent = [m.wallet amountSentByTransaction:tx];
        NSString *address = [m.wallet addressForTransaction:tx];
        
        NSString *nameLabel = nil;
        
        uint64_t amount = received;
        NSString *fromTo = [String key:@"HOME_FROM"];
        if(sent > 0){
            fromTo = [String key:@"HOME_TO"];
            amount = received - sent;
        }
        
        if(!address){
            nameLabel = [String key:@"HOME_UNKNOWN_COUNTERPART"];
        }else{
            nameLabel = [NSString stringWithString:address];
        }
        
        NSString *addEdit = [String key:@"ADD_TO_ADDRESS_BOOK"];
        NSString *name = [self nameForAddress:address inTx:tx];
        if(name){
            addEdit = [String key:@"EDIT_IN_ADDRESS_BOOK"];
            nameLabel = name;
        }
        
        
        NSDictionary *data = [self dataForIndexPath:indexPath withAddress:address];
        
        if(address && data.allKeys.count < 2){
            [self relookup:address forTx:tx];
        }
        
        NSString *text = [data objectForKey:@"message"];
        if(!text){
            text = @"";
        }
        if([data objectForKey:@"label"]){
            text = [text stringByAppendingFormat:@"\n%@",[data objectForKey:@"label"]];
        }
        
        NSString *title = [NSString stringWithFormat:@"%@ %@ %@\n%@\n%@",[NSString stringWithFormat:@"%@",[CurrencyUtil stringForBtcAmount:amount]], fromTo, nameLabel, [self dateForTx:tx], text];
        
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:[String key:@"CANCEL"] destructiveButtonTitle:nil otherButtonTitles:addEdit, [String key:@"SEND_CONTACT_COINS"], [String key:@"LABEL"], [String key:@"BITEASY_BROWSE_TX"], nil];
            
        sheet.tag = SHEET_TX;
        [sheet showFromTabBar:self.parent.tabBar];
        
        self.selectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
    }
}

-(void)browseTx:(BRTransaction*)tx
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.biteasy.com/transactions/%@",tx.txIdAsString];
    
#if BITCOIN_TESTNET
    urlString = [NSString stringWithFormat:@"https://www.biteasy.com/testnet/transactions/%@",tx.txIdAsString];
#endif
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == SHEET_TX && self.selectedIndexPath){
        
        BRTransaction *tx = [self.filteredTransactions objectAtIndex:self.selectedIndexPath.row];
        
        BRWalletManager *m = [BRWalletManager sharedInstance];
        NSString *address = [m.wallet addressForTransaction:tx];
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if([buttonTitle isEqualToString:[String key:@"ADD_TO_ADDRESS_BOOK"]] || [buttonTitle isEqualToString:[String key:@"EDIT_IN_ADDRESS_BOOK"]]){
            if(address){
                [self editContactForAddress:address];
            }else{
                [self informTxHasNoAddress];
            }
        }else if([buttonTitle isEqualToString:[String key:@"SEND_CONTACT_COINS"]]){
            if(address){
                [self.parent startSendRequestForAddress:address];
            }else{
                [self informTxHasNoAddress];
            }
        }else if([buttonTitle isEqualToString:[String key:@"LABEL"]]){
            KnCTxLabelsTableViewController *vc = [[KnCTxLabelsTableViewController alloc]initWithBRTransaction:tx];
            vc.labelsDelegate = self;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self.parent presentViewController:nav animated:YES completion:nil];
        }else if([buttonTitle isEqualToString:[String key:@"BITEASY_BROWSE_TX"]]){
            [self browseTx:tx];
        }
        
    }
    
    if(self.selectedIndexPath){
        [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [self.tableView reloadData];
    }
}

- (UIImage*)imageForAddress:(NSString*)address
{
    if(!address) return nil;
    
    UIImage *image = [self.imageCache objectForKey:address];
    if(!image){
        
        KnCContact *contact = [AddressBookProvider contactByAddress:address];
        if(contact){
            UIImage *contactImage = [AddressBookProvider imageForContact:contact];
            if(contactImage){
                image = [ImageUtils imageWithImage:contactImage fit:CGSizeMake(45, 45)];
                [self.imageCache setObject:image forKey:address];
            }else{
                [self.imageCache setObject:@"" forKey:address];
            }
        }
        
    }
    
    if(image && [image isKindOfClass:[UIImage class]]){
        return image;
    }
    
    return nil;
}

- (NSString*)nameForAddress:(NSString*)address inTx:(BRTransaction*)tx
{
    if(!address) return nil;
    
    NSString *name = [self.nameCache objectForKey:address];
    
    if(!name){
        
        KnCContact *contact = [AddressBookProvider contactByAddress:address];

        
        if(!contact){
            NSString *knownPhoneNumber = [KnCTxDataUtil knownTelephoneNumber:tx.txIdAsString];
            if(knownPhoneNumber){
                contact = [AddressBookProvider contactByPhone:knownPhoneNumber];
                if(contact){
                    [AddressBookProvider saveAddress:address toContact:contact];
                }
            }
        }
        
        if(contact && contact.label){
            
            self.nameCache[address] = [NSString stringWithString:contact.label];
            
        }else{
            self.nameCache[address] = @"";
            
        }
    }
    name = self.nameCache[address];
    if([name isEqualToString:@""]){
        return nil;
    }
    
    return name;
}

-(void)relookup:(NSString*)address forTx:(BRTransaction*)tx
{
    NSString *txHash = tx.txIdAsString;
    [AddressBookProvider forceLookup:address forTx:txHash success:^(NSDictionary *response) {
        
        [self lookupDone:address forTx:txHash withResponse:response];
        
    } errorCallback:^(NSError *error) {
        
    }];
}

-(void)lookup:(NSString*)address forTx:(BRTransaction*)tx
{
    NSString *txHash = tx.txIdAsString;
    [AddressBookProvider lookup:address forTx:txHash success:^(NSDictionary *response) {
        
        [self lookupDone:address forTx:txHash withResponse:response];
        
    } errorCallback:^(NSError *error) {
        
    }];
}

-(void)lookupDone:(NSString*)address forTx:(NSString*)txHash withResponse:(NSDictionary*)response
{
    [self.nameCache removeObjectForKey:address];
    [self.rowHeights removeAllObjects];
    [self.txDataCache removeObjectForKey:txHash];
    [self.imageCache removeObjectForKey:address];
    [self.tableView reloadData];
}

-(void)editContactForAddress:(NSString*)address
{
    KncContactTableViewController *vc = [[KncContactTableViewController alloc]initWithAddress:address];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.parent presentViewController:nav animated:YES completion:nil];
}

-(void)informTxHasNoAddress
{
    [[[UIAlertView alloc]initWithTitle:[String key:@"HOME_TX_HAS_NO_ADDRESS"] message:nil delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
}




@end
