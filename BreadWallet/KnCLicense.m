
#import "KnCLicense.h"

@implementation KnCLicense

-(id)initWithTitle:(NSString*)title andUrl:(NSString*)url
{
    return [self initWithTitle:title andUrl:url andLicense:nil];
}
-(id)initWithTitle:(NSString*)title andUrl:(NSString*)url andLicense:(NSString*)license
{
    self = [super init];
    if(self){
        self.title = title;
        self.url = url;
        self.license = license;
    }
    return self;
}

@end
