//
//  WRDocument.swift
//  Pods
//
//  Created by xianghui on 2020/3/5.
//

import UIKit

class WRDocument: UIDocument {

    var rootFolder: WRCloudFolder? = nil
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    override func contents(forType typeName: String) throws -> Any {
        return rootFolder?.fileWrapper == nil ? FileWrapper.init(directoryWithFileWrappers: [:]) : rootFolder!.fileWrapper
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {

        guard let fileWrapper = contents as? FileWrapper else {
            return
        }
        if rootFolder == nil {
            rootFolder = WRCloudFolder(WRCloudManager.shared.path.root!, file: fileWrapper, superFolder: nil)
        }
        
        rootFolder?.parse(fileWrapper)
        if let folder = rootFolder {
            WRCloudManager.shared.delegate?.cloudManager(WRCloudManager.shared, open: folder)
        }
    }
    
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        debugPrint("UIDocument error = ", error, "userInteractionPermitted = ", userInteractionPermitted)
    }
    
    override func fileNameExtension(forType typeName: String?, saveOperation: UIDocument.SaveOperation) -> String {
        
        return ""
    }
}
