
#import <Foundation/Foundation.h>

#define TAG_KNC_LOGO 999

@interface UIViewController (KnCViewController)

-(BOOL)isTallScreen;
-(UIView*)dangerousTableViewHeader:(NSString*)title;
-(void)appendKnCLogo;
-(void)setKnCLogoHidden:(BOOL)hidden;
-(void)fadeToggle:(UIView*)view hidden:(BOOL)hidden;
@end
