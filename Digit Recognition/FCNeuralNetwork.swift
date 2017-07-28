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
    
    // MARK: Properties
    
    let inputSize: Int
    let outputSize: Int
    let hiddenLayerSizes: [Int]
    
    var weights: [[[Double]]]
    
    var trainingSet = [(input: [UInt8], correctOutput: Int)]()
    
    /// Node values for all layers, including input and output
    var nodes: [[Double]]

    
    
    // MARK: Initialization
    init(input: Int, output: Int, hiddenLayers: Int...) {
        
        self.inputSize = input
        self.outputSize = output
        self.hiddenLayerSizes = hiddenLayers
    
        self.weights = [[[Double]]]()
        
        self.nodes = [[Double]]()

        
        // weight matrix for input
        var dimensions = (0,0)
        dimensions.1 = input + 1
        dimensions.0 = hiddenLayers.isEmpty ? output : hiddenLayers[0]
        
        let inputWeightMatrix = createMatrix(dimensions: dimensions)
        
        weights.append(inputWeightMatrix)
        
        
        // weight matrices for the hidden layers
        let numHiddenLayers = hiddenLayers.count
        
        if numHiddenLayers > 0 {
            
            for i in 0..<numHiddenLayers - 1 {
                dimensions.1 = hiddenLayers[i] + 1
                dimensions.0 = hiddenLayers[i+1]
                
                let hiddenWeightMatrix = createMatrix(dimensions: dimensions)
                
                weights.append(hiddenWeightMatrix)
            }
            
            // last weight matrix
            dimensions.1 = hiddenLayers[numHiddenLayers-1] + 1
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
    }
    
   
    
    
    // MARK: Functions
    
    func predict(bitmap: [[UInt8]]) -> [Double] {
        
        var input = [Double]()
        
        for row in bitmap {
            for value in row {
                input.append(Double(value))
            }
        }
        let prediction = forwardPass(input: input)
        
        return prediction
    }
    
    func addToTrainingSet(trainingData: (input: [UInt8], correctOutput: Int)) -> Void {
        self.trainingSet.append(trainingData)
    }
    
    func addToTrainingSet(image: [[UInt8]], correctOutput: Int) -> Void {
        
        var newInput = [UInt8]()
        
        for row in image {
            for value in row {
                newInput.append(value)
            }
        }
        
        addToTrainingSet(trainingData: (newInput, correctOutput: correctOutput))
    }
    
    
    
    /// This function optimizes the weights
    func train() -> Void {
        
        // TODO: Implement
        let cost = costFunction()
        print(cost)
        
        // forward pass

        
        // backpropogate
        
    }
    
    func forwardPass(input: [UInt8]) -> [Double] {
        
        var input2 = [Double].init(repeating: 0.0, count: inputSize)
        
        for i in 0..<inputSize {
            input2[i] = Double(input[i])
        }
        
        return forwardPass(input: input2)
    }
    
    /// AKA the predict function
    ///
    /// - Parameter input:
    /// - Returns: predicted output
    func forwardPass(input: [Double]) -> [Double] {
        guard input.count == inputSize else {
            fatalError("Incorrect dimension for forward pass")
        }
        
        nodes.removeAll()
        nodes.append(input)
        
        let numHiddenLayers = hiddenLayerSizes.count
        
        let numberOfIterations = numHiddenLayers + 1
        
        for i in 0..<numberOfIterations {
            let weightMatrix = weights[i]
            let inputNodes = nodes.last!
            
            let newLayer = forwardStep(weightMatrix: weightMatrix, nodes: inputNodes)
            
            nodes.append(newLayer)
        }
        
        return nodes.last!
    }
    
    private func backpropogate() -> Void {
        // TODO: Implement
    }
    
    
    /// Tells us how well our neural network performs on the training set
    ///
    /// - Returns: cost function value
    func costFunction() -> Double {
        
        let lambda = 1.0
        
        // TODO: Implement
        
        var results = [(predicted: [Double], actual: [Double])]()
        
        for trainData in trainingSet {
            let predicted = forwardPass(input: trainData.input)
            let correctOutput = trainData.correctOutput
            
            var correctOutputVector = [Double].init(repeating: 0.0, count: outputSize)
            correctOutputVector[correctOutput] = 1.0
            
            let resultData = (predicted: predicted, actual: correctOutputVector)
            
            results.append(resultData)
        }
        
        var ret = 0.0
        
        // normal part
        for result in results {
            
            let predicted = result.predicted
            let actual = result.actual
            
        }
        
        
        // regularization
        
        
        
        
        return 0.0
    }
    
    func sigmoid(weights: [Double], input: [Double]) -> Double {
        
        guard weights.count == input.count else {
            fatalError("Incorrect dimension of parameters for sigmoid")
        }
        
        let n = weights.count
        
        var dotProduct: Double = 0
        
        for i in 0..<n {
            dotProduct += weights[i] * input[i]
        }
        
        return 1 / (1 + exp(-dotProduct))
    }
    
    // MARK: Private functions
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
        return Double(arc4random()) / Double(UINT32_MAX) * M_E * 2 - M_E
    }
    
    /// Matrix multiples weight matrix with nodes (including a bias node of 1 at the beginning)
    ///
    /// - Parameters:
    ///   - weightMatrix:
    ///   - nodes:
    /// - Returns: result of the matrix multiplication
    private func forwardStep(weightMatrix: [[Double]], nodes: [Double]) -> [Double] {
        
        guard weightMatrix[0].count == nodes.count + 1 else {
            fatalError("incorrect dimensions: \(weightMatrix[0].count) vs \(nodes.count + 1)")
        }
        
        var nodesWithBias = [1.0]
        nodesWithBias.append(contentsOf: nodes)
        
        
        var ret = [Double]()
        
        for row in weightMatrix {
            ret.append(sigmoid(weights: row, input: nodesWithBias))
        }
        return ret
    }
}

