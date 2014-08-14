
#import "CurrencyUtil.h"
#import "BRWalletManager.h"
#define KEY_BTC_PRECISION @"KEY_BTC_PRECISION"
#define KEY_BTC_SHIFT @"KEY_BTC_SHIFT"
#define KEY_USER_DENOMINATION @"KEY_USER_DENOMINATION"

@implementation CurrencyUtil

+(KnCDenomination*)denomination
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSInteger precision = [defs integerForKey:KEY_BTC_PRECISION];
    NSInteger shift = [defs integerForKey:KEY_BTC_SHIFT];
    if(![defs boolForKey:KEY_USER_DENOMINATION]){
        precision = 0;
        shift = 6;
    }
    
    return [[KnCDenomination alloc]initWithPrecision:precision andShift:shift];
}

+(void)setDenomination:(KnCDenomination*)denomination
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setInteger:denomination.precision forKey:KEY_BTC_PRECISION];
    [defs setInteger:denomination.shift forKey:KEY_BTC_SHIFT];
    [defs setBool:YES forKey:KEY_USER_DENOMINATION];
    [defs synchronize];
}

+ (NSString *)stringForBtcAmount:(int64_t)amount
{
    return [self stringForBtcAmount:amount withSymbol:YES];
}

+ (NSString *)stringForBtcAmount:(int64_t)btcAmount withSymbol:(BOOL)useSymbol
{
    KnCDenomination *denomination = [self denomination];
    
    NSString *formattedString = [self formatValue:btcAmount withPrecision:denomination.precision andShift:denomination.shift];
    
    if(useSymbol){
        return [NSString stringWithFormat:@"%@ %@",formattedString, denomination.name];
    }
    
    return formattedString;
}

+ (int64_t)bitsAmountForLocalAmount:(int64_t)amount
{
    if(amount == 0)return 0;
    double price = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LOCAL_CURRENCY_PRICE"];
    
    double rate = SATOSHIS / price;
    double convert = rate*amount / 100.0;
    
    return convert;
}

+ (NSString *)localCurrencyStringForAmount:(int64_t)amount
{
    return [self localCurrencyStringForAmount:amount withSymbol:YES];
}

+(int64_t)convertAmountWithDenomiationToBits:(int64_t)amount
{
    KnCDenomination *denomination = [self denomination];
    //mXBT => bits
    if(denomination.precision == 2 && denomination.shift == 3){
        return amount * 1000;
    }
    // XBT => bits
    if(denomination.shift == 0){
        return amount * 1000000;
    }
    return amount;
}

+(NSString*)localCurrencyCode
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"LOCAL_CURRENCY_CODE"];
}

+ (NSString *)localCurrencyStringForAmount:(int64_t)amount withSymbol:(BOOL)useSymbol
{
    static NSNumberFormatter *format = nil;
    
    if (! format) {
        format = [NSNumberFormatter new];
        format.lenient = YES;
        format.numberStyle = NSNumberFormatterDecimalStyle;
        format.maximumFractionDigits = 2;
        format.negativeFormat = [format.positiveFormat
                                 stringByReplacingCharactersInRange:[format.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    }
    
    if (amount == 0) return [format stringFromNumber:@(0)];
    
    NSString *symbol = [[NSUserDefaults standardUserDefaults] stringForKey:@"LOCAL_CURRENCY_SYMBOL"];
    NSString *code = [[NSUserDefaults standardUserDefaults] stringForKey:@"LOCAL_CURRENCY_CODE"];
    double price = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LOCAL_CURRENCY_PRICE"];

    if(useSymbol){
        format.currencySymbol = symbol;
        format.currencyCode = code;
    }else{
        format.currencySymbol = @"";
        format.currencyCode = @"";
    }
    
    
    
    NSString *ret = [format stringFromNumber:@(price*amount/SATOSHIS)];
    
    
    return ret;
}

+(NSNumber*)numberFromString:(NSString*)string
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

+(NSString*)formatValue:(long long)value withPrecision:(int)precision andShift:(int)shift
{
    return [self formatValue:value withPrecision:precision andShift:shift plusSign:@"" minusSign:@"-"];
}

+(NSString*)formatValue:(long long)value withPrecision:(int)precision andShift:(int)shift plusSign:(NSString*)plusSign minusSign:(NSString*)minusSign
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
    f.maximumFractionDigits = precision;
    f.minimumIntegerDigits = 1;
    f.minimumFractionDigits = 2;
    f.minusSign = minusSign;
    f.plusSign = plusSign;
    
    double ONE_BTC_INT = 100000000.0;
    double ONE_MBTC_INT = 100000;
    double ONE_UBTC_INT = 100;
    
    double coins = 0;
    
    if (shift == 0)
    {
        coins = value / ONE_BTC_INT;
    }
    else if (shift == 3)
    {
        coins = value / ONE_MBTC_INT;
    }
    else if (shift == 6)
    {
        f.minimumFractionDigits = 0;
        coins = value / ONE_UBTC_INT;
    }else{
        return nil;
    }
    
    return [f stringFromNumber:[NSDecimalNumber numberWithDouble:coins]];
}


@end