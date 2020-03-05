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
    
    var folders:[WRCloudFolder] = []
    var files:[WRCloudFile] = []
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
    func save(file path: String) throws {
        
    }
}
