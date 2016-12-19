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
    
    @IBOutlet weak private var textView: NSTextView!
    
    @IBOutlet var setPasswordSheet: NSWindow!
    @IBOutlet weak var setPasswordField: NSSecureTextField!
    @IBOutlet weak var confirmPasswordField: NSSecureTextField!
    @IBOutlet weak var setPasswordErrorLabel: NSTextField!
    @IBOutlet weak var setPasswordOKButton: NSButton!
    
    @IBOutlet var enterPasswordSheet: NSWindow!
    @IBOutlet weak var enterPasswordField: NSSecureTextField!
    @IBOutlet weak var enterPasswordErrorLabel: NSTextField!
    @IBOutlet weak var enterPasswordOKButton: NSButton!
    
    private var passwordKey: String?
    private var dataToLoad: Data?
    
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
    
    @IBAction func cancelEnterPassword(_ sender: AnyObject) {
        windowForSheet!.endSheet(enterPasswordSheet)
        close()
    }
    
    @IBAction func cancelSetPassword(_ sender: AnyObject) {
        windowForSheet!.endSheet(setPasswordSheet)
        close()
    }
    
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return true
    }
    
    // This function is called when the enterPasswordField, setPasswordField or
    // confirmPassordField's text contents changes.
    override func controlTextDidChange(_ obj: Notification) {
        
        // Call appropriate helper method depending on which text field was altered
        if obj.object as! NSSecureTextField === enterPasswordField {
            enterPasswordFieldTextDidChange()
        } else if obj.object as! NSSecureTextField === setPasswordField
                  || obj.object as! NSSecureTextField === confirmPasswordField {
            setPasswordFieldsTextDidChange()
        }
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
    
    private func enterPasswordFieldTextDidChange() {
        // Only allow the user to click the OK button if a password has been entered
        if (enterPasswordField.stringValue != "") {
            enterPasswordOKButton.isEnabled = true
        } else {
            enterPasswordOKButton.isEnabled = false
        }
    }
    
    // Decrypt data with given password and validate it, then close the dialog
    @IBAction func passwordEntered(_ sender: AnyObject) {
        
        passwordKey = enterPasswordField.stringValue
        
        // Decrypt the data with the given password
        do {
            let plainTextData = try LJDecrypt(data: dataToLoad!, password: passwordKey!)
            
            windowForSheet!.endSheet(enterPasswordSheet)
            
            var attributes = [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
            let attributesPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>(&attributes)
            let textStorageToLoad = NSTextStorage.init(rtfd: plainTextData,
                                                       documentAttributes: attributesPointer)
            textView!.layoutManager!.replaceTextStorage(textStorageToLoad!)
            
        } catch {
            // The password is incorrect
            enterPasswordErrorLabel.stringValue = "Incorrect password"
            enterPasswordErrorLabel.isHidden = false
        }
    }
    
    // Open data that has been read from a file
    override func read(from data: Data, ofType typeName: String) throws {
        dataToLoad = data
    }
    
    @IBAction func setPassword(_ sender: AnyObject) {
        
        let givenPassword = setPasswordField!.stringValue
        
        // Validate the password
        if givenPassword.characters.count < 8 {
            // Passwords must be at least 8 characters long
            setPasswordErrorLabel.stringValue = "Password must be at least 8 characters long"
            setPasswordErrorLabel.isHidden = false
            
        } else if givenPassword != confirmPasswordField!.stringValue {
            // The password must be the same in both fields
            setPasswordErrorLabel.stringValue = "Passwords don't match"
            setPasswordErrorLabel.isHidden = false
            
        } else {
            // Everything is in order, set the password
            passwordKey = givenPassword
            
            windowForSheet!.endSheet(setPasswordSheet!)
        }
    }
    
    private func setPasswordFieldsTextDidChange() {
        // Only allow the user to click the OK button if a password has been entered
        if (setPasswordField.stringValue != "" && confirmPasswordField.stringValue != "") {
            setPasswordOKButton.isEnabled = true
        } else {
            setPasswordOKButton.isEnabled = false
        }
    }
    
    private func showEnterPasswordSheet() {
        
        // Load the password sheet xib file if it isn't loaded already
        if enterPasswordSheet == nil {
            Bundle.main.loadNibNamed("EnterPasswordDialog", owner: self, topLevelObjects: nil)
        }
        
        windowForSheet!.beginSheet(enterPasswordSheet!, completionHandler: nil)
    }
    
    private func showSetPasswordSheet() {
        
        // Load the password sheet xib file if it isn't loaded already
        if setPasswordSheet == nil {
            Bundle.main.loadNibNamed("SetPasswordDialog", owner: self, topLevelObjects: nil)
        }
        
        windowForSheet!.beginSheet(setPasswordSheet!, completionHandler: nil)
    }

    override func makeWindowControllers() {
        
        let documentWindowController = NSWindowController.init(windowNibName: "DocumentWindow",
                                                               owner: self)
        addWindowController(documentWindowController)
        
        // Make the window visible before opening a sheet
        documentWindowController.showWindow(self)
        
        if dataToLoad == nil {
            // If there is no data to load then we are creating a new document and need to ask the
            // user to set a password for the new document.
            showSetPasswordSheet()
            
        } else {
            // We are opening a file, ask for its password
            showEnterPasswordSheet()
        }
    }
}

