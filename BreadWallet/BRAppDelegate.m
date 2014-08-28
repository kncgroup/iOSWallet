//
//  BRAppDelegate.m
//  BreadWallet
//
//  Created by Aaron Voisine on 5/8/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRAppDelegate.h"
#import "BRPeerManager.h"
#import "KnCMainViewController.h"
#import "KncPinViewController.h"
#import "KnCPinUtil.h"
#import <HockeySDK/HockeySDK.h>
#import "BRWalletManager.h"
#import "KnCDocument.h"
#import "String.h"
#import "KnCBackupUtil.h"
#import "KnCRestoreBackupTableViewController.h"
#import "KnCColor+UIColor.h"
#import "KnCConstants.h"
#import "AddressBookProvider.h"

#if BITCOIN_TESTNET
#warning testnet build
#endif

@interface BRAppDelegate ()

@property (nonatomic, strong) KnCBackupUtil *backupUtil;
@property (nonatomic) BOOL shouldLock;

@end

@implementation BRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if(![identifier isEqualToString:@"com.kncwallet.app"]){
        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:HOCKEYAPP_KEY];
        [[BITHockeyManager sharedHockeyManager] startManager];
        [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
        [BITHockeyManager sharedHockeyManager].debugLogEnabled = YES;
    }
    
    [self setupAppearance];
    
    // use background fetch to stay synced with the blockchain
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        NSData *file = [NSData dataWithContentsOfURL:launchOptions[UIApplicationLaunchOptionsURLKey]];

        if (file.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BRFileNotification object:nil
             userInfo:@{@"file":file}];
        }
    }
    

    //TODO: pin code

    //TODO: create a BIP and GATT specification for payment protocol over bluetooth LE
    // https://developer.bluetooth.org/gatt/Pages/default.aspx

    //TODO: bitcoin protocol/payment protocol over multipeer connectivity

    //TODO: accessibility for the visually impaired

    //TODO: internationalization

    //TODO: full screen alert dialogs with clean transitions

    //TODO: fast wallet restore using webservice

    //TODO: ask user if they need to sweep to a new wallet when restoring because it was compromised

    //TODO: detect if device is jailbroken and prompt user to wipe the wallet `if (fopen("/bin/bash", "r"))`

    //TODO: figure out deterministic builds/removing app sigs: http://www.afp548.com/2012/06/05/re-signining-ios-apps/

    //TODO: after two or three manual reconnect attempts when network is reachable, request a fresh peer list from DNS

    //TODO: implement state preservation to control things like disabling launch screenshot

    //TODO: XXXXX update openssl

    // this will notify user if bluetooth is disabled (on 4S and newer devices that support BTLE)
    //CBCentralManager *cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

    //[self centralManagerDidUpdateState:cbManager]; // Show initial state
    
    KnCMainViewController *kvc = [[KnCMainViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:kvc];
    self.window.rootViewController = nav;
    
    self.backupUtil = [[KnCBackupUtil alloc]init];
    
    self.shouldLock = YES;

    return YES;
}

-(void)setupAppearance
{
    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14]];
    
    [[UITabBar appearance] setTintColor:[UIColor teal]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor teal], NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateHighlighted];
    
    [[UIButton appearance] setTintColor:[UIColor teal]];
    [[UINavigationBar appearance] setTintColor:[UIColor teal]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor teal]];
    [[UISegmentedControl appearance] setTintColor:[UIColor teal]];
    
    UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blackColor];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]}
     forState:UIControlStateNormal];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor sectionHeaderGray]];
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    if(self.shouldLock){
        [self checkPin];
    }
    [self checkContacts];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    self.shouldLock = YES;
    [self checkPin];
}

