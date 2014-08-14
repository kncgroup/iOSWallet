
#import "UIViewController+KnC.h"

@implementation UIViewController (KnC)

-(void)appendKnCLogo
{
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, self.view.frame.size.width, 25)];
    [iv setImage:[UIImage imageNamed:@"knc-logo"]];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    [self.navigationController.navigationBar addSubview:iv];
}

@end
