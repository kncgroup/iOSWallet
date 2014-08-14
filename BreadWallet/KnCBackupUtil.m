
#import "KnCBackupUtil.h"
#import "FBEncryptorAES.h"
#import "BRWalletManager.h"
#import "String.h"
#import "KnCMetadataQuery.h"

@interface KnCBackupUtil()

@property (nonatomic, strong) KnCMetadataQuery *query;

@end

@implementation KnCBackupUtil

-(id)init
{
    self = [super init];
    if(self){
        [self iCloudSetup];
    }
    return self;
}

-(void)iCloudSetup
{
    id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];

    if (currentiCloudToken) {
        NSData *newTokenData =
        [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults]
         setObject: newTokenData
         forKey: @"com.kncwallet.wallet.UbiquityIdentityToken"];
    } else {
        [[NSUserDefaults standardUserDefaults]
         removeObjectForKey: @"com.kncwallet.wallet.UbiquityIdentityToken"];
    }
    
    
    self.ubiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if(self.ubiquitousURL){
        NSLog(@"iCloud available");
    }else{
        NSLog(@"iCloud not available");
    }
    
}

-(NSString*)backupTitle
{
    NSString *testnet = @"";
#if BITCOIN_TESTNET
    testnet = @"-testnet";
#endif
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"bitcoin-wallet-phrase%@-%@",testnet,dateString];
}


-(void)iCloudBackupWordSeed:(void (^)(BOOL success, NSString * message))completion
{
    if(!self.ubiquitousURL){
        completion(NO, [String key:@"BACKUP_ICLOUD_NOT_AVAILABLE"]);
        return;
    }

    NSString *phrase = [[BRWalletManager sharedInstance] seedPhrase];
    
    if(!phrase){
        completion(NO,[String key:@"BACKUP_DOCUMENT_NO_PHRASE"]);
        return;
    }
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSArray *current = [store arrayForKey:@"seeds"];

    if(!current){
        current = [NSArray array];
    }

    if([current containsObject:phrase]){
        completion(NO, [String key:@"BACKUP_ALREADY_EXIST"]);
        return;
    }
    
    NSMutableArray *newArray = [NSMutableArray arrayWithObject:phrase];
    [newArray addObjectsFromArray:current];

    [store setObject:newArray forKey:@"seeds"];

    if([store synchronize]){
        completion(YES,[String key:@"BACKUP_DOCUMENT_SAVED"]);
    }else{
        completion(NO, [String key:@"BACKUP_DOCUMENT_ERROR_SAVE"]);
    }
}

-(void)saveDocument:(NSString*)fileName withContent:(NSString*)content completionCallback:(void (^)(BOOL success, NSString * message))completion
{
    
    if(!self.ubiquitousURL){
        completion(NO, [String key:@"BACKUP_ICLOUD_NOT_AVAILABLE"]);
        return;
    }
    NSURL *destinationURL = [[self.ubiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.dox",fileName]];
    KnCDocument *doc = [[KnCDocument alloc]initWithFileURL:destinationURL];
    
    doc.content = [NSString stringWithString:content];
    
    [doc saveToURL:destinationURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        
        if(success){
            completion(YES,[String key:@"BACKUP_DOCUMENT_SAVED"]);
        }else{
            completion(NO, [String key:@"BACKUP_DOCUMENT_ERROR_SAVE"]);
        }
        
    }];
    
}

-(NSString*)encryptedBackup:(NSString*)key
{
    NSString *phrase = [[BRWalletManager sharedInstance] seedPhrase];
    if(!phrase){
        return nil;
    }
    return [FBEncryptorAES encryptBase64String:phrase keyString:key separateLines:NO];
}

-(NSString*)decryptDocumentContent:(KnCDocument*)document withKey:(NSString*)key
{
    return [self decrypt:document.content withKey:key];
}
-(NSString*)decrypt:(NSString*)content withKey:(NSString*)key
{
    return [FBEncryptorAES decryptBase64String:content keyString:key];
}

-(void)openDocument:(NSString*)fileName completionCallback:(void (^)(BOOL success, KnCDocument * document, NSString *message))completion
{
    
    if(!self.ubiquitousURL){
        completion(NO, nil, [String key:@"BACKUP_ICLOUD_NOT_AVAILABLE"]);
        return;
    }
    
    NSURL *destinationURL = [[self.ubiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
    KnCDocument *doc = [[KnCDocument alloc]initWithFileURL:destinationURL];
    
    [doc openWithCompletionHandler:^(BOOL success) {
        if(success){
            completion(YES, doc, [String key:@"BACKUP_OPEN_SUCCESS"]);
        }else{
            completion(NO, nil, [String key:@"BACKUP_OPEN_FAILURE"]);
        }
    }];
    
}

-(void)allBackups:(void (^)(BOOL success, NSArray *seeds, NSString *message))completion
{
    if(!self.ubiquitousURL){
        completion(NO, nil, [String key:@"BACKUP_ICLOUD_NOT_AVAILABLE"]);
        return;
    }
    
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    NSArray *current = [store arrayForKey:@"seeds"];
    
    if(!current){
        current = [NSArray array];
    }
    completion(YES, current, nil);
}

-(void)aasdallDocuments:(void (^)(BOOL success, NSArray *urls, NSString *message))completion
{
    
    if(!self.ubiquitousURL){
        completion(NO, nil, [String key:@"BACKUP_ICLOUD_NOT_AVAILABLE"]);
        return;
    }
    
    self.query = [[KnCMetadataQuery alloc] init];
    [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K like[cd] %@", NSMetadataItemFSNameKey, @"*"];

    [self.query setPredicate:pred];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:self.query];
    [self.query startQuery];
    
    self.query.block = ^(NSArray *results) {
      
        NSMutableArray *urls = [NSMutableArray array];
        for(NSMetadataItem *item in results){
            NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
            [urls addObject:url];
        }
        
        completion(YES, urls, nil);
        
    };
}

- (void)queryDidFinishGathering:(NSNotification *)notif {
    KnCMetadataQuery *query = [notif object];
    [query disableUpdates];
    [query stopQuery];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    query.block([query results]);
}

-(BOOL)emailBackup:(NSString*)key delegate:(UIViewController<MFMailComposeViewControllerDelegate>*)sender;
{
    if(![MFMailComposeViewController canSendMail]){
        return NO;
    }
    
    NSString *content = [self encryptedBackup:key];
    if(!content){
        return NO;
    }
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if(!data){
        return NO;
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc]init];
    if(mc){
        [mc setSubject:[String key:@"BACKUP_MAIL_SUBJECT"]];
        [mc setMessageBody:[String key:@"BACKUP_MAIL_BODY"] isHTML:NO];
        mc.mailComposeDelegate = sender;
        [mc addAttachmentData:data mimeType:@"text/plain" fileName:[self backupTitle]];
        [sender presentViewController:mc animated:YES completion:nil];
        return YES;
    }
    
    return NO;
    
}


@end
