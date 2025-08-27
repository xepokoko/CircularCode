//
//  RCOpenCVBridge.h
//  CameraTest
//
//  Created by 谢恩平 on 2025/1/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCOpenCVWrapper : NSObject

- (NSArray<NSValue *> *)detectCirclesInImage:(UIImage *)image;
- (UIImage *)getImagesEdges:(UIImage *)image;
- (UIImage *)getGrayscaleImage:(UIImage *)image;
- (UIImage *)getBineryImage:(UIImage *)image;
- (NSArray<NSValue *> *)getLocationFlagPositionWith:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
