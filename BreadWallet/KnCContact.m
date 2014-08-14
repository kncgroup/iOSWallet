
#import "KnCContact.h"
#import "NSManagedObject+Sugar.h"

@implementation KnCContact

@dynamic phone;
@dynamic label;
@dynamic address;
@dynamic imageIdentifier;


-(NSString*)mostRecentAddress
{
    if(self.address && [[self.address allKeys]count]>0){
        
        NSArray *sortedDates = [[self.address allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
        
        NSDate *mostRecentDate = sortedDates.firstObject;
        for(NSString *key in [self.address allKeys]){
            if([mostRecentDate isEqualToDate:[self.address objectForKey:key]]){
                return key;
            }
        }
    }
    
    if(self.address && [[self.address allKeys]count]>0){
        return [[self.address allKeys]firstObject];
    }
    return nil;
}

-(AddressBookContact*)createAddressBookContactObject
{
    NSString *address = [self mostRecentAddress];
    if(address){
        AddressBookContact *abc = [[AddressBookContact alloc]init];
        
        abc.address = address;
        abc.phone = self.phone;
        abc.name = self.label;
        return abc;
    }
    return nil;
}

@end
