
#import <Foundation/Foundation.h>

@interface SettingsSection : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *rows;

-(id)initWithTitle:(NSString*)title;
-(id)initWithTitle:(NSString*)title andRows:(NSArray*)rows;

@end
