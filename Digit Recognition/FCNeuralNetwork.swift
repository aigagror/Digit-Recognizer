//
//  NeuralNetwork.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/27/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import Foundation

let dimension = 16
let neuralNetwork = FCNeuralNetwork(input: dimension * dimension, output: 10, hiddenLayers: 100, 100)

/// A fully connected neural network
class FCNeuralNetwork {
    
    // MARK: Properties
    
    let inputSize: Int
    let outputSize: Int
    let hiddenLayerSizes: [Int]
    
    private var weights: [[[Double]]]

    // Regularization term
    private let lambda = 0.00005
    
    private var trainingSet = [(input: [Double], correctOutput: Int)]()
    
    /// Node values for all layers, including input and output
    private var nodes: [[Double]]

    var delegate: NeuralNetworkDelegate? = nil
    
    
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
    
   
    
    
    // MARK: Neural Network Functions
    
    func predict(bitmap: [[Double]]) -> [Double] {
        
        var input = [Double]()
        
        for row in bitmap {
            for value in row {
                input.append(value)
            }
        }
        let prediction = forwardPass(input: input)
        
        return prediction
    }
    
    
    
    
    
    /// This function optimizes the weights
    func train() -> Void {
        let alpha = 0.5
        
        var oldCost = 0.0
        var newCost = 0.0
        
        var progress = 0.0
        
        repeat {
            oldCost = newCost
            
            
            // backpropogate
            let D = backpropogate()
            
            let L = hiddenLayerSizes.count + 2
            for l in 0..<L-1 {
                for i in 0..<weights[l].count {
                    for j in 0..<weights[l][i].count {
                        
                        let d = D[l][i][j]
                        
                        weights[l][i][j] -= alpha * d
                    }
                }
            }
            
            
            newCost = costFunction()
            
            progress = abs(oldCost - newCost)
            
            if let delegate = delegate {
                delegate.trainingProgressUpdate(progress: min(1E-2 / progress, 1.0))
            }
            
        } while progress > 1E-2
        
        print("Done training")
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
        
        
        var delta = [[Double]]()
        delta.append([Double].init(repeating: 0.0, count: inputSize))
        for size in hiddenLayerSizes {
            delta.append([Double].init(repeating: 0.0, count: size))
        }
        delta.append([Double].init(repeating: 0.0, count: outputSize))
        
        
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
            
            delta[L-1] = vectorSubtract(v1: correctOutputVector, from: nodes[L-1])
            
            for i in (1..<L-1).reversed() {
                
                let weightMatrix = weights[i]
                
                let transposedWeightMatrix = transpose(matrix: weightMatrix)
                
                var firstPart = matrixMultiply(matrix: transposedWeightMatrix, vector: delta[i+1])
                
                firstPart.removeFirst()
                
                let secondPart = gPrime(layerIndex: i)
                
                delta[i] = entrywiseMultiply(firstPart, secondPart)
            }
            
            // update the capitalDeltas
            for l in 0..<L-1 {
                for i in 0..<capitalDelta[l].count {
                    var a = [1.0]
                    a.append(contentsOf: nodes[l])
                    
                    for j in 0..<capitalDelta[l][i].count {
                        capitalDelta[l][i][j] += a[j] * delta[l+1][i]
                    }
                }
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
                    
                    weights[l][i][j] = originalWeights[l][i][j]
 
                }
            }
        }
        
        // compare gradApprox to D
        var largestRelativeError = 0.0
        var largestAbsoluteError = 0.0
        var detectedOppositeSigns = false
        for l in 0..<L {
            for i in 0..<weights[l].count {
                for j in 0..<weights[l][i].count {
                    
                    let d = D[l][i][j]
                    let ga = gradApprox[l][i][j]
                    
                    let relErr = abs((d - ga) / ga)
                    let absErr = abs((d - ga))
                    
                    if d*ga < 0 {
                        detectedOppositeSigns = true
                    }
                    
                    if relErr > largestRelativeError && relErr != Double.infinity {
                        largestRelativeError = relErr
                    }
                    if absErr > largestAbsoluteError {
                        largestAbsoluteError = absErr
                    }
                }
            }
        }
        
        print("gradient checking. largest absErr: \(largestAbsoluteError). largest relErr: \(largestRelativeError)")

        weights = originalWeights
        
        if detectedOppositeSigns {
            print("Detected opposite signs")
        }
        
        return largestRelativeError <= epsilon && detectedOppositeSigns == false
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
        
        print("normal: \(ret)", separator: "", terminator: "\t")
        
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
        
        print("reg: \(regularization)", separator: "", terminator: "\t")
        
        // add the regularization
        ret += regularization
        
        print("total: \(ret)")
        
        return ret
    }
    
    // MARK: Helper functions
    
    func removeLastTrainingEntry() -> Void {
        trainingSet.removeLast()
    }
    
    /// Shows an example of a bitmap from the training set
    func showBitMap() -> Void {
        guard let entry = trainingSet.last else {
            print("training set is empty :(")
            return
        }
        
        let input = entry.input
        
        let dimension = Int(sqrt(Double(input.count)))
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                print(Int((input[i*dimension + j]*100.0).rounded()), separator: "", terminator: "\t")
            }
            print("\n")
        }
    }
    
    func addToTrainingSet(trainingData: (input: [Double], correctOutput: Int)) -> Void {
        
        guard trainingData.input.count == dimension*dimension else {
            fatalError("incorrect dimensions")
        }
        
        self.trainingSet.append(trainingData)
    }
    
    func addToTrainingSet(image: [[Double]], correctOutput: Int) -> Void {
        
        var newInput = [Double]()
        
        for row in image {
            for value in row {
                newInput.append(value)
            }
        }
        
        addToTrainingSet(trainingData: (newInput, correctOutput: correctOutput))
    }
    
    private func sigmoid(weights: [Double], input: [Double]) -> Double {
        
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

