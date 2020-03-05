//
//  WRCloudFolder.swift
//  DemoCloud
//
//  Created by xianghui on 2020/3/4.
//  Copyright © 2020 moni. All rights reserved.
//

import UIKit

struct WRCloudFile {
    var name: String
    var path: String
}

struct WRCloudFolder {
    var name: String
    var path: String
    var files: [WRCloudFile] = []
}
