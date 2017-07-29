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
    
    private var weights: [[[Double]]]

    // Regularization term
    private let lambda = 0.005
    
    private var trainingSet = [(input: [UInt8], correctOutput: Int)]()
    
    /// Node values for all layers, including input and output
    private var nodes: [[Double]]

    
    
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
        // TODO: implement
        
        var oldCost = 0.0
        var newCost = 0.0
        
        repeat {
            oldCost = costFunction()
            
            
            // forward pass
            
            
            // backpropogate
            
            newCost = costFunction()
            print(newCost)
        } while oldCost - newCost > 1E-10
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
    
    
    private func backpropogate() -> [[[Double]]] {
        
        // zero out capitalDelta
        var capitalDelta = weights
        for l in 0..<capitalDelta.count {
            for i in 0..<capitalDelta[l].count {
                for j in 0..<capitalDelta[l][i].count {
                    capitalDelta[l][i][j] = 0.0
                }
            }
        }
        
        
        var delta = nodes
        
        
        // this is where we will store the partial derivatives
        var D = capitalDelta
        
        // number of layers
        let L = hiddenLayerSizes.count + 2
        
        // number of training entries
        let m = trainingSet.count
        
        for trainingEntry in trainingSet {
            
            let input = trainingEntry.input
            
            forwardPass(input: input)
            
            let correctOutput = trainingEntry.correctOutput
            var correctOutputVector = [Double].init(repeating: 0, count: outputSize)
            correctOutputVector[correctOutput] = 1
            
            
            // calculate the deltas. Note that delta[0] is meaningless
            
            delta[L] = vectorSubtract(v1: correctOutputVector, from: nodes[L])
            
            for i in (1..<L-1).reversed() {
                
                let weightMatrix = weights[i]
                
                let transposedWeightMatrix = transpose(matrix: weightMatrix)
                
                let firstPart = matrixMultiply(matrix: transposedWeightMatrix, vector: delta[i+1])
                
                let secondPart = gPrime(layerIndex: i)
                
                delta[i] = entrywiseMultiply(firstPart, secondPart)
            }
            
            // update the capitalDeltas
            for l in 0..<L {
                var capitalDeltaMatrix = capitalDelta[l]
                
                for i in 0..<capitalDeltaMatrix.count {
                    for j in 0..<capitalDeltaMatrix[i].count {
                        capitalDeltaMatrix[i][j] += nodes[l][j] * delta[l+1][i]
                    }
                }
                
                capitalDelta[l] = capitalDeltaMatrix
            }
        }
        
        // get the D!! (pun intended)
        for l in 0..<L-1 {
            for i in 0..<D[l].count {
                for j in 0..<D[l][i].count {
                    
                    if j == 0 {
                        D[l][i][j] = 1 / Double(m) * (capitalDelta[l][i][j] + lambda * weights[l][i][j])
                    } else {
                        D[l][i][j] = 1 / Double(m) * (capitalDelta[l][i][j])
                    }
                }
            }
        }
        
        
        return D
    }
    
    
    /// Checks that backpropogation works correctly
    ///
    /// - Returns: True if it works, false if it doesn't
    func gradientCheck() -> Bool {
        
        let D = backpropogate()
        
        let originalWeights = weights
        
        let epsilon = 1E-4
        
        var gradApprox = weights
        
        let L = hiddenLayerSizes.count + 1
        
        for l in 0..<L {
            for i in 0..<weights[l].count {
                for j in 0..<weights[l][i].count {
                    weights[l][i][j] += epsilon
                    
                    let costPlus = costFunction()
                    
                    weights[l][i][j] -= 2*epsilon
                    
                    let costMinus = costFunction()
                    
                    gradApprox[l][i][j] = (costPlus - costMinus) / (2*epsilon)
 
                }
            }
        }
        
        // compare gradApprox to D
        var largestDifference = 0.0
        for l in 0..<L {
            for i in 0..<weights[l].count {
                for j in 0..<weights[l][i].count {
                    
                    let diff = abs(D[l][i][j] - gradApprox[l][i][j])
                    
                    if diff > largestDifference {
                        largestDifference = diff
                    }
                }
            }
        }
        
        print("gradient checking. largest difference: \(largestDifference)")

        weights = originalWeights
        
        
        return largestDifference <= epsilon
    }
    
    
    /// Tells us how well our neural network performs on the training set
    ///
    /// - Returns: cost function value
    func costFunction() -> Double {
        
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
            
            let k = actual.count
            
            for i in 0..<k {
                
                let predictedNodeValue = predicted[i]
                let actualNodeValue = actual[i]
                
                ret += actualNodeValue * log(predictedNodeValue) + (1-actualNodeValue) * log(1.0 - predictedNodeValue)
                
            }
        }
        let m = Double(results.count)
        ret = ret * (-1 / m)
        
        print("normal part: \(ret)")
        
        // regularization
        var regularization = 0.0
        for weightMatrix in weights {
            let width = weightMatrix[0].count
            let height = weightMatrix.count
            
            for i in 1..<height {
                // excluding the bias unit
                for j in 0..<width {
                    
                    let theta = weightMatrix[i][j]
                    
                    regularization += theta * theta
                }
            }
        }
        regularization = regularization * (2 * lambda / m)
        
        
        
        // add the regularization
        ret += regularization
        
        
        return ret
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
    
    
    /// Computes v2 - v1
    ///
    /// - Parameters:
    ///   - v1:
    ///   - v2:
    private func vectorSubtract(v1: [Double], from v2: [Double]) -> [Double] {
        
        guard v1.count == v2.count else {
            fatalError("bad input for vector subtract")
        }
        
        var ret = v2
        
        let n = v1.count
        for i in 0..<n {
            ret[i] -= v1[i]
        }
        return ret
    }
    
    private func transpose(matrix: [[Double]]) -> [[Double]] {
        var ret = [[Double]]()
        
        let height = matrix.count
        let width = matrix[0].count
        
        for j in 0..<width {
            var column = [Double]()
            for i in 0..<height {
                column.append(matrix[i][j])
            }
            
            ret.append(column)
        }
        
        guard ret.count == width && ret[0].count == height else {
            fatalError("transpose is incorrect")
        }
        
        return ret
    }
    
    private func matrixMultiply(matrix: [[Double]], vector: [Double]) -> [Double] {
        guard matrix[0].count == vector.count else {
            fatalError("bad arguments for matrix multiply")
        }
        
        var ret = [Double]()
        
        for row in matrix {
            
            let ewm = entrywiseMultiply(row, vector)
            
            let dotProduct = sum(ewm)
            
            ret.append(dotProduct)
        }
        return ret
    }
    private func entrywiseMultiply(_ v1: [Double], _ v2: [Double]) -> [Double] {
        guard v1.count == v2.count else {
            fatalError("bad arguments for entrywise multiply")
        }
        
        var ret = v1
        for i in 0..<v1.count {
            ret[i] *= v2[i]
        }
        
        return ret
    }
    
    private func sum(_ v: [Double]) -> Double {
        var s = 0.0
        
        for value in v {
            s += value
        }
        return s
    }
    
    private func gPrime(layerIndex: Int) -> [Double] {
        
        let a = nodes[layerIndex]
        
        var ret = [Double]()
        
        for i in 0..<a.count {
            let value = a[i] * (1 - a[i])
            ret.append(value)
        }
        
        return ret
    }
}

