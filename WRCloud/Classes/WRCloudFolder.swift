//
//  WRCloudFolder.swift
//  DemoCloud
//
//  Created by xianghui on 2020/3/4.
//  Copyright © 2020 moni. All rights reserved.
//

import UIKit

private let WRCloudResourceName = ".icloud"

//MARK:-
public class WRCloudFile {
    var name: String
    var fullName: String
    var url: URL
    var type: String
    var fileWrapper : FileWrapper
    
    weak var folder: WRCloudFolder? = nil

    init(_ url: URL, file: FileWrapper, superFolder: WRCloudFolder?) {
        self.url = url
        self.fullName = (url.path as NSString).lastPathComponent
        self.name = (fullName as NSString).deletingPathExtension
        self.type = (url.path as NSString).pathExtension
        self.fileWrapper = file
        self.folder = superFolder
    }
}

//MARK:-
public class WRCloudFolder {
    var name: String
    var url: URL
    var fileWrapper : FileWrapper
    
    var contents: [Any] = []        //内容数组
    var waitingContents: [Any] = []  // 等待更新内容数组

    weak var folder: WRCloudFolder? = nil
    
    var isRoot: Bool {
        return folder == nil
    }

    init(_ url: URL, file: FileWrapper, superFolder: WRCloudFolder?) {
        self.url = url
        self.name = ((url.path as NSString).lastPathComponent as NSString).deletingPathExtension
        self.fileWrapper = file
        self.folder = superFolder
    }
    
//    func save(folder name: String) {
//        guard !self.isExist(target: name) else {
//            WRCloudManager.shared.delegate?.cloudManager(WRCloudManager.shared, catch: .folderIsExist)
//            return
//        }
//
//        let cloudFolderUrl = URL(fileURLWithPath: path).appendingPathComponent(name)
//        let folderWrapper = FileWrapper.init(directoryWithFileWrappers: [:])
//        folderWrapper.preferredFilename = name
//        self.fileWrapper.addFileWrapper(folderWrapper)
//
//        do {
//            try folderWrapper.write(to: cloudFolderUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: nil)
//        } catch let error as NSError {
//            print(error)
//        }
//    }
    
    func save(file path: String) {
//        let originalUrl = URL(fileURLWithPath: path)
//        let fullName = (path as NSString).lastPathComponent
//        let cloudFileUrl = URL(fileURLWithPath: self.path).appendingPathComponent(fullName)
//        debugPrint(cloudFileUrl)
//
//
////        do {
////            try FileManager.default.copyItem(at: originalUrl, to: cloudFileUrl)
////        } catch let error {
////            print(error)
////        }
//
//
//
//        do {
//            let data = try Data.init(contentsOf: originalUrl)
//            let newFileWrapper = FileWrapper.init(regularFileWithContents: data)
//            newFileWrapper.preferredFilename = fullName
//            if self.isExist(target: fullName)
//            {
//                let deleteFile = self.fileWrapper.fileWrappers?.filter({ (info) -> Bool in
//                    return info.key == fullName
//                    }).values.first
//                self.fileWrapper.removeFileWrapper(deleteFile!)
//            }
//
//            self.fileWrapper.addFileWrapper(newFileWrapper)
//
////            try data.write(to: cloudFileUrl)
//
////            try newFileWrapper.write(to: cloudFileUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: originalUrl)
//
//            let doc = WRDocument.init(fileURL: URL(fileURLWithPath: self.path))
//            doc.open { (success) in
//                doc.rootFolder?.fileWrapper.addFileWrapper(newFileWrapper)
//                doc.save(to: cloudFileUrl, for: UIDocument.SaveOperation.forCreating) { (success) in
////                    doc.close(completionHandler: nil)
//                }
//
//            }
//
//
////            WRCloudManager.shared.document?.save(to: cloudFileUrl, for: UIDocument.SaveOperation.forCreating, completionHandler: nil)
////            WRCloudManager.shared.document?.save(to: cloudFileUrl, for: UIDocument.SaveOperation.forCreating, completionHandler: { (success) in
////
////            })
//
////
////            WRCloudManager.shared.close()
////            WRCloudManager.shared.document?.updateChangeCount(.done)
////            WRCloudManager.shared.document?.save(to: cloudFileUrl, for: UIDocument.SaveOperation.forOverwriting, completionHandler: { (finished) in
////
////            })
//
//        } catch let error as NSError {
//            debugPrint(error)
//        }
        
    }
}

