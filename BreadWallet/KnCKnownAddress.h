
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class KnCContact;

@interface KnCKnownAddress : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) KnCContact *contact;

@end
