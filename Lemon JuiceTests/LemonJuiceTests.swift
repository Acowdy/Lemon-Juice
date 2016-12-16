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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
//    func testEncryptionAndDecryption() {
//        let doc = Document.init()
//        let key = "password12345"
//        let plainTextData = "Hello world".data(using: String.Encoding.unicode)
//        
//        // TODO: implement the methods encrypt(data: password: ) and decrypt(data: password: ) in
//        // the Document class
//        
//        let cipherTextData = doc.encrypt(data: plainTextData, password: key)
//        
//        let decryptedPlainTextData = doc.decrypt(data: cipherTextData, password: key)
//        let decryptedPlainText = String.init(data: decryptedPlainTextData,
//                                             encoding: String.Encoding.unicode)
//        
//        XCTAssert(decryptedPlainTextData == plainTextData,
//                  "The decrypted plaintext does not match the original plaintext")
//    }
    
//    func testEncryptionPerformance() {
//        let doc = Document.init()
//        let key = "password12345"
//        let plainTextData = "Hello world".data(using: String.Encoding.unicode)
//        
//        self.measure {
//            // TODO
//        }
//    }
    
}
