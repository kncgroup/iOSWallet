
#import "KncContactTableViewController.h"
#import "String.h"
#import "NSString+Base58.h"
#import "KnCTextFieldTableViewCell.h"
#import "ImageUtils.h"
#import "SVProgressHUD.h"
#import "KnCColor+UIColor.h"
#import "KnCImageView+UIImageView.h"
#import "KnCViewController+UIViewController.h"

#define TAG_HEAD_IMAGE 100
#define TAG_HEAD_IMAGE_LABEL 101

#define SHEET_IMAGE 1

#define TAG_NAME 2
#define TAG_ADDRESS 3
#define TAG_PHONE 4

#define ALERT_DELETE 5

@interface KncContactTableViewController ()

@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSMutableDictionary *inputs;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *contactSource;

@property (nonatomic, strong) NSString *contactSourceDisplayString;

@property (nonatomic) BOOL isEditMode;

@end

@implementation KncContactTableViewController

static NSString *cellTextFieldIdentifier = @"TextFieldCell";
static NSString *cellTextFieldIdentifierOther = @"TextFieldCellOther";

-(id)initWithAddress:(NSString*)address
{
    self = [super init];
    if(self){
        self.address = address;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:cellTextFieldIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCTextFieldTableViewCell" bundle:nil] forCellReuseIdentifier:cellTextFieldIdentifierOther];
    [self.tableView registerNib:[UINib nibWithNibName:@"KnCSettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    
    [self setupHeader];
    
    self.isEditMode = NO;
    
    self.inputs = [NSMutableDictionary dictionary];
    
    if(self.address){
        
        [self.inputs setObject:[NSString stringWithString:self.address] forKey:[self key:TAG_ADDRESS]];
        
        KnCContact *contact = [AddressBookProvider contactByAddress:self.address];

        if(!contact){
            self.title = [String key:@"ADD_TO_ADDRESS_BOOK"];
        }else{
            [self.inputs setObject:[NSString stringWithString:contact.label] forKey:[self key:TAG_NAME]];
            
            if(contact.phone){
                [self.inputs setObject:[NSString stringWithString:contact.phone] forKey:[self key:TAG_PHONE]];
            }
            
            self.title = [String key:@"EDIT_IN_ADDRESS_BOOK"];
            
            UIImage *contactImage = [AddressBookProvider imageForContact:contact];
            if(contactImage){
                self.image = contactImage;
                [self setHeadImage:contactImage];
            }
            
            NSString *mostRecent = [contact mostRecentAddress];
            [self.inputs setObject:[NSString stringWithString:mostRecent] forKey:[self key:TAG_ADDRESS]];
            
            self.isEditMode = YES;

            self.contactSource = contact.source;
            self.contactSourceDisplayString = [contact displayStringSource];
            
        }
    }else{
        self.title = [String key:@"ADD_NEW_CONTACT"];
    }
   
}

-(BOOL)hasBackButton
{
    return self.navigationController.viewControllers.count > 1;
}

-(void)cancelEdit:(id)sender
{
    [self dismiss:sender];
}

-(void)dismiss:(id)sender
{
    if([self hasBackButton]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)setupHeader
{
    UIView *head = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    [head setClipsToBounds:YES];
    
    UIButton *button = [[UIButton alloc]initWithFrame:head.frame];
    [button addTarget:self action:@selector(headImagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [head addSubview:button];
    
    
    CGFloat imageSize = 70;

    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0,10, imageSize, imageSize)];
    iv.tag = TAG_HEAD_IMAGE;
    [iv setContentMode:UIViewContentModeScaleToFill];
    [iv setImage:[UIImage imageNamed:@"contact-inverted-big"]];
    [iv setClipsToBounds:YES];
    [iv setCenter:head.center];
    [iv applyCircleMask];
    
    [head addSubview:iv];
    
    UILabel *infoAddPhoto = [[UILabel alloc]initWithFrame:CGRectMake(0, iv.frame.origin.y+iv.frame.size.height, head.frame.size.width, 14.0f)];
    [infoAddPhoto setText:[String key:@"CONTACT_ADD_PHOTO"]];
    [infoAddPhoto setTextAlignment:NSTextAlignmentCenter];
    [infoAddPhoto setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0f]];
    [infoAddPhoto setTextColor:[UIColor teal]];
    [infoAddPhoto setUserInteractionEnabled:NO];
    [infoAddPhoto setTag:TAG_HEAD_IMAGE_LABEL];
    [button addSubview:infoAddPhoto];
    
    
    self.tableView.tableHeaderView = head;
}

-(void)headImagePressed:(id)sender
{
    NSString *destructive = nil;
    if(self.image){
        destructive = [String key:@"REMOVE"];
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:[String key:@"CONTACT_IMAGE"] delegate:self cancelButtonTitle:[String key:@"CANCEL"] destructiveButtonTitle:destructive otherButtonTitles:[String key:@"PICK_FROM_CAMERA"],
                            [String key:@"PICK_FROM_GALLERY"],nil];
    sheet.tag = SHEET_IMAGE;
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == SHEET_IMAGE){
        
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:[String key:@"PICK_FROM_GALLERY"]]){
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }else if([title isEqualToString:[String key:@"PICK_FROM_CAMERA"]]){
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }else if([title isEqualToString:[String key:@"REMOVE"]]){
            [self removeContactImage];
        }
        
    }
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if(![UIImagePickerController isSourceTypeAvailable:sourceType]){
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if(pickedImage){
        self.image = [ImageUtils scaleAndRotateImage:pickedImage];
        [self setHeadImage:self.image];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)removeContactImage
{
    if(self.address){
        self.image = nil;
        KnCContact *contact = [AddressBookProvider contactByAddress:self.address];
        [AddressBookProvider removeImageForContact:contact];
    }
    [self setHeadImage:nil];
}

-(void)setHeadImage:(UIImage*)image
{
    UIImageView *iv = (UIImageView*)[self.tableView.tableHeaderView viewWithTag:TAG_HEAD_IMAGE];
    if(iv){
        if(image){
            [iv setImage:[ImageUtils imageWithImage:image fit:iv.frame.size]];
            [iv setContentMode:UIViewContentModeCenter];
        }else{
            [iv setImage:[UIImage imageNamed:@"contact-inverted-big"]];
            [iv setContentMode:UIViewContentModeScaleToFill];
        }
    }
    
    UILabel *label = (UILabel*)[self.tableView viewWithTag:TAG_HEAD_IMAGE_LABEL];
    if(label){
        if(image){
            [label setText:[String key:@"CONTACT_CHANGE_PHOTO"]];
        }else{
            [label setText:[String key:@"CONTACT_ADD_PHOTO"]];
        }
    }
}


-(void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)save:(id)sender
{
    
    NSString *inputAddress = [self.inputs objectForKey:[self key:TAG_ADDRESS]];
    
    if(!inputAddress || ![inputAddress isValidBitcoinAddress]){
        
        [SVProgressHUD showErrorWithStatus:[String key:@"ADDRESS_BOOK_INVALID_ADDRESS"]];
        
        return;
    }
    
    NSString *inputName = [self.inputs objectForKey:[self key:TAG_NAME]];
    
    if(inputAddress && inputName){
        NSString *phone = [self.inputs objectForKey:[self key:TAG_PHONE]];
        
        KnCContact *contact = [AddressBookProvider saveContact:inputName address:inputAddress phone:phone source:self.contactSource];
        
        if(self.image){
            [AddressBookProvider setImage:self.image toContact:contact];
        }
        
        [self.delegate contactTableViewControllerDelegate:self updatedContact:contact];
    }
    [self dismiss:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)key:(int)tag
{
    return [NSString stringWithFormat:@"%i",tag];
}

-(int)tagForIndexPath:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    if(section == 0){
        return TAG_NAME;
    }else if(section == 1){
        return TAG_ADDRESS;
    }else if(section == 2){
        return TAG_PHONE;
    }
    
    return 0;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(section == 0){
        return [String key:@"NAME"];
    }else if(section == 1){
        return [String key:@"ADDRESS"];
    }else if(section == 2){
        return [String key:@"TELEPHONENUMBER"];
    }else if(section == 3){
        return [String key:@"CONTACT_SOURCE"];
    }else if(section == 4){
        return [String key:@"CONTACT_ADVANCED_ACTIONS"];
    }
    return nil;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 4){
        return [self dangerousTableViewHeader:[self tableView:tableView titleForHeaderInSection:section]];
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(!self.isEditMode){
        return 3;
    }
    
    if(self.contactSource && [self.contactSource isEqualToString:SOURCE_DIRECTORY]){
        return 4;
    }
    
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(void)textFieldChanged:(UITextField*)textField
{
    [self.inputs setObject:textField.text forKey:[self key:textField.tag]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section < 3){
        KnCTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTextFieldIdentifier forIndexPath:indexPath];
        
        cell.textField.tag = [self tagForIndexPath:indexPath];
        NSString *input = [self.inputs objectForKey:[self key:cell.textField.tag]];
        cell.textField.text = input;
        
        if(indexPath.section == 0){
            [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        }else{
            [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        }
        
        if(indexPath.section == 2){
            [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
        }else{
            [cell.textField setKeyboardType:UIKeyboardTypeAlphabet];
        }
        
        cell.textField.delegate = self;
        [cell.textField addTarget:self
                          action:@selector(textFieldChanged:)
                forControlEvents:UIControlEventEditingChanged];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = YES;
        
        return cell;
    }else if(indexPath.section == 3){
        KnCTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTextFieldIdentifierOther forIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        cell.textField.text = self.contactSourceDisplayString;
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.textField setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0f]];
        return cell;
    }else if(indexPath.section == 4){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [String key:@"CONTACT_DELETE"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = nil;
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    return cell;
}

-(void)askDelete
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String key:@"CONTACT_DELETE_CONFIRM"] message:nil delegate:self cancelButtonTitle:[String key:@"CANCEL"] otherButtonTitles:[String key:@"YES"], nil];
    alert.tag = ALERT_DELETE;
    [alert show];
}

-(void)deleteContact
{
    KnCContact *contact = [AddressBookProvider contactByAddress:self.address];
    [AddressBookProvider deleteContact:contact];
    [self.delegate contactTableViewControllerDelegate:self updatedContact:nil];
    [self dismiss:nil];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1 && alertView.tag == ALERT_DELETE){
        [self deleteContact];
    }
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 4){
        [self askDelete];
        [self.tableView reloadData];
    }
}


@end
