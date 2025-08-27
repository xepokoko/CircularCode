//
//  PJCameraView.swift
//  CameraTest
//
//  Created by 谢恩平 on 2024/11/5.
//

import UIKit
import AVFoundation
import Photos

protocol PJCameraViewDelegate {
    func takePhotoImage(image: UIImage)
}

class PJCameraView: UIView {
    var cost: Double = 0
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue", qos: .userInteractive)
    public var session: AVCaptureSession = AVCaptureSession()
    private var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer()
        preview.frame = self.frame
        return preview
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.frame = self.bounds
        return view
    }()
        
    public var delegate: PJCameraViewDelegate?
    
    init(frame: CGRect, session: AVCaptureSession? = nil) {
        if let session = session {
            self.session = session
        }
        super.init(frame: frame)
        initView()
        configureCameraView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        let deviceTypes = [
            AVCaptureDevice.DeviceType.builtInDualCamera,
            AVCaptureDevice.DeviceType.builtInWideAngleCamera,
            AVCaptureDevice.DeviceType.builtInTelephotoCamera,
            AVCaptureDevice.DeviceType.builtInUltraWideCamera,
            AVCaptureDevice.DeviceType.builtInTrueDepthCamera
        ]

        let session = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                        mediaType: .video,
                                                         position: .unspecified)

        let multicamSupportedDeviceSets = session.supportedMultiCamDeviceSets
        multicamSupportedDeviceSets.forEach { set in
            for element in set {
                let position = element.position.rawValue == 1 ? "后" : "前"
                print("type:\(element.deviceType.rawValue)- position:\(position)")
            }
            
            print("-------------------------------------------")
        }
        
        self.backgroundColor = UIColor.white
        self.addSubview(contentView)
        self.contentView.layer.addSublayer(previewLayer)
    }
    
    private func configureCameraView() {
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill

        sessionQueue.async {
            self.configSession()
            // 启动相机
            self.session.startRunning()
        }
    }
    
    func configSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        let backWideAngleCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: backWideAngleCamera!) else { return }
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
//        if photoOutput.isLivePhotoCaptureSupported {
//            photoOutput.isLivePhotoCaptureEnabled = true
//        }
        
        if #available(iOS 17.0, *) {
            if photoOutput.isAutoDeferredPhotoDeliverySupported {
                photoOutput.isAutoDeferredPhotoDeliveryEnabled = true
            }
            if photoOutput.isZeroShutterLagSupported {
                photoOutput.isZeroShutterLagEnabled = false
            }
            
        }
        session.commitConfiguration()
    }
    
    public func takePhoto() {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.hevc])

        photoSettings.photoQualityPrioritization = photoOutput.maxPhotoQualityPrioritization
        print("\(photoOutput.maxPhotoQualityPrioritization)")
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
        
}

extension PJCameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
        cost = CFAbsoluteTimeGetCurrent()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willCapturePhotoFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("didCapturePhotoFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        cost = CFAbsoluteTimeGetCurrent() - cost
        print("didFinishProcessingPhoto, cost:\(cost)")
        guard let data = photo.fileDataRepresentation() else { return }
        let image = UIImage.init(data: data)
        delegate?.takePhotoImage(image: image!)
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        }, completionHandler: nil)
    
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: Error?) {
        print("didFinishCapturingDeferredPhotoProxy")
        if let error = error {
            print("deferredPhotoProxy error: \(error)")
            return
        }
        let library = PHPhotoLibrary.shared()
        guard let data = deferredPhotoProxy?.fileDataRepresentation() else { return }

        library.performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photoProxy, data: data, options: nil)
        } completionHandler: { _, error in
            if let error {
                print("PHAssetCreationRequest error: \(error)")
            } else {
                print("save success")
            }
        }
    }
    
}
