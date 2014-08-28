
#import "KnCLicenseTableViewController.h"
#import "String.h"
#import "KnCLicenseTableViewCell.h"
#import "KnCLicense.h"
#import "KnCLicenseFileViewController.h"
#import "KnCAlertView.h"

@interface KnCLicenseTableViewController ()

@property (nonatomic, strong) NSArray *code;
@property (nonatomic, strong) NSArray *gfx;

@end

@implementation KnCLicenseTableViewController

static NSString *cellIdentifier = @"LicenseCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [String key:@"SETTINGS_LICENSE_TITLE"];
    self.code = @[
                      [[KnCLicense alloc]initWithTitle:@"breadwallet" andUrl:@"https://github.com/voisine/breadwallet" andLicense:@"LICENSE_BREADWALLET"],
                      [[KnCLicense alloc]initWithTitle:@"SVProgressHUD" andUrl:@"https://github.com/TransitApp/SVProgressHUD" andLicense:@"LICENSE_SVPROGRESSHUD"],
                      [[KnCLicense alloc]initWithTitle:@"RMPhoneFormat" andUrl:@"https://github.com/rmaddy/RMPhoneFormat" andLicense:@"LICENSE_RMPHONEFORMAT"],
                      [[KnCLicense alloc]initWithTitle:@"FBEncryptor" andUrl:@"https://github.com/dev5tec/FBEncryptor" andLicense:@"LICENSE_FBENCRYPT"],
                      [[KnCLicense alloc]initWithTitle:@"SSToolkit" andUrl:@"https://github.com/samsoffes/sstoolkit" andLicense:@"LICENSE_SSTOOLKIT"],
                      [[KnCLicense alloc]initWithTitle:@"SDWebImage" andUrl:@"https://github.com/rs/SDWebImage" andLicense:@"LICENSE_SDWEBIMAGE"]
                      ];
    
    self.gfx = @[
                 [[KnCLicense alloc]initWithTitle:@"Pixeden" andUrl:@"http://www.pixeden.com/"],
                 [[KnCLicense alloc] initWithTitle:@"Icons8" andUrl:@"http://icons8.com/"]
                 ];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCLicenseTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return [String key:@"LICENSE_TITLE_CODE"];
    }else if(section == 1){
        return [String key:@"LICENSE_TITLE_GFX"];
    }
    return nil;
}
-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0){
        return [String key:@"LICENSE_CODE_FOOTER"];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return self.code.count;
    }else if(section == 1){
        return self.gfx.count;
    }
    return 0;
}

-(KnCLicense*)license:(NSIndexPath*)indexPath
{
    if(indexPath.section == 0){
        return [self.code objectAtIndex:indexPath.row];
    }else if(indexPath.section == 1){
        return [self.gfx objectAtIndex:indexPath.row];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    KnCLicense * license = [self license:indexPath];
    
    cell.textLabel.text = license.title;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    
    cell.detailTextLabel.text = license.url;
    
    return cell;
}

-(void)askOpenUrlForLicense:(KnCLicense*)license
{
    KnCAlertView *alert = [[KnCAlertView alloc] initWithTitle:license.title message:[String key:@"OPEN_WEB_PAGE_FOR_LICENSE"] delegate:self cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"YES"], nil];
    
    [alert setBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:license.url]];
    }];
    
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1 && [alertView isKindOfClass:[KnCAlertView class]]){
        if(((KnCAlertView*)alertView).block){
            ((KnCAlertView*)alertView).block();
        }
    }
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnCLicense * license = [self license:indexPath];
    
    if(license.license){
        
        KnCLicenseFileViewController *vc = [[KnCLicenseFileViewController alloc]initWithLicense:license];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        [self askOpenUrlForLicense:license];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
