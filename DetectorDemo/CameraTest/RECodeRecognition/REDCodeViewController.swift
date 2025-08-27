//
//  REDCodeViewController.swift
//  CameraTest
//
//  Created by 谢恩平 on 2025/1/7.
//

import UIKit
import Photos

class REDCodeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    lazy var selectImageBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("选择图片", for: .normal)
        return btn
    }()
    
    
    var overlayViews: [UIView] = []
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    lazy var imageContext: UIScrollView = {
        let sco = UIScrollView()
        sco.backgroundColor = .brown
        sco.delegate = self
        sco.minimumZoomScale = 0.1
        sco.maximumZoomScale = 3.0
        sco.translatesAutoresizingMaskIntoConstraints = false
        return sco
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPhotoLibraryAccess()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        selectImageBtn.addTarget(self, action: #selector(imageBtnClick), for: .touchUpInside)
        
        view.addSubview(selectImageBtn)
        view.addSubview(imageContext)
        imageContext.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            selectImageBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            selectImageBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectImageBtn.heightAnchor.constraint(equalToConstant: 40),
            selectImageBtn.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            imageContext.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageContext.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageContext.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageContext.bottomAnchor.constraint(equalTo: selectImageBtn.topAnchor, constant: -20)
        ])
        
    }
    
    @objc 
    func imageBtnClick() {
        self.presentImagePickerController()
    }

    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            
        }
    }

    private func presentImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // 图片展示
        renderTargetImage(image)
        // 去除标识
        overlayViews.forEach { view in
            view.removeFromSuperview()
        }
        overlayViews.removeAll()
        
        // 将选中的图片传递给检测方法
        self.detectCircles(in: image)
        
//        // 获取边缘图
//        let opencvWrapper = RCOpenCVWrapper()
//        let edgesView = opencvWrapper.getImagesEdges(image)
//        self.imageView.image = edgesView
        
    }
    
    private func renderTargetImage(_ image: UIImage) {
        let imagePointSize = image.size
        let imageWidthInPixels = imagePointSize.width * image.scale
        let imageHeightInPixels = imagePointSize.height * image.scale
        let newSize = CGSize(width: imageWidthInPixels, height: imageHeightInPixels)
        imageContext.contentSize = newSize
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidthInPixels, height: imageHeightInPixels)
    }

    private func detectCircles(in image: UIImage) {
        let opencvWrapper = RCOpenCVWrapper()
        let array = opencvWrapper.getLocationFlagPosition(with: image)
        signLocationFlags(array)
    }
    
    /// 标识出检测到的圆
    private func signCircles(_ detectedCircles: [NSValue]) {
        for i in stride(from: 0, to: detectedCircles.count, by: 2) {
            let centerValue = detectedCircles[i]
            let radiusValue = detectedCircles[i + 1]
            if let center = centerValue as? CGPoint, let radius = radiusValue as? CGFloat {
                print("Circle center: (\(center.x), \(center.y)), radius: \(radius)")
                createOverlay(center, radius: radius)
            }
        }
        
        func createOverlay(_ center: CGPoint, radius: CGFloat) {
            let overlayView = OverlayView(frame: imageView.bounds, center: center, radius: radius)
            self.overlayViews.append(overlayView)
            imageView.addSubview(overlayView)
        }
    }
    
    /// 标识出检测到的定位符号
    private func signLocationFlags(_ pointValues: [NSValue]) {
        for point in pointValues {
            let centerValue = point
            let radius: CGFloat = 20
            if let center = centerValue as? CGPoint {
                print("Circle center: (\(center.x), \(center.y)), radius: \(radius)")
                createOverlay(center, radius: radius)
            }
        }
        
        func createOverlay(_ center: CGPoint, radius: CGFloat) {
            let overlayView = OverlayView(frame: imageView.bounds, center: center, radius: radius)
            self.overlayViews.append(overlayView)
            imageView.addSubview(overlayView)
        }
    }
}


extension REDCodeViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

class OverlayView: UIView {
//    var centerPoint: CGPoint
//    var sideLength: CGFloat
//
//    init(frame: CGRect, center: CGPoint, sideLength: CGFloat) {
//        self.centerPoint = center
//        self.sideLength = sideLength
//        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear // 确保背景透明
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        
//        // 计算正方形的起始点
//        let originX = centerPoint.x - sideLength / 2
//        let originY = centerPoint.y - sideLength / 2
//        let squareRect = CGRect(x: originX, y: originY, width: sideLength, height: sideLength)
//
//        // 设置边框颜色和线宽
//        context.setStrokeColor(UIColor.green.cgColor)
//        context.setLineWidth(2.0)
//        
//        // 添加正方形路径
//        context.addRect(squareRect)
//        
//        // 绘制路径
//        context.strokePath()
//    }
    var centerPoint: CGPoint
       var radius: CGFloat

       init(frame: CGRect, center: CGPoint, radius: CGFloat) {
           self.centerPoint = center
           self.radius = radius
           super.init(frame: frame)
           self.backgroundColor = UIColor.clear // 保证背景透明
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

       override func draw(_ rect: CGRect) {
           guard let context = UIGraphicsGetCurrentContext() else { return }
           
           // 设置线宽
           context.setLineWidth(10.0)
           
           // 设置颜色
           context.setStrokeColor(UIColor.green.cgColor)
           
           // 绘制圆
           context.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: false)
           
           // 绘制路径
           context.strokePath()
       }
}

