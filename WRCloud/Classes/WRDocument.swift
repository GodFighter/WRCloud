//
//  WRDocument.swift
//  Pods
//
//  Created by xianghui on 2020/3/5.
//

import UIKit

class WRDocument: UIDocument {

    public var rootFolder: WRCloudFolder? = nil
    
    public override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    public override func contents(forType typeName: String) throws -> Any {
        return rootFolder?.fileWrapper == nil ? FileWrapper.init(directoryWithFileWrappers: [:]) : rootFolder!.fileWrapper
    }

    public override func load(fromContents contents: Any, ofType typeName: String?) throws {

        guard let fileWrapper = contents as? FileWrapper else {
            return
        }
        if rootFolder == nil {
            rootFolder = WRCloudFolder(WRCloudManager.shared.path.root!, file: fileWrapper, superFolder: nil)
        }
        
        for var wrapper in (rootFolder?.fileWrapper.fileWrappers!.values)! {
                
            
//            if let data = wrapper.regularFileContents {
//                do {
//                    let string = try String(data: data, encoding: .utf8)
//                    print(string)
//                } catch let error {
//                    print(error)
//                }
//            }
        }
        
        rootFolder?.parse(fileWrapper)
//        do {
//            try FileManager.default.startDownloadingUbiquitousItem(at: ))
//        } catch let error {
//            print("download error =", error)
//        }
        
    }
    
    override open func handleError(_ error: Error, userInteractionPermitted: Bool) {
        
    }
    
    override open func fileNameExtension(forType typeName: String?, saveOperation: UIDocument.SaveOperation) -> String {
        
        return ""
    }
}
