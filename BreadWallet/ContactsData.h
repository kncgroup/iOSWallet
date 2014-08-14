
#import <Foundation/Foundation.h>

@interface ContactsData : NSObject

@property (nonatomic, strong) NSString *firstNames;
@property (nonatomic, strong) NSString *lastNames;
@property (nonatomic, strong) UIImage* image;

@property (nonatomic, strong) NSMutableArray *numbers;

@end
