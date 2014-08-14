
#import <Foundation/Foundation.h>
#import "KnCTxData.h"
@interface KnCTxDataUtil : NSObject

+(void)saveMessage:(NSString*)message toTx:(NSString*)txHash;
+(void)saveLabel:(NSString*)label toTx:(NSString*)txHash;
+(KnCTxData*)txData:(NSString*)txHash;
+(BOOL)hasBeenLookedUp:(NSString*)txHash;
+(void)setHasBeenLookedUp:(NSString*)txHash;
+(void)saveTelephoneNumber:(NSString*)telephoneNumber toTx:(NSString*)txHash;
+(NSString*)knownTelephoneNumber:(NSString*)txHash;
@end
