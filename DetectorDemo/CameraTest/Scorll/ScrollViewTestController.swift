//
//  ScrollViewTestController.swift
//  CameraTest
//
//  Created by 谢恩平 on 2024/11/9.
//

import UIKit

class ScrollViewTestController: UIViewController {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.frame = CGRect(x: 0, y: 300, width: self.view.bounds.width, height: 100)
        view.backgroundColor = .brown
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    func setupUI() {
        let tickLayer = CALayer()
        tickLayer.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 50)
        tickLayer.backgroundColor = CGColor(gray: 0.5, alpha: 0.8)
        scrollView.layer.addSublayer(tickLayer)
        view.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(width: tickLayer.frame.width, height: scrollView.frame.size.height)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: tickLayer.frame.width / 2, bottom: 0, right: 0)
    }

}

extension ScrollViewTestController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("offset: \(scrollView.contentOffset), size: \(scrollView.contentSize)")
    }
}


