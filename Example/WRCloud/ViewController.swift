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
        
//        WRCloudManager.open { (folder) in
//            guard let rootFolder = folder else {
//                return
//            }
//            print(rootFolder.contents)
//        }

        let filePath = Bundle.main.path(forResource: "README", ofType: "md")
//        WRCloudManager.save(file: URL(fileURLWithPath: filePath!))
        WRCloudManager.save(file: URL(fileURLWithPath: filePath!), folderName: "Image")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK:-
fileprivate typealias ViewController_WRCloudManagerDelegate = ViewController
extension ViewController_WRCloudManagerDelegate {
    func cloudManager(_ manager: WRCloudManager, open folder: WRCloudFolder) {
        debugPrint("WRCloudManager open success)")
}
    
    func cloudManager(_ manager: WRCloudManager, catch error: Error, code: WRCloudManager.WRCloudError) {
        debugPrint("WRCloudManager error = \(error)")
    }
    
    func cloudManager(_ manager: WRCloudManager, saveFile name: String) {
        debugPrint("WRCloudManager save file success)")
    }
}


