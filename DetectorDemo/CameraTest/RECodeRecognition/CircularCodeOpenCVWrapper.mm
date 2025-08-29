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

# import "CircularCodeDetect.hpp"
using namespace cv;
using namespace std;
#endif


#import "CircularCodeOpenCVBridge.h"

@implementation CircularCodeOpenCVWrapper

//MARK: - 检测圆环
- (NSArray<NSValue *> *)detectCirclesInImage:(UIImage *)image {
    cv::Mat mat; UIImageToMat(image, mat);
    if (mat.empty()) {
        NSLog(@"[DetectCircles] 输入图像为空");
        return @[];
    }
    cv::Mat gray;
    if (mat.channels() == 4) { cv::cvtColor(mat, gray, cv::COLOR_BGRA2GRAY); }
    else if (mat.channels() == 3) { cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY); }
    else { gray = mat; }
    cv::GaussianBlur(gray, gray, cv::Size(9, 9), 2, 2);
    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(gray, circles, cv::HOUGH_GRADIENT, 1, gray.rows / 8, 200, 100, 0, 0);
    if (circles.empty()) {
        NSLog(@"[DetectCircles] 未检测到圆");
    } else {
        NSLog(@"[DetectCircles] 圆数量: %d", (int)circles.size());
    }
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
    cv::Mat mat; UIImageToMat(image, mat);
    if (mat.empty()) {
        NSLog(@"[Edges] 输入图像为空");
        return nil;
    }
    cv::Mat gray;
    if (mat.channels() == 4) { cv::cvtColor(mat, gray, cv::COLOR_BGRA2GRAY); }
    else if (mat.channels() == 3) { cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY); }
    else { gray = mat; }
    cv::GaussianBlur(gray, gray, cv::Size(9, 9), 2, 2);
    cv::Mat edges; cv::Canny(gray, edges, 50, 150);
    UIImage *result = [self convertMatToUIImage:edges];
    return result;
}

//MARK: - 获取灰度图
- (UIImage *)getGrayscaleImage:(UIImage *)image {
    cv::Mat mat; UIImageToMat(image, mat);
    if (mat.empty()) {
        NSLog(@"[Gray] 输入图像为空");
        return nil;
    }
    cv::Mat gray;
    if (mat.channels() == 4) { cv::cvtColor(mat, gray, cv::COLOR_BGRA2GRAY); }
    else if (mat.channels() == 3) { cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY); }
    else { gray = mat; }
    UIImage *result = [self convertMatToUIImage:gray];
    return result;
}

//MARK: - 获取二值图
- (UIImage *)getBineryImage:(UIImage *)image {
    cv::Mat mat; UIImageToMat(image, mat);
    if (mat.empty()) {
        NSLog(@"[Binary] 输入图像为空");
        return nil;
    }
    cv::Mat gray;
    if (mat.channels() == 4) { cv::cvtColor(mat, gray, cv::COLOR_BGRA2GRAY); }
    else if (mat.channels() == 3) { cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY); }
    else { gray = mat; }
    cv::Mat binary; threshold(gray, binary, 245, 255, THRESH_BINARY);
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
    cv::Mat mat; UIImageToMat(image, mat);
    if (mat.empty()) {
        NSLog(@"[Locate] 输入图像为空");
        return @[];
    }
    cv::Mat gray;
    if (mat.channels() == 4) { cv::cvtColor(mat, gray, cv::COLOR_BGRA2GRAY); }
    else if (mat.channels() == 3) { cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY); }
    else { gray = mat; }
    QRDetect detect; detect.init(gray);
    bool success = detect.localization();
    if (!success) {
        NSLog(@"[Locate] localization 失败");
    }
    vector<Point2f> points = detect.localization_points;
    if (points.size() != 3) {
        NSLog(@"[Locate] 定位点数量异常: %d", (int)points.size());
    } else {
        NSLog(@"[Locate] 三定位点: (%.1f,%.1f) (%.1f,%.1f) (%.1f,%.1f)", points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y);
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < points.size(); i++) {
        CGPoint ocPoint = CGPointMake(points[i].x, points[i].y);
        [result addObject:[NSValue valueWithCGPoint:ocPoint]];
    }
    return [result copy];
}