-(void)checkPin
{
    if([KnCPinUtil hasPin]){
        UIViewController *current = [self currentViewController];
        
        BOOL isShowingEnterPin = NO;
        
        if([current isKindOfClass:[KnCPinViewController class]]){
            isShowingEnterPin = YES;
        }else if([current isKindOfClass:[UINavigationController class]]){
            UINavigationController *currentNav = (UINavigationController*)current;
            if(currentNav.viewControllers.count > 0 && [currentNav.viewControllers.firstObject isKindOfClass:[KnCPinViewController class]]){
                isShowingEnterPin = YES;
            }
        }
        
        if(!isShowingEnterPin){
            KnCPinViewController *pin = [[KnCPinViewController alloc]init];
            __weak KnCPinViewController *weakPin = pin;
            [pin setCompletionBlock:^(BOOL success) {
                if(success){
                    self.shouldLock = NO;
                    [weakPin dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
            [current presentViewController:pin animated:NO completion:nil];
        }
    }
}

-(UIViewController*)currentViewController
{
    UIViewController *root = self.window.rootViewController;
    if(root && [root isKindOfClass:[UINavigationController class]]){
        UINavigationController *nav = (UINavigationController*)root;
        UIViewController *current = [nav.viewControllers objectAtIndex:nav.viewControllers.count-1];
        
        while(current.presentedViewController){
            current = current.presentedViewController;
        }
        return current;
    }
    return self.window.rootViewController;
}

-(void)handleBitcoinUrl:(NSURL*)url
{
    UINavigationController *rootNavigationController = (UINavigationController*)self.window.rootViewController;
    
    KnCMainViewController *main = rootNavigationController.viewControllers.firstObject;
    
    UIViewController *current = [self currentViewController];
    
    while (current && current != main) {

        [current dismissViewControllerAnimated:NO completion:nil];
        current = [self currentViewController];
    }
    
    [main handleBitcoinUrl:url];
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
annotation:(id)annotation
{
    if([url.scheme isEqualToString:@"file"]){
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[KnCRestoreBackupTableViewController alloc] initWithUrl:url]];
        [[self currentViewController]presentViewController:nav animated:NO completion:nil];
        
        return YES;
        
    }else if([url.scheme isEqualToString:@"bitcoin"]){
        [self handleBitcoinUrl:url];
        return YES;
    }else if([url.scheme isEqualToString:@"kncwallet"]){
        
        NSString *replaceScheme = [[url absoluteString] stringByReplacingOccurrencesOfString:@"kncwallet:" withString:@"bitcoin:"];
        [self handleBitcoinUrl:[NSURL URLWithString:replaceScheme]];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:BRURLNotification object:nil userInfo:@{@"url":url}];
    
    return YES;
}

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    __block id syncFinishedObserver = nil, syncFailedObserver = nil;
    __block void (^completion)(UIBackgroundFetchResult) = completionHandler;
    BRPeerManager *m = [BRPeerManager sharedInstance];

    if (m.syncProgress >= 1.0) {
        if (completion) completion(UIBackgroundFetchResultNoData);
        return;
    }

    // timeout after 25 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (m.syncProgress > 0.1) {
            if (completion) completion(UIBackgroundFetchResultNewData);
        }
        else if (completion) completion(UIBackgroundFetchResultFailed);
        completion = nil;

        if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
        if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
        syncFinishedObserver = syncFailedObserver = nil;
        //TODO: XXXX disconnect
    });

    syncFinishedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            if (completion) completion(UIBackgroundFetchResultNewData);
            completion = nil;
            
            if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
            if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
            syncFinishedObserver = syncFailedObserver = nil;
        }];

    syncFailedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            if (completion) completion(UIBackgroundFetchResultFailed);
            completion = nil;

            if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
            if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
            syncFinishedObserver = syncFailedObserver = nil;
        }];
    
    [m connect];
}

-(void)iCloudBackupWordSeed:(void (^)(BOOL success, NSString * message))completion
{
    [self.backupUtil iCloudBackupWordSeed:completion];
}
-(BOOL)emailBackup:(NSString*)key delegate:(UIViewController<MFMailComposeViewControllerDelegate>*)sender
{
    return [self.backupUtil emailBackup:key delegate:sender];
}

-(void)checkContacts
{
    [AddressBookProvider lookupContacts];
}

//#pragma mark - CBCentralManagerDelegate
//
//- (void)centralManagerDidUpdateState:(CBCentralManager *)cbManager
//{
//    switch (cbManager.state) {
//        case CBCentralManagerStateResetting: NSLog(@"system BT connection momentarily lost."); break;
//        case CBCentralManagerStateUnsupported: NSLog(@"BT Low Energy not suppoerted."); break;
//        case CBCentralManagerStateUnauthorized: NSLog(@"BT Low Energy not authorized."); break;
//        case CBCentralManagerStatePoweredOff: NSLog(@"BT off."); break;
//        case CBCentralManagerStatePoweredOn: NSLog(@"BT on."); break;
//        default: NSLog(@"BT State unknown."); break;
//    }    
//}

@end
