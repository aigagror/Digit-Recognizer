//
//  SecondViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, CanvasViewDelegate, NeuralNetworkDelegate {

    
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func removeLastPressed(_ sender: UIButton) {
        
        neuralNetwork.removeLastTrainingEntry()
    }
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let bitMap = canvas.getCroppedBitMap(dimension: dimension) {
            neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }

        canvas.reset()
    }
    @IBAction func trainPressed(_ sender: UIButton) {
        neuralNetwork.train()
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
        
        canvas.reset()
    }
    
    func trainingProgressUpdate(progress: Double) {
        progressView.setProgress(Float(progress), animated: true)
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

