//
//  PJCameraViewController.swift
//  CameraTest
//
//  Created by 谢恩平 on 2024/11/6.
//

import UIKit
import AVFoundation

class PJCameraViewController: UIViewController {
    var session = AVCaptureSession()
    
    lazy var cameraView: PJCameraView = {
        let view = PJCameraView(frame: view.bounds, session: session)
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bottomControlView: CameraBottomControlView = {
        let view = CameraBottomControlView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        session.stopRunning()
    }
    
    func setupUI() {
        view.addSubview(cameraView)
        view.addSubview(bottomControlView)
        
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bottomControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomControlView.heightAnchor.constraint(equalToConstant: 200),
            bottomControlView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension PJCameraViewController: CameraBottomControlDelegate {
    func captureClick() {
        cameraView.takePhoto()
    }
}

extension PJCameraViewController: PJCameraViewDelegate {
    func takePhotoImage(image: UIImage) {
        bottomControlView.thumbnailView.image = image
    }
}
