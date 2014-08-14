
#import "KnCDirectory.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URLEncoding.h"

@implementation KnCDirectory

+(BOOL)isRegistred
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:KEY_REGISTERED];
}

+(BOOL)isRemoved
{
    return [[NSUserDefaults standardUserDefaults]boolForKey:KEY_REMOVED];
}

+(NSString*)userAgent
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *versionName = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *versionCode = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"KnCWallet %@%@%@",versionName,versionCode,DIRECTORY_UA_KEY];
}

+(void)setRemoved:(BOOL)removed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:removed forKey:KEY_REMOVED];
    [defaults synchronize];
}

+(void)setRegistered:(BOOL)registered
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:registered forKey:KEY_REGISTERED];
    [defaults synchronize];
}

+(NSString*)clientId
{
    return [[NSUserDefaults standardUserDefaults]stringForKey:KEY_CLIENT_ID];
}

+(NSString*)clientSecret
{
    return [[NSUserDefaults standardUserDefaults]stringForKey:KEY_CLIENT_SECRET];
}

+(NSString*)telephoneNumber
{
    return [[NSUserDefaults standardUserDefaults]stringForKey:KEY_PHONE];
}

+(void)saveTelephoneNumber:(NSString*)telephoneNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:telephoneNumber forKey:KEY_PHONE];
    [defaults synchronize];
}

+(void)requestResendCodeRequest:(NSString*)telephoneNumber completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    [self request:[NSString stringWithFormat:@"entries/%@/authToken", telephoneNumber] method:GET signed:YES payload:nil completionCallback:completion errorCallback:error];
}

+(void)registrationRequest:(NSString*)telephoneNumber bitcoinWalletAddress:(NSString*)bitcoinWalletAddress phoneID:(NSString*)phoneID completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                             telephoneNumber,@"telephoneNumber",
                             bitcoinWalletAddress,@"bitcoinWalletAddress",
                             phoneID, @"phoneID",
                             nil];
    
    [self saveTelephoneNumber:telephoneNumber];
    
    NSDictionary *payload = [NSDictionary dictionaryWithObject:entry forKey:@"entry"];
    
    [self request:@"entries" method:POST signed:NO payload:payload completionCallback:completion errorCallback:error];
}

+(void)validateRegistrationRequest:(NSString*)authToken completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
                           authToken,@"authToken",
                           nil];
    
    NSDictionary *payload = [NSDictionary dictionaryWithObject:entry forKey:@"entry"];
    
    [self request:[NSString stringWithFormat:@"entries/%@",[self telephoneNumber]] method:PATCH signed:YES payload:payload completionCallback:completion errorCallback:error];
}

+(void)contactsRequest:(NSArray*)contacts completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    
    NSDictionary *payload = [NSDictionary dictionaryWithObject:contacts forKey:@"contacts"];
    
    [self request:[NSString stringWithFormat:@"entries/%@/contacts", [self telephoneNumber]] method:POST signed:YES payload:payload completionCallback:completion errorCallback:error];
}

+(void)addressPatchRequest:(NSString*)bitcoinWalletAddress completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    NSDictionary *entry = [NSDictionary dictionaryWithObject:bitcoinWalletAddress forKey:@"bitcoinWalletAddress"];
    NSDictionary *payload = [NSDictionary dictionaryWithObject:entry forKey:@"entry"];
    
    [self request:[NSString stringWithFormat:@"entries/%@",[self telephoneNumber]] method:PATCH signed:YES payload:payload completionCallback:completion errorCallback:error];
}

+(void)removeEntryRequest:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    [self request:[NSString stringWithFormat:@"entries/%@", [self telephoneNumber]] method:DELETE signed:YES payload:nil completionCallback:completion errorCallback:error];
}

+(void)updateTxRequest:(NSString*)counterpart note:(NSString*)note sent:(BOOL)sent txId:(NSString*)transactionId payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    [self submitTx:YES counterpart:counterpart note:note sent:sent txId:transactionId payload:payload completionCallback:completion errorCallback:error];
}

+(void)submitTxRequest:(NSString*)counterpart message:(NSString*)message sent:(BOOL)sent txId:(NSString*)transactionId payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    [self submitTx:NO counterpart:counterpart note:message sent:sent txId:transactionId payload:payload completionCallback:completion errorCallback:error];
}

+(void)submitTx:(BOOL)isUpdate counterpart:(NSString*)counterpart note:(NSString*)note sent:(BOOL)sent txId:(NSString*)transactionId payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    NSString *encodedAdditionalPayload = @"%7B%7B";
    if(payload){
        encodedAdditionalPayload = [[payload description]urlEncodeUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *transaction = nil;
    
    if(isUpdate){
        
        NSString *key = sent ? @"senderNote" : @"receiverNote";
        transaction = [NSDictionary dictionaryWithObjectsAndKeys:encodedAdditionalPayload,@"payload", note, key, nil];
        
    }else{
        
        NSString *sentFrom = nil;
        NSString *sentTo = nil;
        if(sent){
            sentFrom = [self telephoneNumber];
            sentTo = counterpart;
        }else{
            sentFrom = counterpart;
            sentTo = [self telephoneNumber];
        }
        
        transaction = [NSDictionary dictionaryWithObjectsAndKeys:[self telephoneNumber],@"sentFrom",sentTo,@"sentTo",encodedAdditionalPayload,@"payload", note, @"message", nil];
    }
    
    NSDictionary *fullPayload = [NSDictionary dictionaryWithObject:transaction forKey:@"transaction"];
    
    [self request:[NSString stringWithFormat:@"transactions/%@",transactionId] method:POST signed:YES payload:fullPayload completionCallback:completion errorCallback:error];
}

+(void)listTransactions:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    [self request:[NSString stringWithFormat:@"entries/%@/transactions", [self telephoneNumber]] method:GET signed:YES payload:nil completionCallback:completion errorCallback:error];
}

