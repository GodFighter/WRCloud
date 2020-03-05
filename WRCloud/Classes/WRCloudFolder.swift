//
//  WRCloudFolder.swift
//  DemoCloud
//
//  Created by xianghui on 2020/3/4.
//  Copyright © 2020 moni. All rights reserved.
//

import UIKit

//MARK:-
public class WRCloudFile {
    var name: String
    var path: String
    var type: String
    var fileWrapper : FileWrapper
    
    weak var folder: WRCloudFolder? = nil

    init(_ path: String, file: FileWrapper) {
        self.path = path
        self.name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension
        self.type = (path as NSString).pathExtension
        self.fileWrapper = file
    }
    
    func lastPathComponent() -> String {
        return (path as NSString).lastPathComponent
    }
}

//MARK:-
public class WRCloudFolder {
    var name: String
    var path: String
    var fileWrapper : FileWrapper
    var contents: [Any] = []

    weak var folder: WRCloudFolder? = nil

    init(_ path: String, file: FileWrapper) {
        self.path = path
        self.name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension
        self.fileWrapper = file
    }
    
    private func addContent(_ content: Any) {
        switch content.self {
        case is FileWrapper:
            let fileWrapper = content as! FileWrapper

            if fileWrapper.isRegularFile {
                let file = WRCloudFile(WRCloudManager.shared.path.root!.appendingPathComponent(fileWrapper.filename!).path, file: fileWrapper)
                file.folder = self
                contents.append(file)
             
            } else if fileWrapper.isDirectory {
                let folder = WRCloudFolder(WRCloudManager.shared.path.root!.appendingPathComponent(fileWrapper.filename!).path, file: fileWrapper)
                folder.parse(folder.fileWrapper)
                folder.folder = self
                contents.append(folder)
            }

        default: break
        }
    }
    
    func parse(_ fileWrapper: FileWrapper) {
        self.contents.removeAll()

        if let wrappers = fileWrapper.fileWrappers?.filter({ (dictionary) -> Bool in
            let key = dictionary.key
            // 筛除无名和隐藏文件
            if key.count == 0 || key[key.startIndex] == "." {
                return false
            }
            return true
        }) {
            wrappers.values.forEach { (fileWrapper) in
                self.addContent(fileWrapper)
            }
        }
    }
}

extension FileWrapper {
    
}
