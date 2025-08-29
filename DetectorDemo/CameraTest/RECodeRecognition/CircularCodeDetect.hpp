//
//  REDCodeDetect.hpp
//  CameraTest
//
//  Created by 谢恩平 on 2025/2/5.
//

#ifndef REDCodeDetect_hpp
#define REDCodeDetect_hpp

#include <stdio.h>
#import <opencv2/opencv.hpp>

namespace cv {

using std::vector;
using std::pair;

class QRDetect
{
public:
    void init(const Mat& src, double eps_vertical_ = 0.2, double eps_horizontal_ = 0.1);
    bool localization();
    bool computeTransformationPoints();
    Mat getBinBarcode() { return bin_barcode; }
    Mat getStraightBarcode() { return straight_barcode; }
    vector<Point2f> getTransformationPoints() { return transformation_points; }
//protected:
    vector<Vec3d> searchHorizontalLines();
    vector<Point2f> separateVerticalLines(const vector<Vec3d> &list_lines);
    vector<Point2f> extractVerticalLines(const vector<Vec3d> &list_lines, double eps);
    void fixationPoints(vector<Point2f> &local_point);
    vector<Point2f> getQuadrilateral(vector<Point2f> angle_list);
    bool testByPassRoute(vector<Point2f> hull, int start, int finish);
    
    Mat barcode, bin_barcode, resized_barcode, resized_bin_barcode, straight_barcode;
    vector<Point2f> localization_points, transformation_points;
    double eps_vertical, eps_horizontal, coeff_expansion;
    enum resize_direction { ZOOMING, SHRINKING, UNCHANGED } purpose;
};

} // namespace


#endif /* REDCodeDetect_hpp */


