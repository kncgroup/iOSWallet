
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KnCContactImage : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * identifier;

@end
