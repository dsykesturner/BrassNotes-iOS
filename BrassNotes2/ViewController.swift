//
//  ViewController.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StaveDelegate, UITabBarDelegate {
    

    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var lblSelectedPosition: UILabel!
    @IBOutlet weak var lblSelectedNote: UILabel!
    
    @IBOutlet weak var testStepper: UIStepper!
    var countNoteValue: Int! = 0
    
    @IBOutlet weak var stave: Stave!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates
        stave.delegate = self
        tabBar.delegate = self
        
        // Setup the default selection
        let defaultItem:UITabBarItem = tabBar.items![1]
        tabBar.selectedItem = defaultItem
        populateWithInstrument(instrument: defaultItem.title!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Interaction actions

    @IBAction func testStepperTapped(_ sender: Any) {
        
        if Int(testStepper.value) > countNoteValue {
            stave.increaseNote()
        } else if Int(testStepper.value) < countNoteValue {
            stave.decreaseNote()
        }
        countNoteValue = Int(testStepper.value)
    }
    
    // MARK: - Regaular methods
    
    func populateWithInstrument(instrument: String) {
        
        navigationController?.navigationBar.topItem?.title = instrument
        stave.populateWithInstrument(instrument: instrument.lowercased())
    }
    
    // MARK: - StaveDelegate
    
    func staveDidChangeCurrentNote(_ note: NoteObject) {
        
        lblSelectedNote.text = note.note
        lblSelectedPosition.text = note.position
    }
    
    // MARK: - UITabBarDelegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Populate the stave with the lowercased name of the tab item selected
        self.populateWithInstrument(instrument: item.title!)
    }
    
    
    
    
//    override func viewWillTransition(to newSize: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        let newStaveSize = stave.conten
////        let newStaveSize = size(forChildContentContainer: stave, withParentContainerSize: newSize)
//        stave.buildStaveUI(size: newStaveSize)
////        systemLayoutFittingSizeDidChange(forChildContentContainer: stave)
//    }
    
}

