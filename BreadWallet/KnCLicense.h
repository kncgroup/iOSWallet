
#import <Foundation/Foundation.h>

@interface KnCLicense : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString *license;

-(id)initWithTitle:(NSString*)title andUrl:(NSString*)url;
-(id)initWithTitle:(NSString*)title andUrl:(NSString*)url andLicense:(NSString*)license;

@end
