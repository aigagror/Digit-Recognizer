//
//  FirstViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, CanvasViewDelegate {
    
    var trials = 0
    var correct = 0
    
    @IBAction func correctPressed(_ sender: Any) {
        
        trials += 1
        correct += 1
        updateSuccessRate()
        
    }
    
    @IBAction func incorrectPressed(_ sender: Any) {
        
        trials += 1
        updateSuccessRate()
    }
    
    func updateSuccessRate() -> Void {
        
        
        if trials == 0 {
            successRateLabel.text = "-"
        } else {
            let rate = Int((Double(correct) / Double(trials) * 100).rounded())
            
            successRateLabel.text = "\(rate)"
        }
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        
        trials = 0
        correct = 0
        updateSuccessRate()
    }
    
    @IBOutlet weak var successRateLabel: UILabel!
    
    func userDidFinishWriting() {
        if let bitMap = canvas.getCroppedBitMap(dimension: FCNeuralNetwork.dimension) {
            var prediction = FCNeuralNetwork.neuralNetwork.predict(bitmap: bitMap)
            
            var choice = 0
            for i in 1..<prediction.count {
                if prediction[i] > prediction[choice] {
                    choice = i
                }
            }
            
            for i in 0..<prediction.count {
                prediction[i] = (prediction[i] * 100).rounded()
            }
            
            predictionDisplay.text = "\(choice)"
        } else {
            predictionDisplay.text = "Error"
        }
        
        canvas.reset()
    }
    
    @IBOutlet weak var predictionDisplay: UILabel!
    
    @IBOutlet weak var canvas: CanvasView!
    

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

