//
//  TrainingSet.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/30/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import Foundation
import os.log

class TrainingSet: NSObject, NSCoding {
    
    // MARK: Properties
    let dimension: Int
    var entries = [(input: [Double], correctOutput: Int)]()
    
    init?(dimension: Int) {
        guard dimension > 0 else {
            return nil
        }
        
        self.dimension = dimension
        
        TrainingSet.ArchiveURL = TrainingSet.DocumentsDirectory.appendingPathComponent("\(dimension)")
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static var ArchiveURL: URL = TrainingSet.DocumentsDirectory.appendingPathComponent("0")
    
    // MARK: Types
    
    struct PropertyKey {
        static let dimension = "dimension"
        static let inputs = "inputs"
        static let outputs = "outputs"
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        
        // get the inputs and outputs into one big array
        var bigInput = [Double]()
        var bigOutput = [Int]()
        
        for entry in entries {
            let input = entry.input
            
            for value in input {
                bigInput.append(value)
            }
            
            bigOutput.append(entry.correctOutput)
        }
        
        
        aCoder.encode(bigInput, forKey: PropertyKey.inputs)
        aCoder.encode(bigOutput, forKey: PropertyKey.outputs)
        aCoder.encode(dimension, forKey: PropertyKey.dimension)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let dimension = aDecoder.decodeInteger(forKey: PropertyKey.dimension)
        
        guard let bigInput = aDecoder.decodeObject(forKey: PropertyKey.inputs) as? [Double] else {
            os_log("Unable to decode the inputs for the training entries", log: OSLog.default, type: .debug)
            return nil

        }
        guard let bigOutput = aDecoder.decodeObject(forKey: PropertyKey.outputs) as? [Int] else {
            os_log("Unable to decode the outputs for the training entries", log: OSLog.default, type: .debug)
            return nil
        }
        
        
        self.init(dimension: dimension)
        
        // determine the number of entries
        let numEntries = bigOutput.count
        
        for i in 0..<numEntries {
            var input = [Double]()
            let inputStartIndex = i * dimension * dimension
            let inputEndIndex = (i+1) * dimension * dimension
            
            for index in inputStartIndex..<inputEndIndex {
                
                let value = bigInput[index]
                
                input.append(value)
            }
            
            let output = bigOutput[i]
            
            let entry = (input: input, correctOutput: output)
            
            self.entries.append(entry)
        }
    }
    
}
