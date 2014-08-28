
#import "KnCMainViewController.h"
#import "KnCHomeTableViewController.h"
#import "KnCSendViewController.h"
#import "KnCReceiveViewController.h"
#import "KnCDirectory.h"

#import "BRWallet.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"

#import "KnCWelcomeViewController.h"

#import "SVProgressHUD.h"
#import "CurrencyUtil.h"
#import "String.h"
#import "NSString+Base58.h"
#import "BRPaymentRequest.h"

#import "AddressBookProvider.h"
#import <AVFoundation/AVFoundation.h>

#import "KncBalanceButton.h"
#import "KnCStorageTableViewController.h"
#import "KnCColor+UIColor.h"
#import "KnCViewController+UIViewController.h"
#import "KnCProgressView.h"
#import "KnCPinViewController.h"
#import "Reachability.h"
#import "KnCAlertView.h"

#define TAG_NAV_ACTIVITY 10
#define TAG_NAV_BALANCE 11
#define TAG_SEEKER 12
#define TAG_SEEKER_BORDER 13
#define TAG_NAV_WARNING 14

@interface KnCMainViewController ()

@property (nonatomic, strong) NSMutableArray *pages;
@property (nonatomic, strong) NSString *lastReceiveAddress;
@property (nonatomic) BOOL firstLoad;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic) uint64_t oldBalance;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation KnCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstLoad = YES;
    [self appendKnCLogo];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStyleDone target:self action:@selector(showSettings:)]
                                                ];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera"] style:UIBarButtonItemStyleDone target:self action:@selector(scanQR)];
    
    if(![KnCDirectory isRegistred] && ![KnCDirectory isRemoved]){
        
        BRWallet *wallet = [[BRWalletManager sharedInstance]wallet];
        if(!wallet){
            [[BRWalletManager sharedInstance]generateRandomSeed];
        }
        
        KnCWelcomeViewController *wvc = [[KnCWelcomeViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wvc];
        [self presentViewController:nav animated:NO completion:nil];
    }
    
    self.zbarController = [[ZBarReaderViewController alloc]init];
    self.zbarController.readerDelegate = self;
    
#if BITCOIN_TESTNET
    [self addTestIndicator];
#endif
    
    self.oldBalance = 0;
    
}

-(void)playCoinsReceivedSound
{
    if(!self.audioPlayer){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"coins_received" ofType:@"wav"];

        NSError *err = nil;
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
        self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&err];

        [self.audioPlayer prepareToPlay];
    }
    [self.audioPlayer play];
}

-(void)addTestIndicator
{
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 32, self.view.frame.size.width, 10)];
    [label setText:@"TESTNET"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]];
    [self.navigationController.navigationBar addSubview:label];
    
}

-(void)scanQR
{
    
    [self presentViewController:self.zbarController animated:YES
                                          completion:^{ NSLog(@"present qr reader complete"); }];
    
    BOOL hasFlash = [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] hasTorch];
    
    int off = 54;
    if([self isTallScreen]){
        off = 64;
    }

    UIBarButtonItem *flashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flash"]
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(flash:)];
    UIImageView *seeker = (UIImageView*)[self.zbarController.view viewWithTag:TAG_SEEKER];
    if(!seeker){
        seeker = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.zbarController.view.frame.size.width, self.zbarController.view.frame.size.height-off)];
        [seeker setImage:[UIImage imageNamed:@"qr-scanner"]];
        [seeker setContentMode:UIViewContentModeCenter];
        [self.zbarController.view addSubview:seeker];
    }
    [self.zbarController.view bringSubviewToFront:seeker];
    
    UIView *border = [self.zbarController.view viewWithTag:TAG_SEEKER_BORDER];
    if(!border){
        border = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.zbarController.view.frame.size.width, self.zbarController.view.frame.size.height-off)];
        border.layer.borderColor = [UIColor teal].CGColor;
        border.layer.borderWidth = 2;
        [border setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.zbarController.view addSubview:border];
    }
    [self.zbarController.view bringSubviewToFront:border];
    
    [self.zbarController.view setBackgroundColor:[UIColor whiteColor]];
    
    // replace zbarController.view info button with flash toggle
    for (UIView *v in self.zbarController.view.subviews) {
        
        for (id t in v.subviews) {
           
            [t setBackgroundColor:[UIColor whiteColor]];
            
            if ([t isKindOfClass:[UIToolbar class]] && [[t items] count] > 1) {
                
                ((UIToolbar*)t).barStyle = 0;
                [t setBackgroundColor:[UIColor whiteColor]];
                
                UIBarButtonItem *cancelButton =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                              target:[(UIBarButtonItem *)[t items][0] target] action:[(UIBarButtonItem *)[t items][0] action]];
                
                UIBarButtonItem *spacing = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                
                hasFlash ? [t setItems:@[cancelButton, spacing, flashButton]] : [t setItems:@[cancelButton]];
                
                [v setBackgroundColor:[UIColor whiteColor]];
            }
            
        }
    }
}

