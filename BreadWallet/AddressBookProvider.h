
#import <Foundation/Foundation.h>
#import "KnCContact.h"

@interface AddressBookProvider : NSObject

+(void)lookupContacts;
+(UIImage*)imageForAddress:(NSString*)address;
+(KnCContact*)contactByAddress:(NSString*)address;
+(KnCContact*)contactByPhone:(NSString*)phone;
+(UIImage*)imageForContact:(KnCContact*)contact;
+(void)removeImageForContact:(KnCContact*)contact;
+(void)setImage:(UIImage*)image toContact:(KnCContact*)contact;
+(KnCContact*)saveContact:(NSString *)label address:(NSString *)address;
+(KnCContact*)saveContact:(NSString *)label address:(NSString *)address phone:(NSString*)phone;
+(KnCContact*)saveContact:(NSString *)label address:(NSString *)address phone:(NSString*)phone source:(NSString*)source;
+(KnCContact*)saveOneNameContact:(NSString *)label address:(NSString *)address username:(NSString*)username;
+(void)saveAddress:(NSString*)address toContact:(KnCContact*)contact;
+(void)lookup:(NSString*)address forTx:(NSString*)txHash success:(void (^)(NSDictionary *response))success errorCallback:(void (^)(NSError *error))error;
+(void)forceLookup:(NSString*)address forTx:(NSString*)txHash success:(void (^)(NSDictionary *response))success errorCallback:(void (^)(NSError *error))error;
+(void)deleteContact:(KnCContact*)contact;
+(void)checkDeletedContacts;
@end
