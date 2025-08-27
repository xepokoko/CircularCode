//
//  CameraBottomControlView.swift
//  CameraTest
//
//  Created by 谢恩平 on 2024/11/6.
//

import UIKit

protocol CameraBottomControlDelegate: AnyObject {
    func captureClick()
}


class CameraBottomControlView: UIView {
    weak var delegate: CameraBottomControlDelegate?
    lazy var contentView: UIView = {
        let view = UIView(frame: self.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var captureButton: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 40
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(clickCaptureButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false  // 禁用 autoresizing mask
        btn.backgroundColor = .white
        return btn
    }()
    lazy var thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(captureButton)
        contentView.addSubview(thumbnailView)
        addSubview(contentView)
        
        // 设置 contentView 的约束
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        // 设置 captureButton 的约束，使其位于 contentView 的几何中心
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            captureButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            thumbnailView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailView.widthAnchor.constraint(equalToConstant: 90),
            thumbnailView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
    }
    
    
    @objc
    func clickCaptureButton() {
        delegate?.captureClick()
    }
}
