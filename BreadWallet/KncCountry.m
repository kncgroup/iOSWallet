
#import "KncCountry.h"

@implementation KncCountry

-(id)initWithCountry:(KncCountry*)country
{
    self = [super init];
    if(self){
        if(country){
            if(country.callingCode){
                self.callingCode = [NSString stringWithString:country.callingCode];
            }
            if(country.displayName){
                self.displayName = [NSString stringWithString:country.displayName];
            }
            if(country.isoCode){
                self.isoCode = [NSString stringWithString:country.isoCode];
            }
                
        }
    }
    return self;
}

@end
