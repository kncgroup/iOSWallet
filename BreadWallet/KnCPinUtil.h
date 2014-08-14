
#import <Foundation/Foundation.h>

@interface KnCPinUtil : NSObject

+(BOOL)hasPin;
+(BOOL)setNewPin:(NSString*)newPin;
+(BOOL)pinOk:(NSString*)enteredPin;
@end
