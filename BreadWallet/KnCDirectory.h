
#import <Foundation/Foundation.h>
#import "KnCConstants.h"

#define TIMEOUT 30

#define KEY_CLIENT_ID @"key_client_id"
#define KEY_CLIENT_SECRET @"key_client_secret"
#define KEY_PHONE @"key_phone"
#define KEY_REGISTERED @"key_registered"
#define KEY_REMOVED @"key_removed_directory"

#define GET @"GET"
#define POST @"POST"
#define PATCH @"PATCH"
#define DELETE @"DELETE"

@interface KnCDirectory : NSObject

@property (atomic, strong) NSOperationQueue *queue;

+(NSString*)telephoneNumber;

+(void)registrationRequest:(NSString*)telephoneNumber bitcoinWalletAddress:(NSString*)bitcoinWalletAddress phoneID:(NSString*)phoneID completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)requestResendCodeRequest:(NSString*)telephoneNumber completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)validateRegistrationRequest:(NSString*)authToken completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)contactsRequest:(NSArray*)contacts completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)addressPatchRequest:(NSString*)bitcoinWalletAddress completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)removeEntryRequest:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)updateTxRequest:(NSString*)counterpart note:(NSString*)note sent:(BOOL)sent txId:(NSString*)transactionId payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)submitTxRequest:(NSString*)counterpart message:(NSString*)message sent:(BOOL)sent txId:(NSString*)transactionId payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)listTransactions:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)lookupTransactions:(NSString*)txId completion:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)request:(NSString*)restPath method:(NSString*)method signed:(BOOL)signRequest payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error;

+(void)saveRegistrationRequest:(NSDictionary*)data;

+(void)setRegistered:(BOOL)registered;

+(BOOL)isRegistred;

+(void)setRemoved:(BOOL)removed;

+(BOOL)isRemoved;

@end
