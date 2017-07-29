//
//  Digit_RecognitionTests.swift
//  Digit RecognitionTests
//
//  Created by Edward Huang on 7/27/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import XCTest
@testable import Digit_Recognition
class Digit_RecognitionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let nn = FCNeuralNetwork(input: 1, output: 1, hiddenLayers: 1)
        
        let s1 = nn.sigmoid(weights: [1], input: [0])
        let s2 = nn.sigmoid(weights: [1], input: [1])
        let s3 = nn.sigmoid(weights: [1], input: [-1])
        
        XCTAssert(s1 == 0.5, "s1: \(s1)")
        XCTAssert(s2 > 0.5, "s2: \(s2)")
        XCTAssert(s3 < 0.5, "s2: \(s3)")
        
    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}