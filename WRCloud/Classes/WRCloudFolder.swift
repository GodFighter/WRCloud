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
class WRCloudFile {
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
    public var url: URL
    var fileWrapper : FileWrapper
    
    var contents: [Any] = []        //内容数组
    var waitingContents: [Any] = []  // 等待更新内容数组

    weak var folder: WRCloudFolder? = nil
    
    init(_ url: URL, file: FileWrapper, superFolder: WRCloudFolder?) {
        self.url = url
        self.name = ((url.path as NSString).lastPathComponent as NSString).deletingPathExtension
        self.fileWrapper = file
        self.folder = superFolder
    }
    
}

//MARK: -
fileprivate typealias WRCloudFolder_Public = WRCloudFolder
public extension WRCloudFolder_Public {
    var isRoot: Bool {
        return folder == nil
    }

    var resources: [Any]? {
        return contents.map { (resource) -> Any in
            if let folder = resource as? WRCloudFolder {
                return folder
            } else if let file = resource as? WRCloudFile {
                return file.url
            }
            return url
        }
    }
    
    var waitingResources: [Any]? {
        return waitingContents.map { (resource) -> Any in
            if let folder = resource as? WRCloudFolder {
                return folder
            } else if let file = resource as? WRCloudFile {
                return file.url
            }
            return url
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

    func isExist(resource name: String, isFolder: Bool) -> Bool {
        let folders = contents.filter { (object) -> Bool in
            if let folder = object as? WRCloudFolder {
                return (folder.name == name && folder.fileWrapper.isDirectory == isFolder)
            } else if let file = object as? WRCloudFile {
                return (file.fullName == name && file.fileWrapper.isRegularFile == !isFolder)
            }
            return false
        }
        return folders.count != 0
    }
    
    func save(folder name: String) {
        guard !self.isExist(resource: name, isFolder: true) else {
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
    
    func save(file url: URL) {
      
        guard url.path.count > 0 else {
            return
        }

        let fileFullName = (url.path as NSString).lastPathComponent

        do {
            let fileData: Data = try Data.init(contentsOf: url)
            let cloudUrl = self.url.appendingPathComponent(fileFullName)
            
            let newFileWrapper = FileWrapper.init(regularFileWithContents: fileData)
            newFileWrapper.preferredFilename = fileFullName
            fileWrapper.addFileWrapper(newFileWrapper)
            
            if self.isExist(resource: fileFullName, isFolder: false)
            {
                let deleteFile = fileWrapper.fileWrappers?.filter({ (info) -> Bool in
                    return info.key == fileFullName
                    }).values.first
                fileWrapper.removeFileWrapper(deleteFile!)
            }

            try newFileWrapper.write(to: cloudUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: url)
            
            let newFile = WRCloudFile.init(url, file: newFileWrapper, superFolder: self)
            contents.append(newFile)
            
            
        } catch let error {
            debugPrint(error)
        }

    }

}

//MARK: -
fileprivate typealias WRCloudFolder_Private = WRCloudFolder
private extension WRCloudFolder_Private {

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

