
#import "KnCPinUtil.h"

#define PIN_KEY_CODE @"PIN_KEY_CODE_NEW"

@implementation KnCPinUtil


+(BOOL)hasPin
{
    return [[NSUserDefaults standardUserDefaults]stringForKey:PIN_KEY_CODE] != nil;
}

+(BOOL)setNewPin:(NSString*)newPin
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    if([newPin isEqualToString:@""]){
        [defs removeObjectForKey:PIN_KEY_CODE];
    }else{
        [defs setObject:newPin forKey:PIN_KEY_CODE];
    }
    return [defs synchronize];
    
}

+(BOOL)pinOk:(NSString*)enteredPin
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    NSString *oldStoredPin = [defs stringForKey:PIN_KEY_CODE];
    
    if(enteredPin && [enteredPin isEqualToString:oldStoredPin]){
        return YES;
    }
    
    return NO;
}

@end
