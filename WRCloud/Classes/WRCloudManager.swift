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
    
    private let GCD_semaphore = DispatchSemaphore.init(value: 0)
    private let GCD_queue_group = DispatchGroup.init()

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
    
}

//MARK:-
fileprivate typealias WRCloudManager_Public = WRCloudManager
public extension WRCloudManager_Public {
    func create(folder name: String, superFolder: WRCloudFolder? = nil) {
        DispatchQueue.global().async(group: GCD_queue_group, execute: DispatchWorkItem.init(block: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.GCD_semaphore.wait()

            let targetFolder = superFolder == nil ? WRCloudManager.shared.document?.rootFolder : superFolder
            guard let folder = targetFolder else {
                return
            }
            
            folder.save(folder: name)
        }))
    }
    
    func save(_ filePath: String?, _ folder: WRCloudFolder? = nil) {
//        guard let path = filePath else {
//            return
//        }
//        let originalUrl = URL(fileURLWithPath: path)
//        let fullName = (path as NSString).lastPathComponent
//        let cloudFolderUrl = self.path.root!.appendingPathComponent((fullName as NSString).deletingPathExtension)
//        let cloudFileUrl = cloudFolderUrl.appendingPathComponent(fullName)
//
//        let doc = WRDocument.init(fileURL: cloudFolderUrl)
////        let folder = FileWrapper.init(directoryWithFileWrappers: [:])
////        folder.preferredFilename = (fullName as NSString).deletingPathExtension
//        
//        
//        doc.open { (success) in
//            if success {
//                do {
//                    let data = try Data.init(contentsOf: originalUrl)
//                    let fileWrapper = FileWrapper.init(regularFileWithContents: data)
//                    fileWrapper.preferredFilename = fullName
//                    fileWrapper.filename = fullName
////                    folder.addFileWrapper(fileWrapper)
//                    doc.rootFolder?.fileWrapper.addFileWrapper(fileWrapper)
//
//                    doc.save(to: cloudFolderUrl, for: UIDocument.SaveOperation.forCreating, completionHandler: { (success) in
//                        doc.close(completionHandler: nil)
//                    })
//
//                } catch let error {
//                    print("save error = \(error)")
//                }
//
//                
//            }
//        }
//        DispatchQueue.global().async(group: GCD_queue_group, execute: DispatchWorkItem.init(block: { [weak self] in
//            guard let `self` = self else
//            {
//                return
//            }
//            self.GCD_semaphore.wait()
//
//            guard let path = filePath, (path as NSString).lastPathComponent.count > 0 else
//            {
//                return
//            }
//
//            let superFolder = folder == nil ? WRCloudManager.shared.document?.rootFolder : folder
//            guard let targetFolder = superFolder else {
//                self.delegate?.cloudManager(self, catch: .folderNotExist)
//                return
//            }
//
//            targetFolder.save(file: path)
//        }))
    }
    
    static func open(root complete:@escaping (WRCloudFolder?) -> ()) {
        let rootDocument = WRDocument.init(fileURL: WRCloudManager.shared.path.root!)
        rootDocument.open { (success) in
            if success
            {
                complete(rootDocument.rootFolder)
            }
        }
        WRCloudManager.shared._document = rootDocument
    }
    
    func open()
    {
//        DispatchQueue.global().async(group: GCD_queue_group, execute: DispatchWorkItem.init(block: { [weak self] in
//            guard let `self` = self, let document = self.document else {
//                return
//            }
//
//            document.open { (finished) in
//                DispatchQueue.main.sync { [weak self]  in
//                    if let `self` = self
//                    {
//                        self.delegate?.cloudManager(openSuccess: self)
//                    }
//                }
//
//                document.enableEditing()
////                document.updateChangeCount(.done)
////                document.close(completionHandler: nil)
//                self.GCD_semaphore.signal()
//            }
//        }))
    }
    
    func close() {
//        DispatchQueue.global().async(group: GCD_queue_group, execute: DispatchWorkItem.init(block: { [weak self] in
//            guard let `self` = self, let document = self.document else {
//                return
//            }
//
////            self.GCD_semaphore.wait()
//            document.close { (finished) in
//                
//            }
//        }))
    }
}
//MARK:-
fileprivate typealias WRCloudManager_Document = WRCloudManager
public extension WRCloudManager_Document {
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
