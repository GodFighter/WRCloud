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
    var fullName: String
    var path: String
    var type: String
    var fileWrapper : FileWrapper
    
    weak var folder: WRCloudFolder? = nil

    init(_ path: String, file: FileWrapper) {
        self.path = path
        self.fullName = (path as NSString).lastPathComponent
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
    
    func isExist(target name: String) -> Bool {
        let folders = contents.filter { (object) -> Bool in
            if let folder = object as? WRCloudFolder {
                return folder.name == name
            } else if let file = object as? WRCloudFile {
                return file.fullName == name
            }
            return false
        }
        return folders.count != 0
    }
    
    func save(folder name: String) {
        guard !self.isExist(target: name) else {
            WRCloudManager.shared.delegate?.cloudManager(WRCloudManager.shared, catch: .folderIsExist)
            return
        }

        let cloudFolderUrl = URL(fileURLWithPath: path).appendingPathComponent(name)
        let folderWrapper = FileWrapper.init(directoryWithFileWrappers: [:])
        folderWrapper.preferredFilename = name
        self.fileWrapper.addFileWrapper(folderWrapper)

        do {
            try folderWrapper.write(to: cloudFolderUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: nil)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func save(file path: String) {
        let originalUrl = URL(fileURLWithPath: path)
        let fullName = (path as NSString).lastPathComponent
        let cloudFileUrl = URL(fileURLWithPath: self.path).appendingPathComponent(fullName)
        debugPrint(cloudFileUrl)

        do {
            let data = try Data.init(contentsOf: originalUrl)
            let newFileWrapper = FileWrapper.init(regularFileWithContents: data)
            newFileWrapper.preferredFilename = fullName
            if self.isExist(target: fullName)
            {
                let deleteFile = self.fileWrapper.fileWrappers?.filter({ (info) -> Bool in
                    return info.key == fullName
                    }).values.first
                self.fileWrapper.removeFileWrapper(deleteFile!)
            }
            
            self.fileWrapper.addFileWrapper(newFileWrapper)
            
//            try data.write(to: cloudFileUrl)
            
            try newFileWrapper.write(to: cloudFileUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: originalUrl)
            WRCloudManager.shared.document?.save(to: cloudFileUrl, for: UIDocument.SaveOperation.forCreating, completionHandler: nil)
            
//            WRCloudManager.shared.close()
//            WRCloudManager.shared.document?.updateChangeCount(.done)
//            WRCloudManager.shared.document?.save(to: cloudFileUrl, for: UIDocument.SaveOperation.forOverwriting, completionHandler: { (finished) in
//                
//            })

        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
