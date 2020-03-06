//
//  WRDocument.swift
//  Pods
//
//  Created by xianghui on 2020/3/5.
//

import UIKit

public class WRDocument: UIDocument {

    public var rootFolder: WRCloudFolder? = nil
    
    public override func contents(forType typeName: String) throws -> Any {

        guard let path = rootFolder?.path else {
            return FileWrapper.init(directoryWithFileWrappers: [:])
        }
        
        return rootFolder?.fileWrapper
    }

    public override func load(fromContents contents: Any, ofType typeName: String?) throws {

        guard let fileWrapper = contents as? FileWrapper else {
            return
        }
        if rootFolder == nil {
            rootFolder = WRCloudFolder(WRCloudManager.shared.path.root!.path, file: fileWrapper)
        }
        
        for var wrapper in (rootFolder?.fileWrapper.fileWrappers!.values)! {
            
        }
        
        rootFolder?.parse(fileWrapper)
    }
    
    open override func save(to url: URL, for saveOperation: UIDocument.SaveOperation, completionHandler: ((Bool) -> Void)? = nil) {
        
    }
}
