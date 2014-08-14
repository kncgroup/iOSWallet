
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KnCTxData : NSManagedObject

@property (nonatomic, retain) NSString * txHash;
@property (nonatomic, retain) id data;

@end
