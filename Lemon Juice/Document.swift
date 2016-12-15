//
//  Document.swift
//  Lemon Juice
//
//  Created by Adam Cowdy on 15/12/2016.
//  Copyright © 2016 Adam Cowdy. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    @IBOutlet weak var textView : NSTextView?
    
    var documentAttributesDict : [String: String] =
        [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
    
    private var passwordKey = ""
    private var textStorage : NSTextStorage?

    override init() {
        super.init()
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    // Write files asynchronously
    class func canAsynchronouslyWrite(to url: URL, ofType typeName: String,
                                      for saveOperation: NSSaveOperationType) -> Bool {
        return true
    }
    
    // Read files asynchronously
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return true
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        // Use textStorage if it already exists e.g. a file has been opened,
        // else simply make the textStorage field a reference to textView.textStorage
        if textStorage != nil {
            textView!.layoutManager!.replaceTextStorage(textStorage!)
        }
        else {
            textStorage = textView!.textStorage!
        }
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        return "Document"
    }
    
    // Makes the data in the document available to save
    override func data(ofType typeName: String) throws -> Data {
        
        // Make the range the whole textStorage of textView
        let range = NSRange(location: 0, length: textView!.textStorage!.length)
        
        // Get the data from the textStorage
        let data = try textView!.textStorage!.data(from: range,
                                                   documentAttributes: documentAttributesDict)
        
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Create a new text storage for the document
        let dictRef = AutoreleasingUnsafeMutablePointer<NSDictionary?>(&documentAttributesDict)
        textStorage = NSTextStorage.init(rtfd: data, documentAttributes: dictRef)!
    }
}

