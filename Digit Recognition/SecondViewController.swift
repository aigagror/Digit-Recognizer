//
//  SecondViewController.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func resetPressed(_ sender: UIButton) {
        
        canvas.reset()
    }
    @IBAction func submitPressed(_ sender: UIButton) {
        
        canvas.reset()
        
        let bitMap = canvas.getIntensities(dimension: 28)
        
        neuralNetwork.train(input: bitMap, output: segmentController.selectedSegmentIndex)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

