
#import "KncContactTableViewController.h"
#import "String.h"
#import "NSString+Base58.h"
#import "KnCTextFieldTableViewCell.h"
#import "ImageUtils.h"
#import "SVProgressHUD.h"
#import "KnCColor+UIColor.h"
#import "KnCImageView+UIImageView.h"

#define TAG_HEAD_IMAGE 100
#define TAG_HEAD_IMAGE_LABEL 101

#define SHEET_IMAGE 1

#define TAG_NAME 2
#define TAG_ADDRESS 3
#define TAG_PHONE 4

@interface KncContactTableViewController ()

@property (nonatomic, strong) NSString *address;

@property (nonatomic, strong) NSMutableDictionary *inputs;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSMutableArray *otherKnownAddresses;

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
        
        self.otherKnownAddresses = [NSMutableArray array];
        
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
            
            for(NSString *address in [contact.address allKeys]){
                if(![address isEqualToString:mostRecent]){
                    [self.otherKnownAddresses addObject:[NSString stringWithString:address]];
                }
            }
            
            self.isEditMode = YES;
            
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
        
        KnCContact *contact = [AddressBookProvider saveContact:inputName address:inputAddress phone:phone];
        
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
        return [String key:@"CONTACT_OLD_ADDRESSES"];
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(!self.isEditMode){
        return 3;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 3){
        return self.otherKnownAddresses.count;
    }
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
        cell.textField.delegate = self;
        [cell.textField addTarget:self
                          action:@selector(textFieldChanged:)
                forControlEvents:UIControlEventEditingChanged];
        
        cell.userInteractionEnabled = YES;
        
        return cell;
    }else if(indexPath.section == 3){
        KnCTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTextFieldIdentifierOther forIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        cell.textField.text = [self.otherKnownAddresses objectAtIndex:indexPath.row];
        [cell.textField setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0f]];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