- (IBAction)flash:(id)sender
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    device.torchMode = device.torchActive ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader withRetry: (BOOL) retry
{
    NSLog(@"did fail qr");
}

- (void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // ignore additonal qr codes while we're still giving visual feedback about the current one
    if ([[(id)self.zbarController.cameraOverlayView image] isEqual:[UIImage imageNamed:@"cameraguide-green.png"]]) {
        return;
    }
    
    for (id result in info[ZBarReaderControllerResults]) {
        NSString *s = (id)[result data];
        BRPaymentRequest *request = [BRPaymentRequest requestWithString:s];
        
        if (! [request isValid] && ! [s isValidBitcoinPrivateKey] && ! [s isValidBitcoinBIP38Key]) {
            [(id)self.zbarController.cameraOverlayView setImage:[UIImage imageNamed:@"cameraguide-red.png"]];
            
            // display red camera guide for 0.5 seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [(id)self.zbarController.cameraOverlayView setImage:[UIImage imageNamed:@"cameraguide.png"]];
                
                if ([s hasPrefix:@"bitcoin:"] || [request.paymentAddress hasPrefix:@"1"]) {
                    [[[UIAlertView alloc] initWithTitle:[String key:@"SCAN_NOT_VALID_ADDRESS"]
                                                message:request.paymentAddress delegate:nil cancelButtonTitle:[String key:@"OK"]
                                      otherButtonTitles:nil] show];
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:[String key:@"SCAN_NOT_BITCOIN_QR"] message:nil
                                               delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil] show];
                }
            });
        }
        else {
            [(id)self.zbarController.cameraOverlayView setImage:[UIImage imageNamed:@"cameraguide-green.png"]];
            
            if (request.r.length > 0) { // start fetching payment protocol request right away
                [BRPaymentRequest fetch:request.r completion:^(BRPaymentProtocolRequest *req, NSError *error) {
                    if (error) {
                        [[[UIAlertView alloc] initWithTitle:[String key:@"SCAN_COULD_NOT_MAKE_PAYMENT"]
                                                    message:error.localizedDescription delegate:nil
                                          cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil] show];
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [reader dismissViewControllerAnimated:YES completion:^{
                            [(id)self.zbarController.cameraOverlayView
                             setImage:[UIImage imageNamed:@"cameraguide.png"]];
                            [self confirmProtocolRequest:req];
                        }];
                    });
                }];
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [reader dismissViewControllerAnimated:YES completion:^{
                        [(id)self.zbarController.cameraOverlayView setImage:[UIImage imageNamed:@"cameraguide.png"]];
                        [self confirmRequest:request];
                    }];
                });
            }
        }
        
        break;
    }
}

-(void)confirmProtocolRequest:(BRPaymentProtocolRequest*)request
{

}

-(void)confirmRequest:(BRPaymentRequest*)request
{
    if(request.paymentAddress){
        [self startSendRequest:request];
    }
}

