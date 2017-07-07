//
//  NoteObject.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

class NoteObject: NSObject {

    var staveIndex: Int! = 0
    var note: String! = ""
    var position: String! = ""
    var isShart: Bool = false
    var isFlat: Bool = false
    
    init(data: [String:Any]) {
        
    }
}
