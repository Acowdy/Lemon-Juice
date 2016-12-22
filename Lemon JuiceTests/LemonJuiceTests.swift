//
//  LemonJuiceTests.swift
//  Lemon Juice Tests
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
        var key = "password12345"
        let plainTextData = "Hello world".data(using: String.Encoding.unicode)!
        
        // Encrypt the data
        let cipherTextData = LJEncrypt(data: plainTextData, password: key)
        
        var decryptedPlainTextData: Data?
        
        // Try to decrypt the data with an incorrect password
        key = "incorrectpassword"
        do {
            decryptedPlainTextData = try LJDecrypt(data: cipherTextData, password: key)
            XCTFail("Decryption with incorrect key didn't throw an exception")
            
        } catch LJEncryptionError.incorrectPassword {
            // Just continue
            print("Correct exception thrown")
            
        } catch {
            XCTFail("Decryption with incorrect key threw wrong exception")
        }
        
        // Try to decrypt the data with the correct password
        key = "password12345"
        do {
            decryptedPlainTextData = try LJDecrypt(data: cipherTextData, password: key)
            
        } catch {
            XCTFail("Decryption failed")
        }
        
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
    
    func testDencryptionPerformance() {
        let key = "password12345"
        var plainTextData = "Hello world".data(using: String.Encoding.unicode)!
        
        let cipherTextData = LJEncrypt(data: plainTextData, password: key)
        
        self.measure {
            do {
                try plainTextData = LJDecrypt(data: cipherTextData, password: key)
            } catch {
                // There should definitely not be any errors here...
                XCTFail("Decryption failed")
            }
        }
    }
    
}