-(void)updateAddressDirectoryEntry
{
    
    NSString *receiveAddress = [[[BRWalletManager sharedInstance]wallet] receiveAddress];
    
    if((receiveAddress && !self.lastReceiveAddress) || (receiveAddress && self.lastReceiveAddress && ![self.lastReceiveAddress isEqualToString:receiveAddress])){
    
        [KnCDirectory addressPatchRequest:receiveAddress completionCallback:^(NSDictionary *response) {
           
            self.lastReceiveAddress = [NSString stringWithString:receiveAddress];
            
        } errorCallback:^(NSError *error) {
            
        }];
    }
}

-(void)registerObservers
{
    
    [[BRPeerManager sharedInstance] connect];

    if(!self.reachability){
        self.reachabilityObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          if (self.reachability.currentReachabilityStatus != NotReachable) {
                                                              [[BRPeerManager sharedInstance] connect];
                                                          }
                                                          else if (self.reachability.currentReachabilityStatus == NotReachable) [self addSyncWarning];
                                                      }];
    }
    
    if(!self.reachability){
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
    }
    
    self.balanceObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      if ([[BRPeerManager sharedInstance] syncProgress] < 1.0) return; // wait for sync before updating balance
                                                      
                                                      [self balanceWasUpdated];
                                                      [self updateAddressDirectoryEntry];
                                                  }];
    if(!self.syncStartedObserver){
        self.syncStartedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncStartedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               [self syncWasStarted];
                                                           }];
    }
    
    if(!self.syncFinishedObserver){
        self.syncFinishedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               [self syncWasFinished];
                                                           }];
    }
    
    if(!self.syncFailedObserver){
    self.syncFailedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               [self syncFailed];
                                                           }];
    }
    
    
}

-(void)startSendRequestForAddress:(NSString*)address
{
    BRPaymentRequest *request = [[BRPaymentRequest alloc]init];
    request.paymentAddress = address;
    [self startSendRequest:request];
}


-(void)startSendRequest:(BRPaymentRequest*)request
{
    int index = 0;
    for(UIViewController *vc in self.pages){
        if([vc isKindOfClass:[KnCSendViewController class]]){
            KnCSendViewController *svc = (KnCSendViewController*)vc;
            [svc startSendRequest:request];
            [self displayPage:index];
            return;
        }
        index++;
    }
}

-(void)removeViewFromNavigationBar:(int)tag
{
    while ([self.navigationController.navigationBar viewWithTag:tag]) {
        [[self.navigationController.navigationBar viewWithTag:tag]removeFromSuperview];
    };
}

-(void)removeNavigationBarActivityIndicator
{
    [self removeViewFromNavigationBar:TAG_NAV_ACTIVITY];
    [self setKnCLogoHidden:NO];
}
-(void)addNavigationBarActivityIndicator
{
    [self removeNavigationBarActivityIndicator];
    
    [self setKnCLogoHidden:YES];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.tag = TAG_NAV_ACTIVITY;
    [view setUserInteractionEnabled:NO];
    KnCProgressView *progressView = [[KnCProgressView alloc]initWithFrame:CGRectMake(0, 0, 320, 3)];
    [view addSubview:progressView];
    
    UILabel *info = [[UILabel alloc]initWithFrame:CGRectMake(60, 7, 200, 20)];
    [info setText:[String key:@"TOP_SYNC_IN_PROGRESS"]];
    [info setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setUserInteractionEnabled:NO];
    [view addSubview:info];
    
    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(60, 22, 200, 15)];
    [sub setText:[String key:@"TOP_SYNC_IN_PROGRESS_SUBTITLE"]];
    [sub setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0f]];
    [sub setTextAlignment:NSTextAlignmentCenter];
    [sub setUserInteractionEnabled:NO];
    [view addSubview:sub];
    
    
    [self.navigationController.navigationBar addSubview:view];
}


-(void)removeSyncWarning
{
    [self removeViewFromNavigationBar:TAG_NAV_WARNING];
}

