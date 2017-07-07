//
//  InstrumentObject.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

class InstrumentObject: NSObject {

    var clef: String! = ""
    var startingNoteIndex: Int! = 0
    var notes: [NoteObject]! = [NoteObject]()
    
    init(data: [String:Any]) {
        self.clef = data["clef"] as! String
        self.startingNoteIndex = data["startingNoteIndex"] as! Int
        if let notes = data["notes"] as? [[String:Any]] {
            for note in notes {
                let n = NoteObject(data: note)
                self.notes.append(n)
            }
        }
    }
}
