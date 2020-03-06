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

    public class Path {
        public var root: URL? {
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
        return manager
    }()

    public var path = Path()
    public weak var delegate: WRCloudManagerDelegate?
    
    private var _document: WRDocument?
    public var document: WRDocument? {
        guard let path = self.path.root else {
            return nil
        }
        if _document == nil {
            _document = WRDocument.init(fileURL: path)
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
        DispatchQueue.global().async(group: GCD_queue_group, execute: DispatchWorkItem.init(block: { [weak self] in
            guard let `self` = self else
            {
                return
            }
            self.GCD_semaphore.wait()

            guard let path = filePath, (path as NSString).lastPathComponent.count > 0 else
            {
                return
            }
            
            let superFolder = folder == nil ? WRCloudManager.shared.document?.rootFolder : folder
            guard let targetFolder = superFolder else {
                self.delegate?.cloudManager(self, catch: .folderNotExist)
                return
            }

            targetFolder.save(file: path)
        }))
    }
    
    func open()
    {
        DispatchQueue.global().async(group: GCD_queue_group, execute: DispatchWorkItem.init(block: { [weak self] in
            guard let `self` = self, let document = self.document else {
                return
            }
            
            document.open { (finished) in
                DispatchQueue.main.sync { [weak self]  in
                    if let `self` = self
                    {
                        self.delegate?.cloudManager(openSuccess: self)
                    }
                }
                
                document.enableEditing()
//                document.updateChangeCount(.done)
//                document.close(completionHandler: nil)
                self.GCD_semaphore.signal()
            }
        }))
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
