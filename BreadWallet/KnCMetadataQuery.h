
#import <Foundation/Foundation.h>

@interface KnCMetadataQuery : NSMetadataQuery

@property (nonatomic, copy) void (^block)(NSArray *results);

@end
