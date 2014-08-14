
#import "KnCDateUtil.h"

@implementation KnCDateUtil

+(NSString*)daySuffix:(NSDate*)date
{
 
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"d"];
    int day = [[formatter stringFromDate:date]integerValue];
    if(day == 1){
        return @"st";
    }else if(day == 2){
        return @"nd";
    }else if(day == 3){
        return @"rd";
    }
    return @"th";
}

@end
