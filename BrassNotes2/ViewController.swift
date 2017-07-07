//
//  ViewController.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var lblSelectedPosition: UILabel!
    @IBOutlet weak var lblSelectedNote: UILabel!
    
    @IBOutlet weak var testStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func testStepperTapped(_ sender: Any) {
    }
    
}

