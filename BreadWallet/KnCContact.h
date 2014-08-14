
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AddressBookContact.h"

@interface KnCContact : NSManagedObject

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) id address;
@property (nonatomic, retain) NSString * imageIdentifier;

-(NSString*)mostRecentAddress;

-(AddressBookContact*)createAddressBookContactObject;
@end
