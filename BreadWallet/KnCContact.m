
#import "KnCContact.h"
#import "NSManagedObject+Sugar.h"
#import "String.h"

@implementation KnCContact

@dynamic phone;
@dynamic label;
@dynamic address;
@dynamic data;
@dynamic imageIdentifier;
@dynamic source;
@dynamic status;

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
        abc.source = self.source;
        return abc;
    }
    return nil;
}

-(NSString*)displayStringSource
{
    if(self.source){
        if([self.source isEqualToString:SOURCE_DIRECTORY]){
            return [String key:@"SOURCE_DIRECTORY"];
        }else if([self.source isEqualToString:SOURCE_ONENAME]){
            return [String key:@"SOURCE_ONENAME"];
        }
    }
    
    return [String key:@"SOURCE_NO_SOURCE"];
}

-(void)setOneNameUsername:(NSString*)username
{
    [self save:username toKey:DATA_ONENAME_USERNAME];
}

-(NSString*)oneNameUsername
{
    if(self.data){
        return [self.data objectForKey:DATA_ONENAME_USERNAME];
    }
    return nil;
}

-(void)save:(NSString*)value toKey:(NSString*)key
{
    if(!self.data){
        self.data = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:self.data];
    
    [newData setObject:value forKey:key];
    
    self.data = [NSDictionary dictionaryWithDictionary:newData];
    
}

@end
