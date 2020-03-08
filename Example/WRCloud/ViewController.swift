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
        
//        let filePath = Bundle.main.path(forResource: "README", ofType: "jpg")
//        WRCloudManager.save(file: URL(fileURLWithPath: filePath!))
//        WRCloudManager.save(file: URL(fileURLWithPath: filePath!), folderName: "Image/Avatar")
        
//        WRCloudManager.create(folder: "Ren", super: "Xiang/Hui/Wu")
//        
//        WRCloudManager.create(folder: "Xiang", super: nil)
                
        WRCloudManager.open { (folder) in
            for resource in (folder?.resources)! {
                print("resource = ", resource)

            }
        }
        
//        WRCloudManager.shared.open()
//        WRCloudManager.shared.create(folder: "Image")
//        let filePath = Bundle.main.path(forResource: "README", ofType: "jpg")
//        WRCloudManager.shared.save(filePath)
        
//        let doc = WRDocument.init(fileURL: WRCloudManager.shared.path.root!)
//        doc.open { (success) in
//            if success {
//                if let url = WRCloudManager.shared.path.root?.appendingPathComponent("README/README.md") {
//                    do {
//                        let data = try Data(contentsOf: url)
//                        let string = String(data: data, encoding: .utf8)
//                        print(string as Any)
//                    } catch let error {
//                        print(error)
//                    }
//
//                }
//            }
//        }
        
        
        
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
        debugPrint("WRCloudManager error = \(error)")
    }
}


