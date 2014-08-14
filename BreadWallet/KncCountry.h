
#import <Foundation/Foundation.h>

@interface KncCountry : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *isoCode;
@property (nonatomic, strong) NSString *callingCode;

-(id)initWithCountry:(KncCountry*)country;

@end
