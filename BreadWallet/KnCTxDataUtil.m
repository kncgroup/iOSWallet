
#import "KnCTxDataUtil.h"
#import "NSManagedObject+Sugar.h"
@implementation KnCTxDataUtil

+(void)saveTelephoneNumber:(NSString*)telephoneNumber toTx:(NSString*)txHash
{
    [self saveValue:telephoneNumber toKey:@"telephonenumber" forTx:txHash];
}

+(NSString*)knownTelephoneNumber:(NSString*)txHash
{
    KnCTxData *txData = [self txData:txHash];
    
    if(txData.data && [txData.data objectForKey:@"telephonenumber"]){
        return [txData.data objectForKey:@"telephonenumber"];
    }
    return nil;
}

+(void)saveMessage:(NSString*)message toTx:(NSString*)txHash
{
    [self saveValue:message toKey:@"message" forTx:txHash];
}

+(void)saveLabel:(NSString*)label toTx:(NSString*)txHash
{
    [self saveValue:label toKey:@"label" forTx:txHash];
}

+(void)setHasBeenLookedUp:(NSString*)txHash
{
    [self saveValue:@"" toKey:@"lookup" forTx:txHash];
}

+(BOOL)hasBeenLookedUp:(NSString*)txHash
{
    KnCTxData *txData = [self txData:txHash];
    
    if(txData.data && [txData.data objectForKey:@"lookup"]){
        return YES;
    }
    
    return NO;
}

+(KnCTxData*)txData:(NSString*)txHash
{
    KnCTxData *txData = nil;
    NSArray *search = [KnCTxData objectsMatching:@"txHash == %@", txHash];
    if(search.count > 0){
        txData = search.firstObject;
    }else{
        txData = [KnCTxData managedObject];
        txData.txHash = txHash;
    }
    return txData;
}

+(void)saveValue:(NSString*)value toKey:(NSString*)key forTx:(NSString*)txHash
{
    KnCTxData *txData = [self txData:txHash];
    
    NSDictionary *data = txData.data;
    if(!data){
        data = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:data];
    if(value && value.length > 0){
        [newData setObject:value forKey:key];
    }else{
        [newData removeObjectForKey:key];
    }
    txData.data = [NSDictionary dictionaryWithDictionary:newData];
    
    [KnCTxData saveContext];
}


@end
