
#import "KnCPinViewController.h"
#import "KnCColor+UIColor.h"
#import "KnCPinUtil.h"
#import "String.h"
#import "SVProgressHUD.h"

@interface KnCPinViewController ()

@property (nonatomic, strong) NSMutableString *input;
@property (nonatomic) BOOL userInteractionEnabled;

@property (nonatomic) PIN_MODE pinMode;
@property (nonatomic, strong) NSString *toBeConfirmed;

@end

@implementation KnCPinViewController

static CGFloat animationDuration = 0.25;

#define TAG_INNER 22
#define TAG_LETTERS 33

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initCancelable
{
    self = [super init];
    if(self){
        self.pinMode = PIN_CANCELABLE;
    }
    return self;
}
-(id)initConfigureMode
{
    self = [super init];
    if(self){
        
        if([KnCPinUtil hasPin]){
            self.pinMode = PIN_CURRENT;
        }else{
            self.pinMode = PIN_SET;
        }
    }
    return self;
}

-(void)updateTitleLabel
{
    if(self.pinMode == PIN_SET){
        self.titleLabel.text = [String key:@"PIN_ENTER_NEW_PIN"];
    }else if(self.pinMode == PIN_CONFIRM){
        self.titleLabel.text = [String key:@"PIN_CONFIRM_NEW_PIN"];
    }else if(self.pinMode == PIN_CURRENT){
        self.titleLabel.text = [String key:@"PIN_ENTER_CURRENT_PIN"];
    }else{
        self.titleLabel.text = [String key:@"PIN_APP_IS_LOCKED"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userInteractionEnabled = YES;
    
    self.input = [[NSMutableString alloc]init];
    
    [self setupView];
}

-(void)setupView
{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    for(UIView *view in self.view.subviews){
        view.alpha = 0;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshIndicators];
        
        [self updateTitleLabel];
        
        if(self.pinMode == PIN_DEFAULT){
            [self.cancelButton setHidden:YES];
        }
        
        [self.deleteButton setTitle:[String key:@"DELETE"] forState:UIControlStateNormal];
        [self.cancelButton setTitle:[String key:@"CANCEL"] forState:UIControlStateNormal];
        
        
        [self.titleLabel setTextColor:[UIColor blackColor]];
        [self.deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        NSArray *letters = @[@"",@"",@"ABC",@"DEF",@"GHI",@"JKL",@"MNO",@"PQRS",@"TUV",@"WXYZ",@""];
        for(UIView *view in self.view.subviews){
            
            if([view isKindOfClass:[UIButton class]]){
                if(view!=self.deleteButton && view!=self.cancelButton){
                    [self makeCircleButton:(UIButton*)view usingLetters:letters];
                }
            }
            
        }
        
        for(UIView *view in self.digitsSuperView.subviews){
            if(view != self.titleLabel){
                [self applyCircleLayerWithInnerLayer:view withBorderColor:[UIColor kncGray] andInnerColor:[UIColor whiteColor] animated:NO];
            }
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            for(UIView *view in self.view.subviews){
                view.alpha = 1;
            }
        }];
        
    });
    
    
}

-(void)makeCircleButton:(UIButton*)button usingLetters:(NSArray*)letters
{
    [self makeCircleButton:button letters:letters border:[UIColor kncGray] inner:[UIColor whiteColor] fontColor:[UIColor teal] letterColor:[UIColor darkGrayColor] animated:YES];
}
-(void)makeCircleButton:(UIButton*)button letters:(NSArray*)letters border:(UIColor*)borderColor inner:(UIColor*)innerColor fontColor:(UIColor*)fontColor letterColor:(UIColor*)letterColor animated:(BOOL)animated
{
 
    [self applyCircleLayerWithInnerLayer:button withBorderColor:borderColor andInnerColor:innerColor animated:animated];
    
    [button setTitleColor:fontColor forState:UIControlStateNormal];
    [button setTitleColor:fontColor forState:UIControlStateHighlighted];
    
    [button setShowsTouchWhenHighlighted:NO];
    
    UILabel *abc = (UILabel*)[button viewWithTag:TAG_LETTERS];
    
    if(!abc){
        abc = [[UILabel alloc]initWithFrame:CGRectMake(0, 46, button.frame.size.width, 13)];
        abc.tag = TAG_LETTERS;
        [abc setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:9.0f]];
        [abc setUserInteractionEnabled:NO];

        [abc setTextAlignment:NSTextAlignmentCenter];
        [button addSubview:abc];
        
        if(letters){
            NSString *string = letters[button.tag];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 2.0f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            [abc setAttributedText:attributedString];
        }
       
    }
    abc.alpha = 1.0f;
    [abc setTextColor:letterColor];    
}