-(void)addSyncWarning
{
    
    [self removeSyncWarning];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(95, 4, 50, 35)];
    button.tag = TAG_NAV_WARNING;
    [button setTintColor:[UIColor teal]];
    
    __weak UIImage *image = [[UIImage imageNamed:@"warning"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(syncWarningPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:button];
    
    
}

-(void)reconnect
{
    BRPeerManager *pm = [BRPeerManager sharedInstance];
    if([pm connected]){
        [self removeSyncWarning];
    }else{
        [pm retryConnect];
    }
}

-(void)syncWarningPressed:(id)sender
{
    
    if(self.reachability.currentReachabilityStatus == NotReachable){
        
        [[[UIAlertView alloc] initWithTitle:[String key:@"CONNECTION_WARNING_TITLE"] message:[String key:@"CONNECTION_WARNING_NO_INTERNET_CONNECTION"] delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
        
    }else{
    
        KnCAlertView *alert = [[KnCAlertView alloc]initWithTitle:[String key:@"CONNECTION_WARNING_TITLE"] message:[String key:@"CONNECTION_WARNING_MESSAGE"] delegate:self cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"RETRY"], nil];
        alert.delegate = self;
        alert.block = ^{
            [self reconnect];
        };
        [alert show];
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([alertView isKindOfClass:[KnCAlertView class]] && buttonIndex == 1){
        ((KnCAlertView*)alertView).block();
    }
}


-(void)balanceWasUpdated
{
    
    uint64_t balance = [[[BRWalletManager sharedInstance]wallet]balance];
    
    if(self.oldBalance > 0 && balance > self.oldBalance){
        [self playCoinsReceivedSound];
    }
    
    self.oldBalance = balance;
    
    for(UIViewController *vc in self.pages){
        
        if([vc respondsToSelector:@selector(updateBalance)]){
            [vc performSelector:@selector(updateBalance)];
        }
        
    }
}

-(void)syncWasStarted
{
    [self addNavigationBarActivityIndicator];
    self.oldBalance = 0;
    
    for(UIViewController *vc in self.pages){
        
        if([vc respondsToSelector:@selector(syncWasStarted)]){
            [vc performSelector:@selector(syncWasStarted)];
        }
        
    }
}

-(void)syncWasFinished
{
    [self balanceWasUpdated];
    [self removeNavigationBarActivityIndicator];
    [self removeSyncWarning];
    
    for(UIViewController *vc in self.pages){
        
        if([vc respondsToSelector:@selector(syncWasFinished)]){
            [vc performSelector:@selector(syncWasFinished)];
        }
        
    }
}

-(void)syncFailed
{
    [self balanceWasUpdated];
    [self removeNavigationBarActivityIndicator];
    [self addSyncWarning];
    
    for(UIViewController *vc in self.pages){
        
        if([vc respondsToSelector:@selector(syncFailed)]){
            [vc performSelector:@selector(syncFailed)];
        }
        
    }
}

-(void)bitcoinUrlContainedInvalidAddress:(NSString*)address
{
    [[[UIAlertView alloc]initWithTitle:[String key:@"SCAN_NOT_VALID_ADDRESS"] message:address delegate:nil cancelButtonTitle:[String key:@"OK"] otherButtonTitles:nil]show];
}

-(void)handleBitcoinUrl:(NSURL*)url
{
    NSString *scheme = [url scheme];
    if([scheme isEqualToString:@"bitcoin"]){
        NSString *withoutScheme = [[url absoluteString] stringByReplacingOccurrencesOfString:@"bitcoin:" withString:@""];
        
        NSRange queryRange = [withoutScheme rangeOfString:@"?"];
        if(queryRange.location == NSNotFound){
            
            if([withoutScheme isValidBitcoinAddress]){
                [self startSendRequestForAddress:withoutScheme];
            }else{
                [self bitcoinUrlContainedInvalidAddress:withoutScheme];
            }
            
        }else{
         
            NSString *address = [withoutScheme substringToIndex:queryRange.location];
            
            BRPaymentRequest *request = [[BRPaymentRequest alloc]init];
            request.paymentAddress = address;
            
            if([address isValidBitcoinAddress]){
                [self startSendRequest:[BRPaymentRequest requestWithURL:url]];
            }else{
                [self bitcoinUrlContainedInvalidAddress:address];
            }
            
        }
        
    }
    
}


-(void)cameraPressed:(id)sender
{
    
}

-(void)showSettings:(id)sender
{
    KnCSettingsTableViewController *settings = [[KnCSettingsTableViewController alloc]init];
    settings.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:settings];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)settingsInvalidated
{
    [self balanceWasUpdated];
    for(UIViewController *vc in self.pages){
        
        if([vc respondsToSelector:@selector(settingsInvalidated)]){
            [vc performSelector:@selector(settingsInvalidated)];
        }
        
    }
}

-(void)emptyWallet
{
    int index = 0;
    for(UIViewController *vc in self.pages){
        if([vc isKindOfClass:[KnCSendViewController class]]){
            KnCSendViewController *svc = (KnCSendViewController*)vc;
            [svc emptyWallet];
            [self displayPage:index];
            return;
        }
        index++;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupPages];
    
    if(self.firstLoad){
        self.firstLoad = NO;
        [self registerObservers];
    }
}

-(void)rebuildView
{
    self.pages = nil;
    [self setupPages];
    [self displayPage:[self currentTabIndex]];
}

-(void)setupPages
{
    if(!self.pages){

        for(UIView *sub in self.scrollView.subviews){
            [sub removeFromSuperview];
        }
        
        [self.pages removeAllObjects];
        self.pages = nil;
        
        self.pages = [NSMutableArray array];
        [self.pages addObject:[[KnCSendViewController alloc]initWithParent:self]];
        [self.pages addObject:[[KnCHomeTableViewController alloc]initWithParent:self]];
        [self.pages addObject:[[KnCReceiveViewController alloc]initWithParent:self]];
        
        CGFloat contentHeight = self.scrollView.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20; //status bar
        
        int xOffset = 0;
        
        NSMutableArray *tabBarItems = [NSMutableArray array];
        
        for(int i=0; i<self.pages.count; i++){
            
            UIViewController *kncPage = [self.pages objectAtIndex:i];
            
            UIView *v = kncPage.view;
            
            CGRect frame = v.frame;
            frame.origin.x = xOffset;
            frame.size.height = contentHeight;
            v.frame = frame;
            
            [self.scrollView addSubview:v];
            
            xOffset += v.frame.size.width;
            
            NSString *imageName = @"";
            if([kncPage respondsToSelector:@selector(tabBarIcon)]){
                imageName = [kncPage performSelector:@selector(tabBarIcon)];
            }
            
            UITabBarItem *tabBarItem = [[UITabBarItem alloc]initWithTitle:kncPage.title image:[UIImage imageNamed:imageName] tag:i];
            [tabBarItems addObject:tabBarItem];
        }
        
        [self.scrollView setContentSize:CGSizeMake(xOffset, 0)];
        
        [self.tabBar setItems:tabBarItems animated:NO];
        
        [self displayPage:1 animated:NO];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int offset = self.scrollView.contentOffset.x;
    
    CGFloat diff = offset / self.scrollView.frame.size.width;
    int index = (int)diff;
    
    if(diff - index < 0.1){
        [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:index]];
        [self notifyPageDidAppear:YES];
    }
    
}

-(void)notifyPageDidAppear:(BOOL)animated
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger index = [self.tabBar.items indexOfObject:self.tabBar.selectedItem];
        UIViewController *current = [self.pages objectAtIndex:index];
        [current viewDidAppear:animated];
    });
   
}

-(void)labelWasUpdated
{
    [self settingsInvalidated];
}


-(void)displayPage:(int)index
{
    [self displayPage:index animated:YES];
}

-(void)displayPage:(int)index animated:(BOOL)animated
{
    int newOffset = self.scrollView.frame.size.width * index;
    
    [self.scrollView setContentOffset:CGPointMake(newOffset, self.scrollView.contentOffset.y) animated:animated];
    
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:index]];
    [self notifyPageDidAppear:YES];
}

-(int)currentTabIndex
{
    int offset = self.scrollView.contentOffset.x;
    
    CGFloat diff = offset / self.scrollView.frame.size.width;
    return (int)diff;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;
{
    [self displayPage:(int)item.tag];
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.syncStartedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncStartedObserver];
    if (self.syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFinishedObserver];
    if (self.syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFailedObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
