//
//  Encryption.swift
//  Lemon Juice
//
//  Created by Adam Cowdy on 17/12/2016.
//  Copyright © 2016 Adam Cowdy. All rights reserved.
//

import Cocoa
import Security

enum LJEncryptionError : Error {
    case incorrectPassword
    case keyGenerationFailed
    case encryptionFailed
}

extension LJEncryptionError {
    var localizedDescription: String {
        switch self {
        case .incorrectPassword:
            return "Incorrect password"
        case .keyGenerationFailed:
            return "Key generation failed"
        case .encryptionFailed:
            return "Performing encryption failed"
        }
    }
}

func generateKey(password: String) throws -> SecKey {
    var keyErrorPtr: Unmanaged<CFError>? = nil
    let keySize = 256 as CFNumber
    let keyParameters: [String: Any] = [
        kSecAttrKeyType as String: kSecAttrKeyTypeAES,
        kSecAttrSalt as String: CFDataCreate(nil, [0], 0),
        kSecAttrKeySizeInBits as String: keySize
    ]
    let key = SecKeyDeriveFromPassword(password as CFString,
                                       keyParameters as CFDictionary,
                                       &keyErrorPtr)
    
    // Check for errors in key generation
    guard keyErrorPtr == nil else {
        throw LJEncryptionError.keyGenerationFailed
    }
    
    return key!
}

public func LJDecrypt(data cipherTextData: Data, password: String) throws -> Data {
    // Generate a key
    let key = try generateKey(password: password)
    
    var decryptionErrorPtr: Unmanaged<CFError>? = nil
    
    let decryptTransform = SecDecryptTransformCreate(key, &decryptionErrorPtr)
    
    // Set the padding
    SecTransformSetAttribute(decryptTransform, kSecPaddingKey,
                             kSecPaddingPKCS7Key, &decryptionErrorPtr)
    
    let cipherTextBytes = [UInt8](cipherTextData)
    let cipherTextCFData = CFDataCreate(kCFAllocatorDefault, cipherTextBytes,
                                        cipherTextBytes.count)!
    
    // Set the input
    SecTransformSetAttribute(decryptTransform, kSecTransformInputAttributeName, cipherTextCFData,
                             &decryptionErrorPtr)
    
    // Perform the decryption, type annotation provided for clarity
    let plainTextDataRef = SecTransformExecute(decryptTransform, &decryptionErrorPtr)
    
    // Check for errors in performing the decryption
    guard decryptionErrorPtr == nil else {
        // If something goes wrong, assume password was incorrect
        throw LJEncryptionError.incorrectPassword
    }
    
    return plainTextDataRef as! Data
}

public func LJEncrypt(data plainTextData: Data, password: String) throws -> Data {
    // Generate a key
    let key = try generateKey(password: password)
    
    var encryptionErrorPtr: Unmanaged<CFError>? = nil
    
    // Create an encryption transform
    let encryptTransform = SecEncryptTransformCreate(key, &encryptionErrorPtr)
    
    // Set the padding
    SecTransformSetAttribute(encryptTransform, kSecPaddingKey,
                             kSecPaddingPKCS7Key, &encryptionErrorPtr)
    
    let plainTextBytes = [UInt8](plainTextData)
    let plainTextCFData = CFDataCreate(kCFAllocatorDefault, plainTextBytes,
                                       plainTextBytes.count)!
    
    // Set the input
    SecTransformSetAttribute(encryptTransform, kSecTransformInputAttributeName, plainTextCFData,
                             &encryptionErrorPtr)
    
    // Perform the encryption
    let cipherTextDataRef = SecTransformExecute(encryptTransform, &encryptionErrorPtr)
    
    // Check for errors in performing the encryption
    guard encryptionErrorPtr == nil else {
        throw LJEncryptionError.encryptionFailed
    }
    
    return cipherTextDataRef as! Data
}
