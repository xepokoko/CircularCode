//
//  RCOpenCVBridge.h
//  CameraTest
//
//  Created by 谢恩平 on 2025/1/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CircularCodeOpenCVWrapper : NSObject

- (NSArray<NSValue *> *)detectCirclesInImage:(UIImage *)image;
- (UIImage *)getImagesEdges:(UIImage *)image;
- (UIImage *)getGrayscaleImage:(UIImage *)image;
- (UIImage *)getBineryImage:(UIImage *)image;
- (NSArray<NSValue *> *)getLocationFlagPositionWith:(UIImage *)image;
/// 解码圆形二维码，成功返回 UTF-8 字符串，失败返回 nil
- (nullable NSString *)decodeCircularCodeWith:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
