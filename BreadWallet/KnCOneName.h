
#import <Foundation/Foundation.h>

#define ONENAME_TIMEOUT 30

@interface KnCOneName : NSObject

+(void)lookupUsername:(NSString*)username completionCallback:(void (^)(NSString *username, NSDictionary *response))completion errorCallback:(void (^)(NSString *username, NSError *error))error;
+(void)lookupUsernameNotUsingCache:(NSString*)username completionCallback:(void (^)(NSString *username, NSDictionary *response))completion errorCallback:(void (^)(NSString *username, NSError *error))error;
@end
