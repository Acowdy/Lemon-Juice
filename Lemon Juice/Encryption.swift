//
//  Encryption.swift
//  Lemon Juice
//
//  Created by Adam Cowdy on 17/12/2016.
//  Copyright © 2016 Adam Cowdy. All rights reserved.
//

import Cocoa
import Security

enum LJEncryptionError {
    case incorrectPassword
}

public func LJDecrypt(data cipherTextData: Data, password passwordKey: String) throws -> Data {
    // TODO: Implement this function
    return cipherTextData
}

public func LJEncrypt(data plainTextData: Data, password passwordKey: String) -> Data {
    // TODO: Implement this function
    return plainTextData
}
