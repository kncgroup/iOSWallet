#import "KnCViewController+UIViewController.h"
#import "KnCColor+UIColor.h"
@implementation UIViewController (KnCViewController)

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    __block int buttonIndex = 0;
    [actionSheet.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor teal] forState:UIControlStateNormal];
            
            if(buttonIndex == [actionSheet destructiveButtonIndex]){
                [button setTitleColor:[UIColor kncRed] forState:UIControlStateNormal];
            }
            
            buttonIndex++;
        }
    }];
}

-(BOOL)isTallScreen
{
    return [[UIScreen mainScreen]bounds].size.height > 500;
}

-(UIView*)dangerousTableViewHeader:(NSString*)title
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(15, 16, 13,13)];
    [iv setTintColor:[UIColor kncRed]];
    [iv setImage:[[UIImage imageNamed:@"warning_inverted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [iv setContentMode:UIViewContentModeScaleAspectFill];
    [view addSubview:iv];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(32, 3, self.view.frame.size.width, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [label setTextColor:[UIColor sectionHeaderGray]];
    [label setText:[title uppercaseString]];
    
    [view addSubview:label];
    
    return view;
}

-(void)appendKnCLogo
{
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, self.view.frame.size.width, 25)];
    [iv setImage:[UIImage imageNamed:@"knc-logo"]];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    iv.tag = TAG_KNC_LOGO;
    [self.navigationController.navigationBar addSubview:iv];
}

-(void)setKnCLogoHidden:(BOOL)hidden
{
    UIView *logo = [self.navigationController.navigationBar viewWithTag:TAG_KNC_LOGO];
    if(logo){
        [self fadeToggle:logo hidden:hidden];
    }
}

-(void)fadeToggle:(UIView*)view hidden:(BOOL)hidden
{
    CGFloat toAlpha = hidden ? 0.0 : 1.0;
    
    if(view.alpha != toAlpha){
        __weak UIView *weakView = view;
        [UIView animateWithDuration:0.25 animations:^{
            weakView.alpha = toAlpha;
        }];
    }
}

@end
