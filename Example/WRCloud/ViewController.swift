//
//  ViewController.swift
//  WRCloud
//
//  Created by GodFighter on 03/04/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRCloud

class ViewController: UIViewController, WRCloudManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        WRCloudManager.shared.delegate = self
        WRCloudManager.shared.open()
//        WRCloudManager.shared.create(folder: "Image")
//        let filePath = Bundle.main.path(forResource: "README", ofType: "md")
//        WRCloudManager.shared.save(filePath)
        
        if let url = WRCloudManager.shared.path.root?.appendingPathComponent("README.md") {
            do {
                let data = try Data(contentsOf: url)
                let string = String(data: data, encoding: .utf8)
                print(string as Any)
            } catch let error {
                print(error)
            }

        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK:-
fileprivate typealias ViewController_WRCloudManagerDelegate = ViewController
extension ViewController_WRCloudManagerDelegate {
    func cloudManager(openSuccess manager: WRCloudManager) {
//        let filePath = Bundle.main.path(forResource: "README", ofType: "md")
//        WRCloudManager.shared.save(filePath)
//        WRCloudManager.shared.create(folder: "Image")
    }
    
    func cloudManager(_ manager: WRCloudManager, catch error: WRCloudManager.WRCloudError) {
        
    }
}


