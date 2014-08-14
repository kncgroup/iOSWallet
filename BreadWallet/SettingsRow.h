
#import <Foundation/Foundation.h>

@interface SettingsRow : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, copy) void (^block)(void);

@property (nonatomic) BOOL enabled;

-(id)initWithTitle:(NSString*)title subtitle:(NSString*)subtitle block:(void (^)(void))block;

@end
