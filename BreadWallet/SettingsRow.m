
#import "SettingsRow.h"

@implementation SettingsRow

-(id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle block:(void (^)(void))block
{
    self = [super init];
    if(self){
        self.title = title;
        self.subtitle = subtitle;
        self.block = block;
        self.enabled = YES;
    }
    return self;
}

@end
