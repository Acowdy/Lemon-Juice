//
//  Lemon_JuiceTests.swift
//  Lemon JuiceTests
//
//  Created by Adam Cowdy on 15/12/2016.
//  Copyright © 2016 Adam Cowdy. All rights reserved.
//

import XCTest
@testable import Lemon_Juice

class LemonJuiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEncryptionAndDecryption() {
        let key = "password12345"
        let plainTextData = "Hello world".data(using: String.Encoding.unicode)!
        
        let cipherTextData = LJEncrypt(data: plainTextData, password: key)
        let decryptedPlainTextData = LJDecrypt(data: cipherTextData, password: key)
        
        // Test that the decrypted data is the same as the original plaintext data
        XCTAssert(decryptedPlainTextData == plainTextData,
                  "The decrypted plaintext does not match the original plaintext")
    }
    
    func testEncryptionPerformance() {
        let key = "password12345"
        let plainTextData = "Hello world".data(using: String.Encoding.unicode)!
        
        self.measure {
            let _ = LJEncrypt(data: plainTextData, password: key)
        }
    }
    
}
