//
//  SecondViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit


class TrainViewController: UIViewController, CanvasViewDelegate, NeuralNetworkDelegate {

    @IBOutlet weak var entryCountLabel: UILabel!
    
    @IBOutlet weak var stopperView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func removeLastPressed(_ sender: UIButton) {
        
        FCNeuralNetwork.neuralNetwork.removeLastTrainingEntry()
        let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
        entryCountLabel.text = "\(entries)"
        
        segmentController.selectedSegmentIndex = segmentController.selectedSegmentIndex == 0 ? 9 : segmentController.selectedSegmentIndex - 1
        
    }
    
    @IBAction func removeAllPressed(_ sender: UIButton) {
        
        FCNeuralNetwork.neuralNetwork.clearTrainingSet()
        segmentController.selectedSegmentIndex = 0
        
        let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
        entryCountLabel.text = "\(entries)"
    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let bitMap = canvas.getCroppedBitMap(dimension: FCNeuralNetwork.dimension) {
            FCNeuralNetwork.neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }

        canvas.reset()
    }
    @IBAction func trainPressed(_ sender: UIButton) {
        stopperView.isHidden = false
        progressView.setProgress(0.0, animated: true)
        
        let trainQueue = DispatchQueue(label: "trainQueue")
        trainQueue.async {
            FCNeuralNetwork.neuralNetwork.train()
        }
    }
    
    @IBAction func showBitmapPressed(_ sender: UIButton) {
        
        FCNeuralNetwork.neuralNetwork.showBitMap()
    }
    @IBAction func gradCheckPressed(_ sender: UIButton) {
        
        FCNeuralNetwork.neuralNetwork.gradientCheck()
        
    }
    
    func userDidFinishWriting() {
        if let bitMap = canvas.getCroppedBitMap(dimension: FCNeuralNetwork.dimension) {
            FCNeuralNetwork.neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }
        
        segmentController.selectedSegmentIndex = segmentController.selectedSegmentIndex == 9 ? 0 : segmentController.selectedSegmentIndex + 1
        
        canvas.reset()
        
        let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
        entryCountLabel.text = "\(entries)"
    }
    
    func trainingProgressUpdate(progress: Double) {
        let progress = Float(progress)
        
        DispatchQueue.main.async {
            self.progressView.setProgress(progress, animated: true)
            
            if progress == 1.0 {
                self.stopperView.isHidden = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        FCNeuralNetwork.neuralNetwork.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        canvas.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

