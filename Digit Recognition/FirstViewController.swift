//
//  FirstViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, CanvasViewDelegate {
    
    func userDidFinishWriting() {
        if let bitMap = canvas.getCroppedBitMap(dimension: 28) {
            var prediction = neuralNetwork.predict(bitmap: bitMap)
            
            for i in 0..<prediction.count {
                prediction[i] = (prediction[i] * 100).rounded()
            }
            
            predictionDisplay.text = "\(prediction)"
        } else {
            predictionDisplay.text = "Error"
        }
        
        canvas.reset()
    }
    
    @IBOutlet weak var predictionDisplay: UILabel!
    
    @IBOutlet weak var canvas: CanvasView!
    
    @IBAction func resetPressed(_ sender: UIButton) {
        canvas.reset()
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

