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
    
    @IBOutlet weak private var textView : NSTextView?
    
    @IBOutlet var setPasswordSheet: NSWindow?
    @IBOutlet weak var passwordField: NSSecureTextField?
    @IBOutlet weak var confirmPasswordField: NSSecureTextField?
    @IBOutlet weak var errorLabel: NSTextField!
    
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
    
    @IBAction func cancelSetPassword(_ sender: AnyObject) {
        close()
    }
    
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return true
    }
    
    // Makes the data in the document available to save
    override func data(ofType typeName: String) throws -> Data {
        
        // Make the range the entire textStorage of textView
        let range = NSRange(location: 0, length: textView!.textStorage!.length)
        let attributes = [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
        
        // Get the data from the textStorage and encrypt it
        let plainTextData = try textView!.textStorage!.data(from: range,
                                                   documentAttributes: attributes)
        let cipherTextData = LJEncrypt(data: plainTextData, password: passwordKey!)
        
        return cipherTextData
    }
    
    // Open data that has been read from a file
    override func read(from data: Data, ofType typeName: String) throws {
        var attributes = [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
        let attributesPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>(&attributes)
        
        // FIXME: Remove the next line when password asking is properly implemented
        passwordKey = ""
        
        // Decrypt the given data
        let plainTextData = LJDecrypt(data: data, password: passwordKey!)
        
        // Create a new text storage for the document to load once the nib is loaded
        textStorageToLoad = NSTextStorage.init(rtfd: plainTextData,
                                               documentAttributes: attributesPointer)
    }
    
    @IBAction func setPassword(_ sender: AnyObject) {
        let givenPassword = passwordField!.stringValue
        // Validate the password
        if (givenPassword.characters.count < 8) {
            // Passwords must be at least 8 characters long
            errorLabel.isHidden = false
            errorLabel.stringValue = "Password must be at least 8 characters long"
        } else if (passwordField!.stringValue != confirmPasswordField!.stringValue) {
            errorLabel.isHidden = false
            errorLabel.stringValue = "Passwords don't match"
        } else {
            // Everything is in order, set the password
            passwordKey = givenPassword
            windowForSheet!.endSheet(setPasswordSheet!)
        }
    }
    
    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        
        // Load textStorageToLoad if it exists
        if (textStorageToLoad != nil) {
            textView!.layoutManager!.replaceTextStorage(textStorageToLoad!)
        }
        
        // Ask the user to set a password if we haven't already
        if (passwordKey == nil) {
            if (setPasswordSheet == nil) {
                Bundle.main.loadNibNamed("LJSetPasswordDialog", owner: self, topLevelObjects: nil)
            }
            
            windowController.showWindow(self)
            windowForSheet!.beginSheet(setPasswordSheet!, completionHandler: nil)
        }
    }

    // Returns the nib file name of the document
    override var windowNibName: String? {
        return "DocumentWindow"
    }
}

