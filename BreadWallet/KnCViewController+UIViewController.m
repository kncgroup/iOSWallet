#import "KnCViewController+UIViewController.h"
#import "KnCColor+UIColor.h"
@implementation UIViewController (KnCViewController)

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor teal] forState:UIControlStateNormal];
        }
    }];
}

-(BOOL)isTallScreen
{
    return [[UIScreen mainScreen]bounds].size.height > 500;
}


@end
