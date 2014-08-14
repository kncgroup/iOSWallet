
#import "KnCDenomination.h"

@implementation KnCDenomination

-(id)initWithPrecision:(NSInteger)precision andShift:(NSInteger)shift
{
    self = [super init];
    
    if(self){
        self.name = [KnCDenomination unitForPrecision:precision andShift:shift];
        self.precision = precision;
        self.shift = shift;
    }
    
    return self;
}

-(BOOL)isEqualToDenomination:(KnCDenomination*)other
{
    return other.precision == self.precision && other.shift == self.shift;
}

+(NSString*)unitForPrecision:(NSInteger)precision andShift:(NSInteger)shift
{
    if(precision == 2 && shift == 3){
        return @"mXBT";
    }else if(precision == 0){
        return @"BIT";
    }
    return @"XBT";
}

+(NSArray*)supportedDenominations
{
    KnCDenomination *xbt8 = [[KnCDenomination alloc]initWithPrecision:8 andShift:0];
    KnCDenomination *xbt6 = [[KnCDenomination alloc]initWithPrecision:6 andShift:0];
    KnCDenomination *xbt4 = [[KnCDenomination alloc]initWithPrecision:4 andShift:0];
    KnCDenomination *mxbt = [[KnCDenomination alloc]initWithPrecision:2 andShift:3];
    KnCDenomination *bits = [[KnCDenomination alloc]initWithPrecision:0 andShift:6];
    
    return @[xbt8, xbt6, xbt4, mxbt, bits];
}

@end
