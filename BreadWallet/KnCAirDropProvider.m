
#import "KnCAirDropProvider.h"

@interface KnCAirDropProvider()

@property (nonatomic, strong) NSString *address;

@end

@implementation KnCAirDropProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[NSURL alloc] init];
}

- (id)initWithAddress:(NSString*)address
{
    self = [super init];
    if (self) {
        self.address = address;
    }
    return self;
}

- (id)item
{
    
    if ([self.activityType isEqualToString:UIActivityTypeAirDrop]) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"kncwallet:%@", self.address]];
    }
    
    return nil;
}

@end