//MARK: -
fileprivate typealias WRCloudFolder_Public = WRCloudFolder
public extension WRCloudFolder_Public {
    func save(folder name: String) {        
        guard !self.isExist(resource: name) else {
            return
        }
        
        let cloudFolderUrl = url.appendingPathComponent(name)
        let folderWrapper = FileWrapper.init(directoryWithFileWrappers: [:])
        folderWrapper.preferredFilename = name
        fileWrapper.addFileWrapper(folderWrapper)

        do {
            try folderWrapper.write(to: cloudFolderUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: nil)
        } catch let error as NSError {
            debugPrint(error)
        }

    }
}

//MARK: -
fileprivate typealias WRCloudFolder_Internal = WRCloudFolder
internal extension WRCloudFolder_Internal {
    func parse(_ fileWrapper: FileWrapper) {
        contents.removeAll()
        waitingContents.removeAll()
        
        // 未下载的文件
        if let waitingWrappers = fileWrapper.fileWrappers?.filter({ (dictionary) -> Bool in
            let key = dictionary.key
            if key.contains(WRCloudResourceName), key[key.startIndex] == "." {
                return true
            }
            return false
        }) {
            waitingWrappers.values.forEach { (waitingWrapper) in
                self.addContent(waiting: waitingWrapper)
            }
        }

        // 已下载的文件
        if let wrappers = fileWrapper.fileWrappers?.filter({ (dictionary) -> Bool in
            let key = dictionary.key
            if key.count == 0 || key[key.startIndex] == "." {
                return false
            }
            return true
        }) {
            wrappers.values.forEach { (fileWrapper) in
                self.addContent(fileWrapper)
            }
        }
        
        if waitingContents.count > 0 {
            download()
        }
    }

}

//MARK: -
fileprivate typealias WRCloudFolder_Private = WRCloudFolder
private extension WRCloudFolder_Private {
    
    func isExist(resource name: String) -> Bool {
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

    func addContent(_ content: Any) {
        switch content.self {
        case is FileWrapper:
            let fileWrapper = content as! FileWrapper

            if fileWrapper.isRegularFile {
                let file = WRCloudFile(self.url.appendingPathComponent(fileWrapper.preferredFilename!), file: fileWrapper, superFolder: self)
                contents.append(file)
             
            } else if fileWrapper.isDirectory {
                let folder = WRCloudFolder(self.url.appendingPathComponent(fileWrapper.preferredFilename!), file: fileWrapper, superFolder: self)
                folder.parse(folder.fileWrapper)
                contents.append(folder)
            }

        default: break
        }
    }
    
    func addContent(waiting content: Any) {
        switch content.self {
        case is FileWrapper:
            let fileWrapper = content as! FileWrapper
            
            var name: String = String(fileWrapper.preferredFilename!.dropFirst())
            name = String(name.dropLast(WRCloudResourceName.count))

            if fileWrapper.isRegularFile {
                let file = WRCloudFile(self.url.appendingPathComponent(name), file: fileWrapper, superFolder: self)
                waitingContents.append(file)
             
            } else if fileWrapper.isDirectory {
                let folder = WRCloudFolder(self.url.appendingPathComponent(name), file: fileWrapper, superFolder: self)
                folder.parse(folder.fileWrapper)
                waitingContents.append(folder)
            }

        default: break
        }
    }

    func download() {
        waitingContents.forEach { (resource) in
            if let file = resource as? WRCloudFile {
                do {
                    try FileManager.default.startDownloadingUbiquitousItem(at: file.url)
                } catch let error {
                    debugPrint(error)
                }
            }
        }
    }

}

