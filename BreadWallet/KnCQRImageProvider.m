
#import "KnCQRImageProvider.h"

@interface KnCQRImageProvider()

@property (nonatomic, strong) UIImage *image;

@end

@implementation KnCQRImageProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[UIImage alloc] init];
}

- (id)initWithUIImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (id)item
{
    
    if ([self.activityType isEqualToString:UIActivityTypeAirDrop]) {
        return nil;
    }
    
    if ([self.activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
        return nil;
    }
    
    if ([self.activityType isEqualToString:UIActivityTypeMessage]) {
        return nil;
    }
        
    return self.image;
}

@end
