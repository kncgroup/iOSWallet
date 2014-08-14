
#import "String.h"

@implementation String

+(NSString*)resource
{
    return @"Strings";
}

+(NSString*)key:(NSString*)word
{
    return NSLocalizedStringFromTable(word,[String resource],nil);
}

@end
