
#import <Foundation/Foundation.h>

@interface AddressBookContact : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *name;

-(id)initWithContact:(AddressBookContact*)contact;

@end
