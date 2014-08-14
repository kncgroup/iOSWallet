
#import "KnCProgressView.h"
#import "KnCColor+UIColor.h"

@interface KnCProgressView ()

@property UIView *viewA;
@property UIView *viewB;

@end

@implementation KnCProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    [self setBackgroundColor:[UIColor clearColor]];

    self.viewB = [[UIView alloc]initWithFrame:CGRectMake(-self.frame.size.width, 0, self.frame.size.width-8, self.frame.size.height)];
    [self addSubview:self.viewB];
    
    self.viewA = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.viewA];
    
    [self assignLine:self.viewA];
    [self assignLine:self.viewB];
    
    [self animateCallback];
}

-(void)assignLine:(UIView*)view
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:self.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor teal] CGColor]];
    [shapeLayer setLineWidth:self.frame.size.height];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:39],
      [NSNumber numberWithInt:8],nil]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, view.frame.size.width, 0);
    
    [shapeLayer setPath:path];
    
    [[view layer] addSublayer:shapeLayer];
    
}

-(void)animateCallback
{
    if(self.viewA.frame.origin.x > self.frame.size.width){
        [self setOrigin:CGPointMake(0, 0) toView:self.viewA];
        [self setOrigin:CGPointMake(-self.frame.size.width, 0) toView:self.viewB];
    }
    
    CGPoint a = self.viewA.frame.origin;
    CGPoint b = self.viewB.frame.origin;
    
    a.x+=5;
    b.x+=5;
    
    [UIView animateWithDuration:0.025 animations:^{
        [self setOrigin:a toView:self.viewA];
        [self setOrigin:b toView:self.viewB];
    } completion:^(BOOL finished) {
        [self animateCallback];
    }];
    
}

-(void)setOrigin:(CGPoint)origin toView:(UIView*)view
{
    CGRect frame = view.frame;
    frame.origin = origin;
    view.frame = frame;
}

-(void)animate:(CAShapeLayer*)shapeLayer
{
    
    // Setup the path
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