- (nullable NSString *)decodeCircularCodeWith:(UIImage *)image {
    cv::Mat mat; UIImageToMat(image, mat);
    if (mat.empty()) { NSLog(@"[Decode] 输入图像为空"); return nil; }
    cv::Mat gray;
    if (mat.channels() == 4) { cv::cvtColor(mat, gray, cv::COLOR_BGRA2GRAY); }
    else if (mat.channels() == 3) { cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY); }
    else { gray = mat; }

    // <对应生成码> 定位：与生成图的三个红色定位符匹配（见 ImageGenerator.drawLocationSymbol 以及 RCShapeInfo.positionOfLocatonSymbols）。
    // 使用 QRDetect.localization() 获得三定位点，并据此估计几何中心与尺度。
    QRDetect detect; detect.init(gray);
    bool localized = detect.localization();
    if (!localized) { NSLog(@"[Decode] localization 失败"); return nil; }
    vector<Point2f> loc = detect.localization_points; if (loc.size() != 3) { NSLog(@"[Decode] 定位点数量=%d != 3", (int)loc.size()); return nil; }

    auto circumcenter = [](const Point2f &A, const Point2f &B, const Point2f &C) -> Point2f {
        float a1 = B.x - A.x, b1 = B.y - A.y;
        float a2 = C.x - A.x, b2 = C.y - A.y;
        float c1 = (a1*(A.x + B.x) + b1*(A.y + B.y))*0.5f;
        float c2 = (a2*(A.x + C.x) + b2*(A.y + C.y))*0.5f;
        float d  = a1*b2 - a2*b1;
        if (fabs(d) < 1e-3f) return Point2f((A.x+B.x+C.x)/3.0f, (A.y+B.y+C.y)/3.0f);
        return Point2f((c1*b2 - c2*b1)/d, (a1*c2 - a2*c1)/d);
    };
    Point2f center = circumcenter(loc[0], loc[1], loc[2]);
    float r1 = norm(loc[0] - center), r2 = norm(loc[1] - center), r3 = norm(loc[2] - center);
    float radius = (r1 + r2 + r3) / 3.0f;
    if (!(radius > 0.f) || !isfinite(radius)) { NSLog(@"[Decode] 半径无效: %.3f", radius); return nil; }

    // <对应生成码> 基础几何：RCShapeInfo 中 lengthOfCRange = 48d（半径=24d）、中心圆直径=14d（半径=7d）、条数=36、每条最多16点。
    // 生成端的绘制起点为 7d + 1.5d（见 ImageGenerator.startDistance 计算），相邻点间距为 d。
    // 直接用定位点反推 d（像素）：|cx-x_locator| ≈ (24*sin45 - 2) * d；|cy-y_locator| 同理。
    const int numOfPointBar = 36;
    const int maxCountOfInfoDotsPerBar = 16;
    float step = 0.0f;
    float startRadius = 0.0f;
    float angleOffset = 0.0f;
    {
        float s45 = (float)M_SQRT1_2;              // sin(45°) = √2/2
        float k = 24.0f * s45 - 2.0f;              // ≈ 14.97
        vector<float> estimates;
        estimates.reserve(6);
        for (size_t i = 0; i < loc.size(); ++i) {
            estimates.push_back(fabsf(center.x - loc[i].x) / k);
            estimates.push_back(fabsf(center.y - loc[i].y) / k);
        }
        float dPixels = 0.0f; for (float v : estimates) dPixels += v; dPixels /= (float)estimates.size();
        step = dPixels;                              // d（像素）
        startRadius = (7.0f + 1.5f) * dPixels;       // 8.5d（像素）
    }
    if (!(step > 0.f) || !(startRadius > 0.f)) { NSLog(@"[Decode] 步长或起始半径无效: step=%.3f start=%.3f", step, startRadius); return nil; }

    // <对应生成码> 掩码规则：InfoDotsModel.testMask() 按 4 条为一组交替翻转整条（(i/4)%2）。解码需对采样值做相同 XOR 逆变换。
    auto maskAt = [](int barIndex, int dotIndex) { return ((barIndex / 4) % 2) == 0; };

    // <对应生成码> 采样：沿每条发射角度按 d 步距取样（见 ImageGenerator 中用 cos/sin 以 d 为步距推进 currentStartX/Y）。
    auto sampleAt = [&](float angle, int j) {
        float r = startRadius + j * step;
        Point2f p(center.x + r * cosf(angle), center.y + r * sinf(angle));
        int px = std::max(0, std::min((int)gray.cols - 1, (int)std::round(p.x)));
        int py = std::max(0, std::min((int)gray.rows - 1, (int)std::round(p.y)));
        // 3x3 平均采样，增强抗噪声与抗锯齿
        int sum = 0, cnt = 0;
        for (int dy = -1; dy <= 1; ++dy) {
            int yy = std::max(0, std::min((int)gray.rows - 1, py + dy));
            for (int dx = -1; dx <= 1; ++dx) {
                int xx = std::max(0, std::min((int)gray.cols - 1, px + dx));
                sum += gray.at<uint8_t>(yy, xx); cnt++;
            }
        }
        uint8_t v = (uint8_t)(sum / cnt);
        return v;
    };

    cv::Mat otsuBin; double otsu = cv::threshold(gray, otsuBin, 0, 255, THRESH_BINARY | THRESH_OTSU);
    NSLog(@"[Decode] Otsu阈值: %.1f center=(%.1f,%.1f) radius=%.1f step=%.2f start=%.2f", otsu, center.x, center.y, radius, step, startRadius);

    // 使用极坐标展开，将采样从 2D 转为 1D（角度×半径），便于做列向局部阈值
    float radiusEnd = startRadius + (maxCountOfInfoDotsPerBar - 1 + 0.5f) * step;
    int unwrapH = std::max(100, (int)std::round(radiusEnd));
    int unwrapW = numOfPointBar * 64; // 每条增加角分辨率
    cv::Mat unwrapped;
    cv::warpPolar(gray, unwrapped, cv::Size(unwrapW, unwrapH), center, radiusEnd, cv::WARP_POLAR_LINEAR);
    cv::Mat unwrappedBlur; cv::GaussianBlur(unwrapped, unwrappedBlur, cv::Size(5,5), 0);
    cv::Mat binImg; // 列向自适应阈值
    cv::adaptiveThreshold(unwrappedBlur, binImg, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY, 21, 5);
    auto clampCol = [&](int c){ return std::max(0, std::min(unwrapW - 1, c)); };
    auto clampRow = [&](int r){ return std::max(0, std::min(unwrapH - 1, r)); };
    auto sampleBinAt = [&](int col, int row) {
        int black = 0, white = 0;
        for (int dy = -1; dy <= 1; ++dy) {
            int rr = clampRow(row + dy);
            for (int dx = -1; dx <= 1; ++dx) {
                int cc = clampCol(col + dx);
                uint8_t v = binImg.at<uint8_t>(rr, cc);
                if (v < 128) black++; else white++;
            }
        }
        return (black > white) ? 1 : 0; // 黑=1（深色）
    };

    // <对应生成码> 采样几何自校准：几何中心/尺度估计可能有细微偏差（生成端按精确几何绘制）。
    // 在 startRadius、step、angleOffset 的小范围内网格搜索，最小化功能头两半 Hamming 距离，以获得更稳健的对齐长度与角度。
    auto computeFuncBits = [&](float startR, float stepD, float angOff) {
        vector<int> func(numOfPointBar, 0);
        for (int i = 0; i < numOfPointBar; ++i) {
            float angle = (2.0f * (float)CV_PI / (float)numOfPointBar) * (float)i + angOff;
            int j = 0; // 功能位
            // 功能位不在空位，但做防御处理
            bool isVoid = false;
            if ((i == 4 || i == 5) && j >= 10) isVoid = true;
            if ((i == 13 || i == 14 || i == 22 || i == 23 || i == 31 || i == 32) && (j >= 11 && j <= 14)) isVoid = true;
            if (isVoid) { func[i] = 0; continue; }
            float r = startR + j * stepD;
            Point2f p(center.x + r * cosf(angle), center.y + r * sinf(angle));
            int px = std::max(0, std::min((int)gray.cols - 1, (int)std::round(p.x)));
            int py = std::max(0, std::min((int)gray.rows - 1, (int)std::round(p.y)));
            int sum = 0, cnt = 0;
            for (int dy = -1; dy <= 1; ++dy) {
                int yy = std::max(0, std::min((int)gray.rows - 1, py + dy));
                for (int dx = -1; dx <= 1; ++dx) {
                    int xx = std::max(0, std::min((int)gray.cols - 1, px + dx));
                    sum += gray.at<uint8_t>(yy, xx); cnt++;
                }
            }
            uint8_t vv = (uint8_t)(sum / cnt);
            bool bit = (vv < otsu);
            bool mask = (((i / 4) % 2) == 0);
            bool recovered = bit ^ mask;
            func[i] = recovered ? 1 : 0;
        }
        return func;
    };
    auto ham = [&](const vector<int>& a, const vector<int>& b){ int n=(int)min(a.size(),b.size()); int d=0; for(int i=0;i<n;++i) if(a[i]!=b[i]) d++; return d; };
    auto minHamFor = [&](const vector<int>& func){ int best=1000; for(int rev=0; rev<=1; ++rev){ vector<int> base=func; if(rev==1) reverse(base.begin(), base.end()); for(int s=0;s<numOfPointBar;++s){ vector<int> seq(36); for(int i=0;i<36;++i) seq[i]=base[(i+s)%36]; vector<int> a(seq.begin(), seq.begin()+18), b(seq.begin()+18, seq.end()); best=min(best, ham(a,b)); }} return best; };
    int hamOrig = minHamFor(computeFuncBits(startRadius, step, 0.0f));
    float bestStart = startRadius, bestStep = step, bestAngle = 0.0f; int bestH = hamOrig;
    float startOffs[] = { -0.5f, -0.3f, 0.0f, 0.3f, 0.5f };
    float stepScale[] = { 0.90f, 0.95f, 1.0f, 1.05f, 1.10f };
    float angleOffs[] = { -0.05f, -0.03f, -0.01f, 0.0f, 0.01f, 0.03f, 0.05f };
    for (float so : startOffs) {
        for (float sc : stepScale) {
            for (float ao : angleOffs) {
                float sr = startRadius + so * step;
                float st = step * sc;
                int h = minHamFor(computeFuncBits(sr, st, ao));
                if (h < bestH) { bestH = h; bestStart = sr; bestStep = st; bestAngle = ao; }
            }
        }
    }
    if (bestH < hamOrig) {
        startRadius = bestStart; step = bestStep; angleOffset = bestAngle;
        NSLog(@"[Decode] 参数校准: minHam %d -> %d, start=%.2f step=%.2f angle=%.2f°", hamOrig, bestH, startRadius, step, angleOffset * 180.0 / (float)CV_PI);
    }

    // <对应生成码> 空点位：
    // 1) Logo 区：i==4 或 5 且 j>=10
    // 2) 定位符覆盖区：i ∈ {13,14,22,23,31,32} 且 11<=j<=14（见 InfoDotsModel.isVoidDot）
    // 功能点位置：每条 j==0（见 InfoDotsModel.isFunctionDot）。
    vector<int> barFunc(numOfPointBar, -1);
    vector<vector<bool>> barData(numOfPointBar);
    int sampledVoid = 0, sampledData = 0, sampledFunc = 0;
    for (int i = 0; i < numOfPointBar; ++i) {
        // 对应展开图的列范围
        int col0 = (int)std::round((i + angleOffset * numOfPointBar / (2.0 * (float)CV_PI)) * (unwrapW / (double)numOfPointBar));
        for (int j = 0; j < maxCountOfInfoDotsPerBar; ++j) {
            bool isVoid = false;
            if ((i == 4 || i == 5) && j >= 10) { isVoid = true; }
            if ((i == 13 || i == 14 || i == 22 || i == 23 || i == 31 || i == 32) && (j >= 11 && j <= 14)) { isVoid = true; }
            if (isVoid) { sampledVoid++; continue; }
            int row = clampRow((int)std::round(((startRadius + j * step) / radiusEnd) * (unwrapH - 1)));
            // 在列附近做小范围投票，提升角精度
            int votes = 0; int cnt = 0;
            for (int dc = -2; dc <= 2; ++dc) { votes += sampleBinAt(clampCol(col0 + dc), row); cnt++; }
            int bitVal = (votes * 2 >= cnt) ? 1 : 0; // 多数投票
            bool mask = maskAt(i, j);
            bool recovered = (bitVal != 0) ^ mask; // 逆掩码
            if (j == 0) { barFunc[i] = recovered ? 1 : 0; sampledFunc++; }
            else { barData[i].push_back(recovered); sampledData++; }
        }
        if (barFunc[i] < 0) { barFunc[i] = 0; }
    }
    NSLog(@"[Decode] 采样统计: func=%d data=%d void=%d", sampledFunc, sampledData, sampledVoid);

    // <对应生成码> 功能头结构：functionGroup = mask(2) + errorCorrectionLevel(5) + dataDotsLength(9) + reserve(2)，该 18 位重复一次合计 36 位（见 InfoDotsModel.generateFunctionDots）。
    // 我们在 shift×reverse 空间中搜索两半最相似的序列（Hamming 最小），再做两半投票纠错，随后 MSB/LSB 双解析，择优选取。
    auto toIntMSB = [](const vector<int> &bits, size_t start, size_t len) {
        int val = 0; for (size_t k = 0; k < len; ++k) { if (start + k >= bits.size()) break; val = (val << 1) | (bits[start + k] ? 1 : 0); } return val; };
    auto toIntLSB = [](const vector<int> &bits, size_t start, size_t len) {
        int val = 0; for (size_t k = 0; k < len; ++k) { if (start + k >= bits.size()) break; if (bits[start + k]) val |= (1 << (int)k); } return val; };
    auto hamming = [](const vector<int> &a, const vector<int> &b) { int n = (int)std::min(a.size(), b.size()); int d = 0; for (int i = 0; i < n; ++i) if (a[i] != b[i]) d++; return d; };

    int bestShift = -1; bool bestRev = false; int bestHam = 1000; vector<int> bestSeq;
    for (int rev = 0; rev <= 1; ++rev) {
        vector<int> base = barFunc; if (rev == 1) { std::reverse(base.begin(), base.end()); }
        for (int s = 0; s < numOfPointBar; ++s) {
            vector<int> seq(36); for (int i = 0; i < 36; ++i) seq[i] = base[(i + s) % 36];
            vector<int> a(seq.begin(), seq.begin() + 18), b(seq.begin() + 18, seq.end());
            int d = hamming(a, b); if (d < bestHam) { bestHam = d; bestShift = s; bestRev = (rev == 1); bestSeq = std::move(seq); }
        }
    }
    if (bestShift < 0) { NSLog(@"[Decode] 无法对齐功能头：没有找到候选序列"); return nil; }

    vector<int> voted(18); for (int i = 0; i < 18; ++i) { int a = bestSeq[i], b = bestSeq[i+18]; voted[i] = (a + b >= 1) ? 1 : 0; }
    bool rsvOK = (voted[16] == 1 && voted[17] == 1);

    int m1 = toIntMSB(voted, 0, 2), ec1 = toIntMSB(voted, 2, 5), len1 = toIntMSB(voted, 7, 9);
    int m2 = toIntLSB(voted, 0, 2), ec2 = toIntLSB(voted, 2, 5), len2 = toIntLSB(voted, 7, 9);
    auto okRange = [](int len){ return len > 0 && len <= 504; };
    int score1 = (okRange(len1)?1:0) + ((len1 % 8 == 0)?1:0) + (rsvOK?1:0);
    int score2 = (okRange(len2)?1:0) + ((len2 % 8 == 0)?1:0) + (rsvOK?1:0);
    NSLog(@"[Decode] 头候选: MSB(mask=%d,ec=%d,len=%d) LSB(mask=%d,ec=%d,len=%d)", m1, ec1, len1, m2, ec2, len2);

    int maskNum = -1, ecLevel = -1, dataLen = -1; bool headerMSB = true;
    if (score2 > score1 || (score2 == score1 && okRange(len2) && len2 > len1)) { maskNum = m2; ecLevel = ec2; dataLen = len2; headerMSB = false; }
    else { maskNum = m1; ecLevel = ec1; dataLen = len1; headerMSB = true; }

    int chosenShift = bestShift; bool chosenReverse = bestRev;
    NSString *reverseStr = chosenReverse ? @"YES" : @"NO"; NSString *headerStr = headerMSB ? @"MSB" : @"LSB";
    NSLog(@"[Decode] 对齐: shift=%d reverse=%@ minHam=%d mask=%d ec=%d len=%d header=%@ rsv=%d/%d", chosenShift, reverseStr, bestHam, maskNum, ecLevel, dataLen, headerStr, voted[16], voted[17]);

    // <对应生成码> 条序重排：生成端按 i 从 0..35 绘制（见 ImageGenerator），我们按选定的 shift/reverse 重排，以复原生成顺序。
    vector<vector<bool>> orderedBars(36);
    if (chosenReverse) { vector<vector<bool>> tmp = barData; std::reverse(tmp.begin(), tmp.end()); for (int i = 0; i < 36; ++i) orderedBars[i] = tmp[(i + chosenShift) % 36]; }
    else { for (int i = 0; i < 36; ++i) orderedBars[i] = barData[(i + chosenShift) % 36]; }

    // <对应生成码> 数据位顺序：updateModel 遍历条 i 与 j，从左到右、从内到外依次填充（见 InfoDotsModel.updateModel 中 traverseDotsTable 的顺序）。我们按该顺序拼接 payloadBits。
    vector<bool> payloadBits; payloadBits.reserve(504);
    for (int i = 0; i < 36; ++i) { payloadBits.insert(payloadBits.end(), orderedBars[i].begin(), orderedBars[i].end()); }

    // 打印比特序列（编码顺序）：功能位（对齐后的36位、投票纠错18位）与数据位（payloadBits）
    {
        // ordered 36 function bits（recovered）与 raw 36（pre-XOR）
        vector<int> orderedFunc(36), orderedFuncRaw(36);
        if (chosenReverse) {
            vector<int> tmp = barFunc; std::reverse(tmp.begin(), tmp.end());
            vector<int> tmpRaw = barFunc; // 先构建 raw
            for (int i = 0; i < 36; ++i) {
                int src = (i + chosenShift) % 36;
                orderedFunc[i] = tmp[src];
            }
            // 重算 raw: 直接用采样 bit（注意需重新按 shift/rev 重排）
            vector<int> raw36;
            raw36.reserve(36);
            for (int i = 0; i < 36; ++i) {
                int idx = (i + chosenShift) % 36;
                raw36.push_back(orderedBars[i].size() >= 0 ? 0 : 0); // 占位，下面重算
            }
            // 重采样功能位 raw（j==0）
            for (int i = 0; i < 36; ++i) {
                int barIdx = (chosenReverse? (35 - ((i+chosenShift)%36)) : (i+chosenShift)%36);
                int col0 = (int)std::round((barIdx + angleOffset * numOfPointBar / (2.0 * (float)CV_PI)) * (unwrapW / (double)numOfPointBar));
                int row = clampRow((int)std::round((startRadius / radiusEnd) * (unwrapH - 1)));
                int votes = 0, cnt = 0; for (int dc = -2; dc <= 2; ++dc) { votes += sampleBinAt(clampCol(col0 + dc), row); cnt++; }
                int bitRaw = (votes * 2 >= cnt) ? 1 : 0;
                orderedFuncRaw[i] = bitRaw;
            }
        } else {
            for (int i = 0; i < 36; ++i) orderedFunc[i] = barFunc[(i + chosenShift) % 36];
            for (int i = 0; i < 36; ++i) {
                int barIdx = (i+chosenShift)%36;
                int col0 = (int)std::round((barIdx + angleOffset * numOfPointBar / (2.0 * (float)CV_PI)) * (unwrapW / (double)numOfPointBar));
                int row = clampRow((int)std::round((startRadius / radiusEnd) * (unwrapH - 1)));
                int votes = 0, cnt = 0; for (int dc = -2; dc <= 2; ++dc) { votes += sampleBinAt(clampCol(col0 + dc), row); cnt++; }
                int bitRaw = (votes * 2 >= cnt) ? 1 : 0;
                orderedFuncRaw[i] = bitRaw;
            }
        }
        NSMutableString *func36 = [NSMutableString string];
        NSMutableString *func36raw = [NSMutableString string];
        for (int i = 0; i < 36; ++i) {
            [func36 appendString:(orderedFunc[i] ? @"1" : @"0")];
            [func36raw appendString:(orderedFuncRaw[i] ? @"1" : @"0")];
            if ((i+1) % 8 == 0 && i+1 < 36) { [func36 appendString:@" "]; [func36raw appendString:@" "]; }
        }
        NSMutableString *func18 = [NSMutableString string];
        for (int i = 0; i < 18; ++i) {
            [func18 appendString:(voted[i] ? @"1" : @"0")];
            if ((i+1) % 8 == 0 && i+1 < 18) [func18 appendString:@" "];
        }
        NSMutableString *dataBits = [NSMutableString string];
        for (size_t k = 0; k < payloadBits.size(); ++k) {
            [dataBits appendString:(payloadBits[k] ? @"1" : @"0")];
            if ((k+1) % 8 == 0 && k+1 < payloadBits.size()) [dataBits appendString:@" "];
        }
        NSLog(@"[Bits][FUNC][ordered36]=%@", func36);
        NSLog(@"[Bits][FUNC][raw36]=%@", func36raw);
        NSLog(@"[Bits][FUNC][voted18]=%@", func18);
        NSLog(@"[Bits][DATA][ordered]=%@", dataBits);
    }

    // <对应生成码> 字节位序：RCCoder.encodeString 以每字节 LSB-first（for i in 0..<8, 取 (byte & (1 << i))）展开；
    // 因此解码优先采用 LSB-first 组字节，若失败再尝试 MSB-first 容错，并且对长度尝试 header.len、其向下取 8 倍数以及可用位最大 8 倍数。
    vector<int> candidates; auto pushCand = [&](int L){ if (L > 0 && L <= (int)payloadBits.size()) candidates.push_back(L); };
    pushCand(dataLen); pushCand((dataLen/8)*8); pushCand(((int)payloadBits.size()/8)*8);
    sort(candidates.begin(), candidates.end()); candidates.erase(unique(candidates.begin(), candidates.end()), candidates.end());
    sort(candidates.begin(), candidates.end(), [&](int a, int b){ int as = (a % 8 == 0); int bs = (b % 8 == 0); if (as != bs) return as > bs; return abs(a - dataLen) < abs(b - dataLen); });

    auto tryDecodeWithLen = [&](int len, bool msb) -> NSString *{
        vector<bool> payload(payloadBits.begin(), payloadBits.begin() + len);
        if (!msb) {
            vector<unsigned char> bytes; bytes.reserve((payload.size() + 7) / 8);
            unsigned char acc = 0; int bpos = 0;
            for (bool b : payload) { if (b) acc |= (1u << bpos); bpos++; if (bpos == 8) { bytes.push_back(acc); acc = 0; bpos = 0; } }
            if (bpos != 0) { bytes.push_back(acc); }
            NSMutableString *hex = [NSMutableString string]; int preview = (int)std::min<size_t>(bytes.size(), 16);
            for (int i = 0; i < preview; ++i) { [hex appendFormat:@"%02X ", bytes[i]]; }
            NSLog(@"[Decode] Try LSB len=%d Bytes=%@", len, hex);
            return [[NSString alloc] initWithBytes:bytes.data() length:bytes.size() encoding:NSUTF8StringEncoding];
        } else {
            vector<unsigned char> bytesMSB; bytesMSB.reserve((payload.size() + 7) / 8);
            unsigned char acc2 = 0; int pos2 = 0;
            for (size_t idx = 0; idx < payload.size(); ++idx) { acc2 = (acc2 << 1) | (payload[idx] ? 1 : 0); pos2++; if (pos2 == 8) { bytesMSB.push_back(acc2); acc2 = 0; pos2 = 0; } }
            if (pos2 != 0) { bytesMSB.push_back(acc2 << (8 - pos2)); }
            NSMutableString *hex = [NSMutableString string]; int preview = (int)std::min<size_t>(bytesMSB.size(), 16);
            for (int i = 0; i < preview; ++i) { [hex appendFormat:@"%02X ", bytesMSB[i]]; }
            NSLog(@"[Decode] Try MSB len=%d Bytes=%@", len, hex);
            return [[NSString alloc] initWithBytes:bytesMSB.data() length:bytesMSB.size() encoding:NSUTF8StringEncoding];
        }
    };

    for (int len : candidates) {
        NSString *res = tryDecodeWithLen(len, false); if (res) { NSLog(@"[Decode] SUCCESS LSB len=%d", len); return res; }
        res = tryDecodeWithLen(len, true); if (res) { NSLog(@"[Decode] SUCCESS MSB len=%d", len); return res; }
    }

    {
        NSMutableString *candStr = [NSMutableString stringWithString:@"["]; for (size_t i = 0; i < candidates.size(); ++i) { [candStr appendFormat:@"%d", candidates[i]]; if (i + 1 < candidates.size()) [candStr appendString:@","]; } [candStr appendString:@"]"];
        NSLog(@"[Decode] 全部候选长度尝试失败，len候选=%@", candStr);
    }
    return nil;
}

@end
