
#import "SettingsSection.h"

@implementation SettingsSection

-(id)initWithTitle:(NSString*)title
{
    return [self initWithTitle:title andRows:nil];
}

-(id)initWithTitle:(NSString*)title andRows:(NSArray*)rows
{
    self = [super init];
    if(self){
        
        self.title = title;
        if(rows){
            self.rows = [NSMutableArray arrayWithArray:rows];
        }else{
            self.rows = [NSMutableArray array];
        }
        
    }
    return self;
}

@end
