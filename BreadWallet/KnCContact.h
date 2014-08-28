
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AddressBookContact.h"


#define SOURCE_DIRECTORY @"Directory"
#define SOURCE_ONENAME @"OneName"

#define STATUS_DELETED @"deleted"

#define DATA_ONENAME_USERNAME @"ONENAME_USERNAME"

@interface KnCContact : NSManagedObject

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) id address;
@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSString * imageIdentifier;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * status;

-(NSString*)mostRecentAddress;

-(AddressBookContact*)createAddressBookContactObject;

-(NSString*)displayStringSource;

-(NSString*)oneNameUsername;

@end
