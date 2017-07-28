//
//  NeuralNetwork.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/27/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import Foundation

let neuralNetwork = FCNeuralNetwork(input: 784, output: 10, hiddenLayers: 300, 100)

/// A fully connected neural network
class FCNeuralNetwork {
    
    
    init(input: Int, output: Int, hiddenLayers: Int...) {
        
        self.input = input
        self.output = output
        self.hiddenLayers = hiddenLayers
        
        let numberOfLayers = 2 + hiddenLayers.count
        
        self.biases = [Double].init(repeating: 0, count: numberOfLayers - 1)
    
        self.weights = [[[Double]]]()
        
        self.currentHiddenLayerNodeValues = [[Double]]()

        
        for i in 0..<biases.count {
            self.biases[i] = random()
        }
        
        // weight matrix for input
        var dimensions = (0,0)
        dimensions.1 = input
        dimensions.0 = hiddenLayers.isEmpty ? output : hiddenLayers[0]
        
        let inputWeightMatrix = createMatrix(dimensions: dimensions)
        
        weights.append(inputWeightMatrix)
        
        
        // weight matrices for the hidden layers
        let numHiddenLayers = hiddenLayers.count
        
        if numHiddenLayers > 0 {
            
            for i in 0..<numHiddenLayers - 1 {
                dimensions.1 = hiddenLayers[i]
                dimensions.0 = hiddenLayers[i+1]
                
                let hiddenWeightMatrix = createMatrix(dimensions: dimensions)
                
                weights.append(hiddenWeightMatrix)
            }
            
            // last weight matrix
            dimensions.1 = hiddenLayers[numHiddenLayers-1]
            dimensions.0 = output
            
            let lastWeightMatrix = createMatrix(dimensions: dimensions)
            weights.append(lastWeightMatrix)
        }
        
        // print out weight matrices dimensions and bias dimension
        for weightMatrix in weights {
            let height = weightMatrix.count
            let width = weightMatrix[0].count
            
            print("(\(height) x \(width))", separator: "", terminator: "\t")
        }
        print("")
        print(biases.count)
        
        
        // setup currentHiddenLayerNodeValues
        for numNodesInThisLayer in hiddenLayers {
            let layer = [Double](repeatElement(0.0, count: numNodesInThisLayer))
            currentHiddenLayerNodeValues.append(layer)
        }
        
    }
    
    // MARK: Properties
    
    // the number of nodes for each layer
    let input: Int
    let output: Int
    let hiddenLayers: [Int]
    
    var weights: [[[Double]]]
    var biases: [Double]
    
    var currentHiddenLayerNodeValues: [[Double]]
    
    
    // MARK: Functions
    func train(input: [[UInt8]], output: Int) -> Void {
        // TODO: convert input into 1-d Int array and call the other train function
    }
    
    func train(input: [Int], output: Int) -> Void {
        
        var input2 = [Double].init(repeating: 0, count: input.count)
        
        for i in 0..<input.count {
            input2[i] = Double(input[i])
        }
        
        let numHiddenLayers = hiddenLayers.count
        
        // do the first hidden layer
        if numHiddenLayers > 0 {
            <#code#>
        }
        
        // do the rest of the middle
        if numHiddenLayers > 2 {
            <#code#>
        }
        
        // do the output layer
        if numHiddenLayers > 0 {
            <#code#>
        } else {
            
        }
        
        
        // backpropogate
        
        
    }
    
    func forward(input: [Double], output: Int) -> Void {
        <#function body#>
    }
    func backpropogate(correctOutput: Int) -> Void {
        <#function body#>
    }
    
    
    func sigmoid(weights: [Double], input: [Double]) -> Double {
        
        guard weights.count == input.count else {
            fatalError("Incorrect dimension of parameters for sigmoid")
        }
        
        let n = weights.count
        
        var dotProduct: Double = 0
        
        for i in 0..<n {
            dotProduct += weights[i] * input[0]
        }
        
        return 1 / (1 + exp(-dotProduct))
    }
    
    //MARK: Private functions
    private func createMatrix(dimensions: (Int, Int)) -> [[Double]] {
        var matrix = [[Double]].init(repeating: [Double].init(repeating: 0, count: dimensions.1), count: dimensions.0)
        
        let height = matrix.count
        let width = matrix[0].count
        
        for i in 0..<height {
            for j in 0..<width {
                matrix[i][j] = random()
            }
        }
        
        return matrix
    }
    
    private func random() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX)
    }
    
    private func forwardStep(weightMatrix: [[Double]], nodes: [Double]) -> [Double] {
        
        
        
        
        
    }
    
    
    
    
}

