
#import "AddressBookProvider.h"
#import <AddressBook/AddressBook.h>
#import "NSManagedObject+Sugar.h"
#import "ContactsData.h"
#import "KnCDirectory.h"
#import "SVProgressHUD.h"
#import "String.h"
#import "KnCKnownAddress.h"
#import "KnCContactImage.h"
#import "KnCTxDataUtil.h"

@implementation AddressBookProvider


+(void)lookupContacts
{
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeopleRef = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        
        NSArray *allPeople = CFBridgingRelease(allPeopleRef);
        
        CFIndex nPeople = allPeople.count;
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        for (int i = 0; i < allPeople.count; i++)
        {
            ContactsData *contacts = [ContactsData new];
            
            ABRecordRef person = (__bridge ABRecordRef)([allPeople objectAtIndex:i]);
            
            //get First Name and Last Name
            
            contacts.firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            contacts.lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!contacts.firstNames) {
                contacts.firstNames = @"";
            }
            if (!contacts.lastNames) {
                contacts.lastNames = @"";
            }
            
            // get contacts picture, if pic doesn't exists, show standart one
            
            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
            contacts.image = [UIImage imageWithData:imgData];
            if (!contacts.image) {
                contacts.image = [UIImage imageNamed:@"NOIMG.png"];
            }
            //get Phone Numbers
            
            NSString *callingCode = [[NSUserDefaults standardUserDefaults]stringForKey:@"COUNTRY_CALLING_CODE"];
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                
                if([phoneNumber rangeOfString:@"0"].location == 0){
                    phoneNumber = [NSString stringWithFormat:@"%@%@",callingCode,[phoneNumber substringFromIndex:1]];
                }
                
                phoneNumber = [self fixPhoneNumber:phoneNumber];
                
                [phoneNumbers addObject:phoneNumber];
                
            }
            
            
            [contacts setNumbers:phoneNumbers];
            
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
                
            }
            
            
            [items addObject:contacts];
            
#ifdef DEBUG
            NSLog(@"Person is: %@ %@", contacts.firstNames, contacts.lastNames);
            NSLog(@"Phones are: %@", contacts.numbers);
#endif
            
            
            
            
        }
        
        [self lookupContactsRemote:items];
        
    } else {
#ifdef DEBUG
        NSLog(@"Cannot fetch Contacts :( ");
#endif
    }
    
    
    
}

+(NSString*)fixPhoneNumber:(NSString*)phoneNumber
{
    return [[phoneNumber componentsSeparatedByCharactersInSet:
      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
     componentsJoinedByString:@""];
}
+(KnCContact*)saveContact:(NSString *)label address:(NSString *)address
{
    return [self saveContact:label address:address phone:nil];
}
+(KnCContact*)saveContact:(NSString *)label address:(NSString *)address phone:(NSString*)phone
{
    KnCContact *contact = [AddressBookProvider contactByAddress:address];
    if(!contact){
        contact = [KnCContact managedObject];
    }
    
    contact.label = label;
    
    if(!contact.address){
        contact.address = [NSDictionary dictionary];
    }
    
    contact.phone = phone;
    
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithDictionary:contact.address];
    if(![addresses objectForKey:address]){
        [addresses setObject:[NSDate date] forKey:address];
    }
    contact.address = [NSDictionary dictionaryWithDictionary:addresses];
    [self saveKnownAddress:address toContact:contact];
    [KnCContact saveContext];

    return contact;
}

+(KnCContact*)contactByPhone:(NSString*)phone
{
    NSArray *search = [KnCContact objectsMatching:@"phone == %@",phone];
    
    if(search && search.count > 0){
        return search.firstObject;
    }
    
    return nil;
}

+(KnCContact*)contactByAddress:(NSString*)address
{
    NSArray *search = [KnCKnownAddress objectsMatching:@"address == %@",address];
    
    KnCKnownAddress *known = search.firstObject;
    
    return known.contact;
}

+(void)setImage:(UIImage*)image toContact:(KnCContact*)contact
{
    KnCContactImage *contactImage = nil;
    if(contact.imageIdentifier){
        NSArray *search = [KnCContactImage objectsMatching:@"identifier == %@",contact.imageIdentifier];
        contactImage = search.firstObject;
    }
    
    if(!contactImage){
        contactImage = [KnCContactImage managedObject];
        NSString *UUID = [[NSUUID UUID] UUIDString];
        contactImage.identifier = UUID;
    }
    
    contactImage.image = UIImagePNGRepresentation(image);
    contact.imageIdentifier = contactImage.identifier;
    
    [KnCContactImage saveContext];
}

+(void)removeImageForContact:(KnCContact*)contact
{
    if(!contact || !contact.imageIdentifier) return;
    
    NSArray *search = [KnCContactImage objectsMatching:@"identifier == %@",contact.imageIdentifier];
    for(KnCContactImage *contactImage in search){
        [contactImage deleteObject];
    }
    contact.imageIdentifier = nil;
    [KnCContact saveContext];
}

+(UIImage*)imageForAddress:(NSString*)address
{
    KnCContact *contact = [self contactByAddress:address];
    return [self imageForContact:contact];
}

