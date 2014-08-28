
#import "KnCImageView+UIImageView.h"

@implementation UIImageView (KnCImageView)

-(void)applyCircleMask
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(self.bounds, nil);
    maskLayer.bounds = self.bounds;
    [maskLayer setPath:maskPath];
    [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
    maskLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    [self.layer setMask:maskLayer];
    
    CGPathRelease(maskPath);
}

-(void)clearMask
{
    [self.layer setMask:nil];
}

@end
