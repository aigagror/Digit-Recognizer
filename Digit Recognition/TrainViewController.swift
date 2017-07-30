//
//  SecondViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit


class TrainViewController: UIViewController, CanvasViewDelegate, NeuralNetworkDelegate {

    @IBOutlet weak var notifierView: UIView!
    @IBOutlet weak var notifierLabel: UILabel!
    @IBOutlet weak var entryCountLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    
    @IBAction func savePressed(_ sender: Any) {
        if FCNeuralNetwork.neuralNetwork.saveTrainingSet() {
            notifierLabel.text = "Training Set Saved"
            
            UIView.animate(withDuration: 2.0, animations: {
                self.notifierView.alpha = 0.0
                self.notifierView.alpha = 1.0
                self.notifierView.alpha = 0.0
            })
            
        }
    }
    
    @IBAction func loadPressed(_ sender: Any) {
        if FCNeuralNetwork.neuralNetwork.loadTrainingSet() {
            notifierLabel.text = "Training Set Loaded"
            
            UIView.animate(withDuration: 2.0, animations: {
                self.notifierView.alpha = 0.0
                self.notifierView.alpha = 1.0
                self.notifierView.alpha = 0.0
            })

            let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
            
            segmentController.selectedSegmentIndex = entries % 10
            
            entryCountLabel.text = "\(entries)"
        }
    }

    
    @IBAction func removeLastPressed(_ sender: UIButton) {
        
        if FCNeuralNetwork.neuralNetwork.removeLastTrainingEntry() {
            let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
            entryCountLabel.text = "\(entries)"
            
            segmentController.selectedSegmentIndex = segmentController.selectedSegmentIndex == 0 ? 9 : segmentController.selectedSegmentIndex - 1
        }
    }
    
    @IBAction func removeAllPressed(_ sender: UIButton) {
        
        if FCNeuralNetwork.neuralNetwork.clearTrainingSet() {
            segmentController.selectedSegmentIndex = 0
            
            let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
            entryCountLabel.text = "\(entries)"
            
        }
    }
    
    @IBAction func trainPressed(_ sender: UIButton) {
        progressView.setProgress(0.0, animated: true)
        FCNeuralNetwork.neuralNetwork.train()
    }
    
    func userDidFinishWriting() {
        if let bitMap = canvas.getCroppedBitMap(dimension: FCNeuralNetwork.dimension) {
            if FCNeuralNetwork.neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex) {
                segmentController.selectedSegmentIndex = segmentController.selectedSegmentIndex == 9 ? 0 : segmentController.selectedSegmentIndex + 1
                
                let entries = FCNeuralNetwork.neuralNetwork.numberOfTrainingEntries()
                entryCountLabel.text = "\(entries)"
                
            }
        }
        canvas.reset()
    }
    
    func trainingProgressUpdate(progress: Double) {
        let progress = Float(progress)
        
        self.progressView.setProgress(progress, animated: true)

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

