
#import "KnCAddressProvider.h"
#import "String.h"

@interface KnCAddressProvider()

@property (nonatomic, strong) NSString *address;

@end

@implementation KnCAddressProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[NSString alloc] init];
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
    
    if ([self.activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return [NSString stringWithFormat:[String key:@"SHARE_FACEBOOK_PATTERN"], self.address];
    }
    
    if ([self.activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return [NSString stringWithFormat:[String key:@"SHARE_TWITTER_PATTERN"], self.address];
    }
    
    if ([self.activityType isEqualToString:UIActivityTypePostToWeibo]) {
        return [NSString stringWithFormat:[String key:@"SHARE_WEIBO_PATTERN"], self.address];
    }
    
    if ([self.activityType isEqualToString:UIActivityTypeMessage]) {
        return [NSString stringWithFormat:[String key:@"SHARE_MESSAGE_PATTERN"], self.address];
    }
    
    if ([self.activityType isEqualToString:UIActivityTypeMail]) {
        return [NSString stringWithFormat:[String key:@"SHARE_MAIL_PATTERN"], self.address];
    }
    
    if ([self.activityType isEqualToString:UIActivityTypePrint]) {
        return nil;
    }
    
    if ([self.activityType isEqualToString:UIActivityTypeAirDrop]) {
        return nil;
    }
    
    if ([self.activityType isEqualToString:UIActivityTypeSaveToCameraRoll]) {
        return nil;
    }
    
    return self.address;
}

@end
