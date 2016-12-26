//
//  Encryption.swift
//  Lemon Juice
//
//  Created by Adam Cowdy on 17/12/2016.
//  Copyright © 2016 Adam Cowdy. All rights reserved.
//

import Cocoa
import Security

// These bytes are inserted at the beginning of the data before it is encrypted. When you decrypt
// the data again, you can tell if we used the right password if these bytes are present at the
// beginning of the decrypted data.
let LJ_MAGIC_BYTES: [UInt8] = [107, 148, 226, 29]

enum LJEncryptionError: Error {
    case incorrectPassword
}

public func LJDecrypt(data cipherTextData: Data, password passwordKey: String) throws -> Data {
    // Generate a key
    var keyErrorPtr: Unmanaged<CFError>? = nil
    let keySize = 256 as CFNumber
    let keyParameters: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeAES,
        kSecAttrSalt as String: CFDataCreate(nil, [0], 0),
        kSecAttrKeySizeInBits as String: keySize
    ]
    let key = SecKeyDeriveFromPassword(passwordKey as CFString,
                                       keyParameters as CFDictionary,
                                       &keyErrorPtr)!
    
    // Check for errors in key generation
    guard keyErrorPtr == nil else {
        // Exit if the key can't be generated, this shouldn't happen
        fatalError("Error generating key: " + keyErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    var decryptionErrorPtr: Unmanaged<CFError>? = nil
    
    // Create an decryption transform
    let decryptTransform = SecDecryptTransformCreate(key, &decryptionErrorPtr)
    
    // Check for errors in creating the decrypt transform
    guard decryptionErrorPtr == nil else {
        fatalError("Error creating decryption transform: "
                   + decryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    // Set the padding
    SecTransformSetAttribute(decryptTransform, kSecPaddingKey,
                             kSecPaddingPKCS7Key, &decryptionErrorPtr)
    
    // Check for errors in setting the transform attribute
    guard decryptionErrorPtr == nil else {
        fatalError("Error setting decryption transform attribute: "
            + decryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    let cipherTextCFData = CFDataCreate(kCFAllocatorDefault, [UInt8](cipherTextData),
                                       [UInt8](cipherTextData).count)!
    
    // Set the input
    SecTransformSetAttribute(decryptTransform, kSecTransformInputAttributeName, cipherTextCFData,
                             &decryptionErrorPtr)
    
    // Check for errors in setting the transform attribute
    guard decryptionErrorPtr == nil else {
        fatalError("Error setting decryption transform attribute: "
              + decryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    // Perform the decryption, type annotation provided for clarity
    let plainTextDataRef: CFTypeRef = SecTransformExecute(decryptTransform, &decryptionErrorPtr)
    
    // Check for errors in performing the encryption
    guard decryptionErrorPtr == nil else {
        // If something goes wrong, assume password was incorrect
        throw LJEncryptionError.incorrectPassword
    }
    
    return plainTextDataRef as! Data
}

public func LJEncrypt(data plainTextData: Data, password passwordKey: String) -> Data {
    // Generate a key
    var keyErrorPtr: Unmanaged<CFError>? = nil
    let keySize = 256 as CFNumber
    let keyParameters: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeAES,
        kSecAttrSalt as String: CFDataCreate(nil, [0], 0),
        kSecAttrKeySizeInBits as String: keySize
    ]
    let key = SecKeyDeriveFromPassword(passwordKey as CFString,
                                       keyParameters as CFDictionary,
                                       &keyErrorPtr)!
    
    // Check for errors in key generation
    guard keyErrorPtr == nil else {
        // Exit if the key can't be generated, this shouldn't happen
        fatalError("Error generating key: " + keyErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    var encryptionErrorPtr: Unmanaged<CFError>? = nil
    
    // Create an encryption transform
    let encryptTransform = SecEncryptTransformCreate(key, &encryptionErrorPtr)
    
    // Check for errors in creating the encrypt transform
    guard encryptionErrorPtr == nil else {
        fatalError("Error creating encryption transform: "
              + encryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    // Set the padding
    SecTransformSetAttribute(encryptTransform, kSecPaddingKey,
                             kSecPaddingPKCS7Key, &encryptionErrorPtr)
    
    // Check for errors in setting the transform attribute
    guard encryptionErrorPtr == nil else {
        fatalError("Error setting encryption transform attribute: "
            + encryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    let plainTextBytes = [UInt8](plainTextData)
    
    // Create a representation of plainTextBytes that can be used as an argument to
    // SecTransformSetAttribute.
    let plainTextCFData = CFDataCreate(kCFAllocatorDefault, plainTextBytes,
                                       plainTextBytes.count)!
    
    // Set the input
    SecTransformSetAttribute(encryptTransform, kSecTransformInputAttributeName, plainTextCFData,
                             &encryptionErrorPtr)
    
    // Check for errors in setting the transform attribute
    guard encryptionErrorPtr == nil else {
        fatalError("Error setting encryption transform attribute: "
            + encryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    // Perform the encryption
    let cipherTextData = SecTransformExecute(encryptTransform, &encryptionErrorPtr) as! Data
    
    // Check for errors in performing the encryption
    guard encryptionErrorPtr == nil else {
        fatalError("Error performing encryption: "
            + encryptionErrorPtr!.takeRetainedValue().localizedDescription)
    }
    
    return cipherTextData
}
