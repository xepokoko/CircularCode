//
//  RCOpenCVBridge.m
//  CameraTest
//
//  Created by 谢恩平 on 2025/1/7.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/objdetect.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <math.h>
#include <iostream>

# import "REDCodeDetect.hpp"
using namespace cv;
using namespace std;
#endif


#import "RCOpenCVBridge.h"

@implementation RCOpenCVWrapper

//MARK: - 检测圆环
- (NSArray<NSValue *> *)detectCirclesInImage:(UIImage *)image {
    // Convert UIImage to cv::Mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // Convert to grayscale
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // Apply Gaussian blur
    cv::GaussianBlur(gray, gray, cv::Size(9, 9), 2, 2);
    
    // Vector to store circles
    std::vector<cv::Vec3f> circles;
    
    // Hough Circle Transform
    cv::HoughCircles(
        gray,
        circles,
        cv::HOUGH_GRADIENT,
        1,
        gray.rows / 8,
        200,
        100,
        0,
        0
    );
    
    // Convert circles to NSArray of NSValue (wrapping CGPoint and radius)
    NSMutableArray<NSValue *> *result = [NSMutableArray array];
    for (size_t i = 0; i < circles.size(); i++) {
        cv::Vec3f circle = circles[i];
        CGPoint center = CGPointMake(circle[0], circle[1]);
        CGFloat radius = circle[2];
        [result addObject:[NSValue valueWithCGPoint:center]];
        [result addObject:@(radius)];
    }
    
    return result;
}


//MARK: - 检测边缘
- (UIImage *)getImagesEdges:(UIImage *)image {
    // Convert UIImage to cv::Mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // Convert to grayscale
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // Apply Gaussian blur
    cv::GaussianBlur(gray, gray, cv::Size(9, 9), 2, 2);
    
    // Use Canny to detect edges
    cv::Mat edges;
    cv::Canny(gray, edges, 50, 150);
    
    UIImage *result = [self convertMatToUIImage:edges];
    return result;
}

//MARK: - 获取灰度图
- (UIImage *)getGrayscaleImage:(UIImage *)image {
    // Convert UIImage to cv::Mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // Convert to grayscale
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    UIImage *result = [self convertMatToUIImage:gray];
    return result;
}

//MARK: - 获取二值图
- (UIImage *)getBineryImage:(UIImage *)image {
    // Convert UIImage to cv::Mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // Convert to grayscale
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // 转化为二值
    Mat binary;
    threshold(gray, binary, 245, 0, THRESH_TOZERO);
    
    UIImage *result = [self convertMatToUIImage:binary];
    return result;
}


//MARK: - 转换格式
- (UIImage *)convertMatToUIImage:(cv::Mat)mat {
    // Ensure the input Mat is in correct format
    if(mat.empty()) {
        return nil;
    }

    // Canny edge detection typically results in a 8UC1 Mat; we will convert it to 8UC4 for UIImage
    cv::Mat mat8UC4;
    if (mat.type() == CV_8UC1) {
        // Convert single channel grayscale to BGRA where A=255
        cv::cvtColor(mat, mat8UC4, cv::COLOR_GRAY2BGRA);
    } else if (mat.type() == CV_8UC3) {
        // Convert 3 channel BGR to BGRA
        cv::cvtColor(mat, mat8UC4, cv::COLOR_BGR2BGRA);
    } else if (mat.type() == CV_8UC4) {
        mat8UC4 = mat;
    } else {
        // If mat is other format, you may need additional handling
        return nil;
    }

    // Use UIImage conversion function from OpenCV
    UIImage *image = MatToUIImage(mat8UC4);
    return image;
}


- (NSArray<NSValue *> *)getLocationFlagPositionWith:(UIImage *)image {
    // 将UIImage转换为cv::Mat
    cv::Mat mat;
    UIImageToMat(image, mat);

    // 转为灰度图
    cv::Mat gray;
    cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    QRDetect detect;
    detect.init(gray);
    bool success = detect.localization();
    
    if (success) {
        
    }
    vector<Point2f> points = detect.localization_points;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < points.size(); i++) {
        CGPoint ocPoint = CGPointMake(points[i].x, points[i].y);
        [result addObject:[NSValue valueWithCGPoint:ocPoint]];
    }
    
    return [result copy];
}
@end
