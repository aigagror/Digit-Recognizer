//
//  SecondViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, CanvasViewDelegate {

    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func resetPressed(_ sender: UIButton) {
        
        canvas.reset()
    }
    @IBAction func submitPressed(_ sender: UIButton) {
        
        if let bitMap = canvas.getCroppedBitMap(dimension: 28) {
            neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }

        canvas.reset()
    }
    @IBAction func trainPressed(_ sender: UIButton) {
        neuralNetwork.train()
    }
    
    @IBAction func currentCostPressed(_ sender: UIButton) {
        
        let cost = neuralNetwork.costFunction()
        
        print("cost: \(cost)")
    }
    
    func userDidFinishWriting() {
        if let bitMap = canvas.getCroppedBitMap(dimension: 28) {
            neuralNetwork.addToTrainingSet(image: bitMap, correctOutput: segmentController.selectedSegmentIndex)
        }
        
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

