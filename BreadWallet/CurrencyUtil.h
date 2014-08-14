
#import <Foundation/Foundation.h>
#import "KnCDenomination.h"

@interface CurrencyUtil : NSObject

+ (NSString*)stringForBtcAmount:(int64_t)amount;
+ (NSString*)stringForBtcAmount:(int64_t)amount withSymbol:(BOOL)useSymbol;

+ (NSString*)localCurrencyStringForAmount:(int64_t)amount;
+ (NSString*)localCurrencyStringForAmount:(int64_t)amount withSymbol:(BOOL)useSymbol;

+ (int64_t)bitsAmountForLocalAmount:(int64_t)amount;

+(KnCDenomination*)denomination;
+(void)setDenomination:(KnCDenomination*)denomination;

+(NSString*)formatValue:(long long)value withPrecision:(int)precision andShift:(int)shift;
+(int64_t)convertAmountWithDenomiationToBits:(int64_t)amount;
+(NSString*)localCurrencyCode;
@end
