//
//  LJDocument.swift
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
    private var encryptedDataToLoad: Data?
    
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
        let senderTextField = obj as! NSSecureTextField
        
        // Call appropriate helper method depending on which text field was altered
        if senderTextField === enterPasswordField {
            enterPasswordFieldTextDidChange()
        } else if senderTextField === setPasswordField || senderTextField === confirmPasswordField {
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
    
    // Convert the given data to a NSTextStorage object and load it to the NSTextView for this
    // document. Note that the argument to this function must be plaintext data.
    private func loadData(_ data: Data) {
        var attributes = [NSDocumentTypeDocumentAttribute: NSRTFDTextDocumentType]
        let attributesPointer = AutoreleasingUnsafeMutablePointer<NSDictionary?>(&attributes)
        let textStorageToLoad = NSTextStorage.init(rtfd: data,
                                                   documentAttributes: attributesPointer)
        
        textView!.layoutManager!.replaceTextStorage(textStorageToLoad!)
    }
    
    // Decrypt data with given password and validate it, then close the dialog
    @IBAction func passwordEntered(_ sender: AnyObject) {
        passwordKey = enterPasswordField.stringValue
        
        // Decrypt the data with the given password
        do {
            let plainTextData = try LJDecrypt(data: encryptedDataToLoad!, password: passwordKey!)
            loadData(plainTextData)
            
            windowForSheet!.endSheet(enterPasswordSheet)
            
        } catch {
            // The password is incorrect
            enterPasswordErrorLabel.stringValue = "Incorrect password"
            enterPasswordErrorLabel.isHidden = false
        }
    }
    
    // Open data that has been read from a file
    override func read(from data: Data, ofType typeName: String) throws {
        encryptedDataToLoad = data
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
        
        if encryptedDataToLoad == nil {
            // If there is no data to load then we are creating a new document and need to ask the
            // user to set a password for the new document.
            showSetPasswordSheet()
            
        } else {
            // We are opening a file, ask for its password
            showEnterPasswordSheet()
        }
    }
}

