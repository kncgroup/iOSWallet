
#import "KncBalanceButton.h"

@implementation KncBalanceButton

- (id)init
{
    self = [super init];
    if(self){
        self.showingLocalCurrency = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
@end
