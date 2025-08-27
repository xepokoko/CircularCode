//
//  ViewController.swift
//  CameraTest
//
//  Created by 谢恩平 on 2024/11/5.
//

import UIKit

class ViewController: UIViewController {
    
    let titles = ["PJCamera", "ScrollTest", "livePhoto", "REDCode"]
    let pageControllers: [UIViewController.Type] = [PJCameraViewController.self]
    
    lazy var table: UITableView = {
        let table = UITableView()
        table.frame = self.view.bounds
        table.delegate = self
        table.dataSource = self
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    func setupUI() {
        view.addSubview(table)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 尝试重用可重用的单元格
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            // 如果没有可重用的单元格，则创建一个新的
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        // 设置单元格的文本
        cell?.textLabel?.text = titles[indexPath.row]
            
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let controller = PJCameraViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 1 {
            let controller = ScrollViewTestController()
            self.navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 2 {
            let controller = LivePhotoVideoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        } else if indexPath.row == 3 {
            let controller = REDCodeViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
}

