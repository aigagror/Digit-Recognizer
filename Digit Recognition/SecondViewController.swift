//
//  SecondViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit


class SecondViewController: UIViewController, CanvasViewDelegate, NeuralNetworkDelegate {

    @IBOutlet weak var entryCountLabel: UILabel!
    
    @IBOutlet weak var stopperView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func removeLastPressed(_ sender: UIButton) {
        
        neuralNetwork.removeLastTrainingEntry()
        let entries = neuralNetwork.numberOfTrainingEntries()
        entryCountLabel.text = "\(entries)"
        
        segmentController.selectedSegmentIndex = segmentController.selectedSegmentIndex == 0 ? 9 : segmentController.selectedSegmentIndex - 1
        
    }
    
    @IBAction func removeAllPressed(_ sender: UIButton) {
        
        neuralNetwork.clearTrainingSet()
    }
    
    
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let bitMap = canvas.getCroppedBitMap(dimension: dimension) {
            neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }

        canvas.reset()
    }
    @IBAction func trainPressed(_ sender: UIButton) {
        stopperView.isHidden = false
        progressView.setProgress(0.0, animated: true)
        
        let trainQueue = DispatchQueue(label: "trainQueue")
        trainQueue.async {
            neuralNetwork.train()
        }
    }
    
    @IBAction func showBitmapPressed(_ sender: UIButton) {
        
        neuralNetwork.showBitMap()
    }
    @IBAction func gradCheckPressed(_ sender: UIButton) {
        
        neuralNetwork.gradientCheck()
        
    }
    
    func userDidFinishWriting() {
        if let bitMap = canvas.getCroppedBitMap(dimension: dimension) {
            neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }
        
        segmentController.selectedSegmentIndex = segmentController.selectedSegmentIndex == 9 ? 0 : segmentController.selectedSegmentIndex + 1
        
        canvas.reset()
        
        let entries = neuralNetwork.numberOfTrainingEntries()
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
        neuralNetwork.delegate = self
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

