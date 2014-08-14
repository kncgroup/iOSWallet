
#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImage *)imageWithImage:(UIImage *)image fit:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;
+ (UIImage *)qrImage:(NSString*)qrString;
@end
