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
    var stavePosition: Float! = 0
    var note: String! = ""
    var position: String! = ""
    var isSharp: Bool = false
    var isFlat: Bool = false
    
    init(data: [String:Any]) {
        self.staveIndex = data["staveIndex"] as! Int
        self.stavePosition = data["stavePosition"] as! Float
        self.note = data["note"] as! String
        self.position = data["position"] as! String
        self.isSharp = self.note.contains("♯")
        self.isFlat = self.note.contains("♭")
    }
}
