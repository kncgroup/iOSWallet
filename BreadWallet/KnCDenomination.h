
#import <Foundation/Foundation.h>

@interface KnCDenomination : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int precision;
@property (nonatomic) int shift;

-(id)initWithPrecision:(NSInteger)precision andShift:(NSInteger)shift;

-(BOOL)isEqualToDenomination:(KnCDenomination*)other;

+(NSArray*)supportedDenominations;
+(NSString*)unitForPrecision:(NSInteger)precision andShift:(NSInteger)shift;

@end