+(void)lookupTransactions:(NSString*)txId completion:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    [self request:[NSString stringWithFormat:@"transactions/%@", txId] method:GET signed:YES payload:nil completionCallback:completion errorCallback:error];
}

+(void)saveRegistrationRequest:(NSDictionary*)response{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *data = [response objectForKey:@"data"];
    if(data){

        if([data objectForKey:@"clientID"]){
            [defaults setObject:[data objectForKey:@"clientID"] forKey:KEY_CLIENT_ID];
        }
        
        if([data objectForKey:@"secret"]){
            [defaults setObject:[data objectForKey:@"secret"] forKey:KEY_CLIENT_SECRET];
        }
    }
    
    [defaults synchronize];
    
}

+(NSString*)trimWhitespace:(NSString*)string
{
    
    NSArray *chars = @[@"\n",@" "];
    for(NSString *character in chars){
        string = [string stringByReplacingOccurrencesOfString:character withString:@""];
    }
    
    return string;
}

+ (void)request:(NSString*)restPath method:(NSString*)method signed:(BOOL)signRequest payload:(NSDictionary*)payload completionCallback:(void (^)(NSDictionary *response))completion errorCallback:(void (^)(NSError *error))error
{
    
    if([self isRemoved]){
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", DIRECTORY_BASE_URL, restPath]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:TIMEOUT];
    
    [request setHTTPMethod:method];
    
    long timestamp = (long)[[NSDate date] timeIntervalSince1970];
    NSString *userAgent = [self userAgent];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:[NSString stringWithFormat:@"%li",timestamp] forHTTPHeaderField:@"X-Timestamp"];
    
    if(signRequest){
        
        NSString *clientId = [self clientId];
        NSString *secret = [self clientSecret];
        
        if(!clientId){
            error([NSError errorWithDomain:@"no client id" code:-1 userInfo:nil]);
            return;
        }
        
        if(!secret){
            error([NSError errorWithDomain:@"no secret" code:-1 userInfo:nil]);
            return;
        }
        
        NSString *serializedBody = @"";
        if(payload){
            NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil];
            NSString *s =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            serializedBody = s;
            [request setHTTPBody:data];
        }
        
        NSString *data = [NSString stringWithFormat:@"%@%@%li",url.absoluteString, serializedBody, timestamp];
        
        NSString *hmac = [self HMACWithSecret:secret string:data];

        [request setValue:clientId forHTTPHeaderField:@"X-ClientId"];
        [request setValue:hmac forHTTPHeaderField:@"X-Signature"];
    }else if(payload){
    
        NSError *bodyError = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&bodyError]];
        
        if(bodyError){
            error([NSError errorWithDomain:@"unable to serialize json body" code:-1 userInfo:payload]);
            return;
        }
    }
    
    NSString *isSigned = signRequest ? @"signed" : @"unsigned";
    
    if(payload){
        NSLog(@"perform %@ request %@ %@ %@",isSigned, url.absoluteString, method, payload);
    }else{
        NSLog(@"perform %@ request %@ %@ (no payload)",isSigned, url.absoluteString, method);
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[self queue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if(data){
                NSString *raw = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"response has data %@",raw);
            }else{
                NSLog(@"response has no data");
            }
            
            
            
            
            if(connectionError){
                
                if(data){
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    if(json && [json isKindOfClass:[NSDictionary class]] && [json objectForKey:@"error"]){
                        NSLog(@"server response error %@",json);
                        error([NSError errorWithDomain:@"bad request" code:-2 userInfo:json]);
                        return;
                    }
                }
                
                NSLog(@"connection error %@ %@",url,connectionError);
                error(connectionError);
                
            }else{
                
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                int statusCode = [httpResponse statusCode];
                
                NSDictionary *dictionary = [httpResponse allHeaderFields];
                NSLog(@"Header response %@",[dictionary description]);
                
                NSError *err = nil;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
                
              	if(statusCode < 200 || statusCode > 300){
                    
                    if(err){
                        error(err);
                        return;
                    }
                    
                    if(!err && json && [json isKindOfClass:[NSDictionary class]]){
                        NSLog(@"server response error %@",json);
                        error([NSError errorWithDomain:@"bad request" code:-2 userInfo:json]);
                    }
                    
                }else{
                    
                    if(!err && json && [json isKindOfClass:[NSDictionary class]]){
                    
                        NSLog(@"response success %i %@",statusCode,json);
                        completion(json);
                    }else{
                        NSLog(@"response success %i (no data)",statusCode);
                        completion([NSDictionary dictionary]);
                        
                    }
                    return;
                    
                }
                
            }
            
        });
        
    }];
    
}

id queue;

+(NSOperationQueue*)queue
{
    if(!queue){
        queue = [[NSOperationQueue alloc]init];
    }
    return queue;
}

+ (NSString*) HMACWithSecret:(NSString*) secret string:(NSString*)string
{
    CCHmacContext    ctx;
    const char       *key = [secret UTF8String];
    const char       *str = [string UTF8String];
    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    char             *p;
    
    CCHmacInit( &ctx, kCCHmacAlgMD5, key, strlen( key ));
    CCHmacUpdate( &ctx, str, strlen(str) );
    CCHmacFinal( &ctx, mac );
    
    p = hexmac;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
        snprintf( p, 3, "%02x", mac[ i ] );
        p += 2;
    }
    
    return [NSString stringWithUTF8String:hexmac];
}

@end
