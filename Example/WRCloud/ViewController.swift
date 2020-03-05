//
//  ViewController.swift
//  WRCloud
//
//  Created by GodFighter on 03/04/2020.
//  Copyright (c) 2020 GodFighter. All rights reserved.
//

import UIKit
import WRCloud

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print(WRCloudManager.shared.path.root)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