+(UIImage*)imageForContact:(KnCContact*)contact
{
    if(!contact || !contact.imageIdentifier) return nil;
    
    NSArray *search = [KnCContactImage objectsMatching:@"identifier == %@",contact.imageIdentifier];
    
    if(search.count > 0){
        KnCContactImage *contactImage = search.firstObject;
        if(contactImage.image){
            return [UIImage imageWithData:contactImage.image];
        }
    }
    return nil;
}

+(void)lookup:(NSString*)address forTx:(NSString*)txHash success:(void (^)(NSDictionary *response))success errorCallback:(void (^)(NSError *error))error
{
    BOOL shouldLookup = ![KnCTxDataUtil hasBeenLookedUp:txHash];
    
    if(!shouldLookup){
        error([NSError errorWithDomain:@"internal" code:-1 userInfo:nil]);
        return;
    }
    [self forceLookup:address forTx:txHash success:success errorCallback:error];
}

+(void)forceLookup:(NSString*)address forTx:(NSString*)txHash success:(void (^)(NSDictionary *response))success errorCallback:(void (^)(NSError *error))error
{
    
    [KnCDirectory lookupTransactions:txHash completion:^(NSDictionary *response) {
        
        NSString *clientPhone = [KnCDirectory telephoneNumber];
        
        NSString *counterPhone = nil;
        
        NSString *from = [response objectForKey:@"sentFrom"];
        NSString *to = [response objectForKey:@"sentTo"];
  
        if(from && to){
            if([clientPhone isEqualToString:from]){
                counterPhone = to;
            }else if([clientPhone isEqualToString:to]){
                counterPhone = from;
            }
            
            if(counterPhone){
                KnCContact *contact = [self contactByPhone:counterPhone];
                if(contact){
                    [self saveAddress:address toContact:contact];
                    [KnCContact saveContext];
                    
                }else{
                    [KnCTxDataUtil saveTelephoneNumber:counterPhone toTx:txHash];
                }
            }
        }
        
        NSString *message = [response objectForKey:@"message"];
        if(message){
            [KnCTxDataUtil saveMessage:message toTx:txHash];
        }
        
        [KnCTxDataUtil setHasBeenLookedUp:txHash];
        
        success(response);
        
    } errorCallback:^(NSError *err) {
        
        if(err && err.code == -2){
            [KnCTxDataUtil setHasBeenLookedUp:txHash];
        }
        
        error(err);
    }];
    
}

+(void)saveKnownAddress:(NSString*)address toContact:(KnCContact*)contact
{
    KnCKnownAddress *known = [KnCKnownAddress managedObject];
    known.address = address;
    known.contact = contact;
}

+(void)saveMatchingContacts:(NSMutableArray*)items withResponse:(NSDictionary*)response
{
    int newContacts = 0;
 
    if(response && [response objectForKey:@"data"]){
        NSArray *data = [response objectForKey:@"data"];
        if([data isKindOfClass:[NSArray class]]){
            
            for(NSDictionary *contactData in data){
                
                NSString *phone = [contactData objectForKey:@"telephoneNumber"];
                NSString *address = [contactData objectForKey:@"bitcoinWalletAddress"];
                if(phone && address){
                    ContactsData *addressBookContact = [self findContact:phone inItems:items];
                    
                    if(addressBookContact){
                        NSArray *search = [KnCContact objectsMatching:@"phone == %@",phone];

                        KnCContact *contact = nil;
                        
                        if(search.count < 1){ //new entity
                            contact = [KnCContact managedObject];
                            newContacts++;
                            contact.label = [[NSString stringWithFormat:@"%@ %@",addressBookContact.firstNames,addressBookContact.lastNames] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            contact.phone = phone;
                        }else{
                            contact = [search firstObject];
                        }
                        
                        if(addressBookContact.image && !contact.imageIdentifier){
                            
                            [AddressBookProvider setImage:addressBookContact.image  toContact:contact];
                            
                        }
                        
                        [self saveAddress:address toContact:contact];
                    }
                }
            }
            
        }
        
        
    }
        
    [KnCContact saveContext];
    
    if(newContacts>0){
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:[String key:@"CONTACTS_UPDATED_PATTERN"],newContacts]];
    }
    
}

+(void)saveAddress:(NSString*)address toContact:(KnCContact*)contact
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionary];
    
    if(contact.address){
        addresses = [NSMutableDictionary dictionaryWithDictionary:contact.address];
    }
    
    if(![addresses objectForKey:address]){
        [addresses setObject:[NSDate date] forKey:address];
        contact.address = [NSDictionary dictionaryWithDictionary:addresses];
    }
    
    [self saveKnownAddress:address toContact:contact];
}

+(ContactsData*)findContact:(NSString*)phone inItems:(NSMutableArray*)items
{
    for(ContactsData *contact in items){
        for(NSString *phoneNumber in contact.numbers){
            if(phoneNumber && [phoneNumber isEqualToString:phone]){
                return contact;
            }
        }
        
    }
    return nil;
}

+(void)lookupContactsRemote:(NSMutableArray*)items
{
    NSMutableArray *numbers = [NSMutableArray array];
    for(ContactsData *contact in items){
        
        for(NSString *phoneNumber in contact.numbers){
            [numbers addObject:[NSString stringWithString:phoneNumber]];
        }
        
    }

    [KnCDirectory contactsRequest:numbers completionCallback:^(NSDictionary *response) {
        [self saveMatchingContacts:items withResponse:response];
    } errorCallback:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:[String key:@"ERROR_DOWNLOADING_CONTACTS"]];
    }];
}

@end
