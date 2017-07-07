//
//  Stave.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

class Stave: NSObject {

    @IBOutlet weak var imgClef: UIImageView!

    var staveLines: [UIView]?
    
    var currentNote: String! = ""
    
    init(instrument: String) {
        
    }
    
}
