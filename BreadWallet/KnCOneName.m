
#import "KnCOneName.h"

@implementation KnCOneName

+(void)lookupUsername:(NSString*)username completionCallback:(void (^)(NSString *username, NSDictionary *response))completion errorCallback:(void (^)(NSString *username, NSError *error))error
{
    [self lookupUsername:username cachePolicy:2 completionCallback:completion errorCallback:error];
}

+(void)lookupUsernameNotUsingCache:(NSString*)username completionCallback:(void (^)(NSString *username, NSDictionary *response))completion errorCallback:(void (^)(NSString *username, NSError *error))error
{
    [self lookupUsername:username cachePolicy:0 completionCallback:completion errorCallback:error];
}

+(void)lookupUsername:(NSString*)username cachePolicy:(int)cachePolicy completionCallback:(void (^)(NSString *username, NSDictionary *response))completion errorCallback:(void (^)(NSString *username, NSError *error))error
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://onename.io/%@.json", username]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:cachePolicy timeoutInterval:ONENAME_TIMEOUT];
    
    [request setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError){

            dispatch_sync(dispatch_get_main_queue(), ^{
               
                if(connectionError){
                    
                    NSLog(@"connection error %@ %@",url,connectionError);
                    error(username, connectionError);
                    return;
                    
                }else{
                    
                    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                    int statusCode = [httpResponse statusCode];
                    
                    NSDictionary *dictionary = [httpResponse allHeaderFields];
                    NSLog(@"Header response %@",[dictionary description]);
                    
                    NSError *err = nil;
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
                    
                    if(statusCode < 200 || statusCode > 300){
                        
                        if(err){
                            error(username, err);
                            return;
                        }
                        
                        if(!err && json && [json isKindOfClass:[NSDictionary class]]){
                            NSLog(@"server response error %@",json);
                            error(username, [NSError errorWithDomain:@"" code:statusCode userInfo:json]);
                            return;
                        }
                        
                    }else{
                        
                        if(!err && json && [json isKindOfClass:[NSDictionary class]]){
                            
                            NSLog(@"response success %i %@",statusCode,json);
                            completion(username, json);
                        }
                        return;
                    }
                }
                
                error(username, [NSError errorWithDomain:@"unknown error" code:-3 userInfo:nil]);
                return;
                
                
            });
        
        
    }];
}

@end
