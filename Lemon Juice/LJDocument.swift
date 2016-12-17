//
//  Document.swift
//  Lemon Juice
//
//  Created by Adam Cowdy on 15/12/2016.
//  Copyright © 2016 Adam Cowdy. All rights reserved.
//

import Cocoa

// Class which acts as a controller mediating between a single window controller and one or more 
// models, in this case a NSTextStorage.
class LJDocument: NSDocument {
    
    @IBOutlet weak private(set) var textView : NSTextView?
    
    private var passwordKey : String?
    private var textStorageToLoad : NSTextStorage?
    
    override init() {
        super.init()
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    class func canAsynchronouslyWrite(to url: URL, ofType typeName: String,
                                      for saveOperation: NSSaveOperationType) -> Bool {
        return true
    }
    
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return true
    }
    
    // Makes the data in the document available to save
    override func data(ofType typeName: String) throws -> Data {
        
        // Make the range the entire textStorage of textView
        let range = NSRange(location: 0, length: textView!.textStorage!.length)
        
        let attributes = [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
        
        // Get the data from the textStorage
        let data = try textView!.textStorage!.data(from: range,
                                                   documentAttributes: attributes)
        
        return data
    }
    
    internal func decrypt(data cipherTextData: Data, password passwordKey: String) -> Data {
        // TODO: Implement this function
        return cipherTextData
    }
    
    internal func encrypt(data plainTextData: Data, password passwordKey: String) -> Data {
        // TODO: Implement this function
        return plainTextData
    }
    
    // Open data that has been read from a file
    override func read(from data: Data, ofType typeName: String) throws {
        var attributes = [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
        let attributesPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>(&attributes)
        
        // Create a new text storage for the document to load once the nib is loaded
        textStorageToLoad = NSTextStorage.init(rtfd: data, documentAttributes: attributesPointer)
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        // Load textStorageToLoad if it exists
        if textStorageToLoad != nil {
            textView!.layoutManager!.replaceTextStorage(textStorageToLoad!)
        }
    }

    // Returns the nib file name of the document
    override var windowNibName: String? {
        return "DocumentWindow"
    }
}

