
#import "KnCDocument.h"

@implementation KnCDocument

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName
                   error:(NSError **)outError
{
    
    if ([contents length] > 0) {
        self.content = [[NSString alloc]
                            initWithBytes:[contents bytes]
                            length:[contents length]
                            encoding:NSUTF8StringEncoding];
    } else {
        self.content = @"";
    }
    
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    
    if ([self.content length] == 0) {
        self.content = @"";
    }
    
    return [NSData dataWithBytes:[self.content UTF8String]
                          length:[self.content length]];
    
}

@end