-(void)applyCircleLayerWithInnerLayer:(UIView*)view withBorderColor:(UIColor*)borderColor andInnerColor:(UIColor*)innerColor animated:(BOOL)animated
{
 
    UIView *inner = [view viewWithTag:TAG_INNER];
    if(!inner){
        inner = [[UIView alloc]initWithFrame:CGRectMake(1, 1, view.frame.size.width-2, view.frame.size.height-2)];
        inner.userInteractionEnabled = NO;
        inner.tag = TAG_INNER;
        [view addSubview:inner];
        [view sendSubviewToBack:inner];
    }

    if(animated){
        [UIView animateWithDuration:0.25 animations:^{
            [self applyCircleLayer:view withColor:borderColor];
            [self applyCircleLayer:inner withColor:innerColor];
        }];
    }else{
        [self applyCircleLayer:view withColor:borderColor];
        [self applyCircleLayer:inner withColor:innerColor];
    }

}

-(void)applyCircleLayer:(UIView*)view withColor:(UIColor*)color
{
    [view setBackgroundColor:color];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(view.bounds, nil);
    maskLayer.bounds = view.bounds;
    [maskLayer setPath:maskPath];
    [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
    maskLayer.position = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    
    [view.layer setMask:maskLayer];
}

-(void)restartSetPin
{
 
    [self.input setString:@""];
    
    
    [self shake:self.digitsSuperView count:3 doneCallback:^{
        
        [UIView animateWithDuration:animationDuration animations:^{
            
            self.digitsSuperView.center = CGPointMake(self.digitsSuperView.frame.size.width*2, self.digitsSuperView.center.y);
            
        } completion:^(BOOL finished) {
            
            self.digitsSuperView.center = CGPointMake(-self.digitsSuperView.frame.size.width, self.digitsSuperView.center.y);
            [self refreshIndicators];
            self.pinMode = PIN_SET;
            [self updateTitleLabel];
            
            [UIView animateWithDuration:animationDuration animations:^{
                
                self.digitsSuperView.center = CGPointMake(self.view.center.x, self.digitsSuperView.center.y);
                
            } completion:^(BOOL finished) {
                
                self.userInteractionEnabled = YES;
                
            }];
            
        }];
        
    }];
    
    
   
}

-(IBAction)deleteCancelButtonPressed:(id)sender
{
    if(!self.userInteractionEnabled){
        return;
    }
    
    if(sender == self.deleteButton){
        if(self.input.length>0){
            
            NSString *removeLastDigit = [self.input substringToIndex:self.input.length-1];
            [self.input setString:removeLastDigit];
            [self refreshIndicators];
        }
    }else if(sender == self.cancelButton){
        [self dismiss:NO];
    }
}

-(void)validatePin
{
    
    BOOL ok = NO;
    
    if(self.pinMode == PIN_CURRENT){
        
        if([KnCPinUtil pinOk:self.input]){
            [self proceedToSetPin];
        }else{
            [self.input setString:@""];
            [self refreshIndicators];
            
            self.userInteractionEnabled = NO;
            [self shake:self.digitsSuperView count:3 doneCallback:^{
                self.userInteractionEnabled = YES;
            }];
            
            
        }
        
    }else if(self.pinMode == PIN_SET){

        self.toBeConfirmed = [NSString stringWithString:self.input];
        
        [self proceedToConfirmPin];
        
    }else if(self.pinMode == PIN_CONFIRM){
        
        ok = [self.input isEqualToString:self.toBeConfirmed];
        
        if(ok){
            
            [KnCPinUtil setNewPin:self.input];
            
            [SVProgressHUD showSuccessWithStatus:[String key:@"PIN_SET_SUCCESS"]];
            
            [self dismiss:YES];
        }else{
            [self restartSetPin];
        }
        
    }else{

        if([KnCPinUtil pinOk:self.input]){
            
            [self dismiss:YES];
            
        }else{
            
            [self.input setString:@""];
            [self refreshIndicators];
             self.userInteractionEnabled = NO;
            [self shake:self.digitsSuperView count:3 doneCallback:^{
                 self.userInteractionEnabled = YES;
            }];
            
           
            
        }
        
    }
    
    
}

-(void)dismiss:(BOOL)ok
{
    if(self.completionBlock){
        self.completionBlock(ok);
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)proceedToSetPin
{
    [self proceedToMode:PIN_SET];
}

-(void)proceedToConfirmPin
{
    [self proceedToMode:PIN_CONFIRM];
}
-(void)proceedToMode:(PIN_MODE)pinMode
{
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:animationDuration animations:^{
        self.digitsSuperView.center = CGPointMake(-self.digitsSuperView.frame.size.width*2, self.digitsSuperView.center.y);
    } completion:^(BOOL finished) {
        
        self.digitsSuperView.center = CGPointMake(self.digitsSuperView.frame.size.width*2, self.digitsSuperView.center.y);
        self.pinMode = pinMode;
        [self.input setString:@""];
        [self refreshIndicators];
        [self updateTitleLabel];
        
        [UIView animateWithDuration:animationDuration animations:^{
            self.digitsSuperView.center = CGPointMake(self.view.center.x, self.digitsSuperView.center.y);
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
        
    }];
    
    
}

-(void)shake:(UIView*)viewa count:(int)count doneCallback:(void (^)(void))callback;
{

    if(count < 1){
        if(callback){
            callback();
        }
        return;
    }
    
    CGFloat duration = 0.1;
    int diff = 20;
    
    __weak KnCPinViewController* weakSelf = self;
    __weak UIView *weakView = viewa;
    
    int y = weakView.center.y;
    int x = weakView.center.x;
    
    [UIView animateWithDuration:duration/2 animations:^{
        
        weakView.center = CGPointMake(x - diff, y);
        
    } completion:^(BOOL finished) {
       
        [UIView animateWithDuration:duration animations:^{
            weakView.center = CGPointMake(x + diff*2, y);
        } completion:^(BOOL finished) {
            
            weakView.center = CGPointMake(x, y);
            [weakSelf shake:weakView count:count-1 doneCallback:callback];
        }];
        
    }];
}

-(void)refreshIndicators
{
    
    switch (self.input.length) {
        case 1:
            [self setIndicator:self.digit0 active:YES];
            [self setIndicator:self.digit1 active:NO];
            [self setIndicator:self.digit2 active:NO];
            [self setIndicator:self.digit3 active:NO];
            break;
        case 2:
            [self setIndicator:self.digit0 active:YES];
            [self setIndicator:self.digit1 active:YES];
            [self setIndicator:self.digit2 active:NO];
            [self setIndicator:self.digit3 active:NO];
            break;
        case 3:
            [self setIndicator:self.digit0 active:YES];
            [self setIndicator:self.digit1 active:YES];
            [self setIndicator:self.digit2 active:YES];
            [self setIndicator:self.digit3 active:NO];
            break;
        case 4:
            [self setIndicator:self.digit0 active:YES];
            [self setIndicator:self.digit1 active:YES];
            [self setIndicator:self.digit2 active:YES];
            [self setIndicator:self.digit3 active:YES];
            break;
        default:
            [self setIndicator:self.digit0 active:NO];
            [self setIndicator:self.digit1 active:NO];
            [self setIndicator:self.digit2 active:NO];
            [self setIndicator:self.digit3 active:NO];
            
            break;
    }
    
    [self.deleteButton setUserInteractionEnabled: self.input.length > 0] ;
    
}

-(void)setIndicator:(UIView*)indicator active:(BOOL)active
{
    if(active){
         [self applyCircleLayerWithInnerLayer:indicator withBorderColor:[UIColor teal] andInnerColor:[UIColor whiteColor] animated:NO];
    }else{
        [self applyCircleLayerWithInnerLayer:indicator withBorderColor:[UIColor kncGray] andInnerColor:[UIColor whiteColor] animated:NO];

    }
}

-(void)appendDigit:(int)digit
{
    
    [self.input appendFormat:@"%i",digit];
    [self refreshIndicators];
    
    if(self.input.length > 3){
        self.userInteractionEnabled = NO;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self validatePin];
        });

    }
}

-(IBAction)pinButtonTouchUpOutside:(UIButton*)sender
{
    [self makeCircleButton:sender usingLetters:nil];
}

-(IBAction)pinButtonDown:(UIButton *)sender
{
    if(self.userInteractionEnabled){
        [self makeCircleButton:sender letters:nil border:[UIColor kncGray] inner:[UIColor kncGray] fontColor:[UIColor whiteColor] letterColor:[UIColor whiteColor] animated:NO];
    }
    
    sender.titleLabel.alpha = 1.0;
}

-(IBAction)pinButtonPressed:(UIButton*)sender
{
    if(self.userInteractionEnabled){
        [self appendDigit:sender.tag];
        [self makeCircleButton:sender usingLetters:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
