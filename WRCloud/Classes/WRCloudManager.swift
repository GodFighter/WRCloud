//
//  WRCloudManager.swift
//  CloudDemo
//
//  Created by xianghui on 2020/3/4.
//  Copyright © 2020 moni. All rights reserved.
//

import UIKit

public protocol WRCloudManagerDelegate: class {
    func cloudManager(_ manager: WRCloudManager, catch error:WRCloudManager.WRCloudError)
    func cloudManager(openSuccess manager: WRCloudManager)
}

public class WRCloudManager: NSObject {
    /**
     云盘错误
     */
    public enum WRCloudError: Error {
        /** 权限错误 */
        case permissionFailure
        case createFolderFailure
        case fileNotExist
        case folderIsExist
        case folderNotExist
    }

    class Path {
        var root: URL? {
            if !WRCloudManager.shared.isAvailable {
                return nil
            }
            guard let cloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
                return nil
            }
            if !WRCloudManager.fileExist(cloudDocumentsURL) {
                return WRCloudManager.createDirectory(cloudDocumentsURL) ? cloudDocumentsURL : nil
            }
            return cloudDocumentsURL
        }
    }

    public static let shared : WRCloudManager = {
        let manager = WRCloudManager()
        NotificationCenter.default.addObserver(manager, selector: #selector(notification_documentStateChanged(_:)), name: UIDocument.stateChangedNotification, object: nil)
        return manager
    }()

    var path = Path()
    public weak var delegate: WRCloudManagerDelegate?
    
    private var _document: WRDocument?
    var document: WRDocument? {
        guard let _ = self.path.root else {
            return nil
        }
        if _document == nil {
            WRCloudManager.open { (_) in}
        }
        return _document
    }
}

//MARK:-
fileprivate typealias WRCloudManager_Private = WRCloudManager
private extension WRCloudManager_Private {
    var isAvailable: Bool {
        do {
            try WRCloudManager.shared.permission()
        } catch {
            delegate?.cloudManager(WRCloudManager.shared, catch: .permissionFailure)
            return false
        }
        return true
    }
    
    func permission() throws{
        if FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") != nil {
            return
        }
        throw WRCloudError.permissionFailure
    }
    
    static func fileExist(_ url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path, isDirectory: nil)
    }
    
    static func createDirectory(_ url: URL) -> Bool {
        var success = true
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            WRCloudManager.shared.delegate?.cloudManager(WRCloudManager.shared, catch: .createFolderFailure)
            success = false
        }
        return success
    }
    
    // 创建文件夹
    @discardableResult
    static func create(folder name: String, super folder: WRCloudFolder) -> WRCloudFolder? {
        if folder.isExist(resource: name, isFolder: true)
        {
            return folder.contents.first { (resource) -> Bool in
                if let subFolder = resource as? WRCloudFolder {
                    return subFolder.name == name
                }
                return false
            } as? WRCloudFolder
        }

        let newFolder = FileWrapper.init(directoryWithFileWrappers: [:])
        newFolder.preferredFilename = name
        folder.fileWrapper.addFileWrapper(newFolder)
        
        let cloudUrl = folder.url.appendingPathComponent(name)
        
        do
        {
            try newFolder.write(to: cloudUrl, options: FileWrapper.WritingOptions.withNameUpdating, originalContentsURL: nil)
        }
        catch let error as NSError
        {
            debugPrint(error)
        }
        
        return WRCloudFolder.init(cloudUrl, file: newFolder, superFolder: folder)
    }

    // 创建层级文件夹
    @discardableResult
    static func create(folder names:[String], super folder: WRCloudFolder) -> WRCloudFolder {
        var index = 0
        var superFolder = folder
        
        while index < names.count {
            let name = names[index]
            index += 1
            
            superFolder = self.create(folder: name, super: superFolder)!
        }
        
        return superFolder
    }
    
}

//MARK:-
fileprivate typealias WRCloudManager_Public = WRCloudManager
public extension WRCloudManager_Public {
    /**创建文件夹*/
    /**
    创建文件夹，superFolder是父文件夹字符串描述
    */
    /// - parameter name: 文件夹名
    /// - parameter superFolder: 父文件夹名。e.g. Image/Avatar/Mine、Image、nil
    static func create(folder name: String, super folder: String?) {
        guard let url = WRCloudManager.shared.path.root else {
            return
        }
        let document = WRDocument.init(fileURL: url)
        document.open { (success) in
            if success
            {
                if let rootFolder = document.rootFolder
                {
                    // 无父文件夹名，创建在根目录下
                    guard let superFolderName = folder else
                    {
                        self.create(folder: name, super: rootFolder)
                        return
                    }
                    
                    let superFolderNames: [String] = superFolderName.split(separator: "/").compactMap { "\($0)" }
                    let superFolder = self.create(folder: superFolderNames, super: rootFolder)
                    self.create(folder: name, super: superFolder)
                }
            }
        }
    }
    
    static func open(root complete:@escaping (WRCloudFolder?) -> ()) {
        guard let url = WRCloudManager.shared.path.root else {
            return
        }
        let rootDocument = WRDocument.init(fileURL: url)
        rootDocument.open { (success) in
            if success
            {
                complete(rootDocument.rootFolder)
            }
        }
        WRCloudManager.shared._document = rootDocument
    }
    
    /**保存文件*/
    /**
    保存文件
    */
    /// - parameter name: 文件名
    /// - parameter folderName: 父文件夹名。e.g. Image/Avatar/Mine、Image、nil
    static func save(file url: URL, folderName: String? = nil) {
        open { (folder) in
            guard let rootFolder = folder else {
                return
            }
            var superFolder = rootFolder
            if let superFolderName = folderName
            {
                superFolder = create(folder: superFolderName.split(separator: "/").compactMap({ "\($0)" }), super: superFolder)
            }
            
            superFolder.save(file: url)
            
        }
    }
    
}

//MARK:-
fileprivate typealias WRCloudManager_Document = WRCloudManager
private extension WRCloudManager_Document {
    @objc func notification_documentStateChanged(_ notification: Notification) {
        if let document = notification.object as? WRDocument {
            debugPrint("documentState = \(document.documentState)")
            switch document.documentState {
            case .progressAvailable:
                debugPrint("documentProgress = \(String(describing: document.progress))")
            default:break
            }
        }
        
    }
}
