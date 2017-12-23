//
//  Stave.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

protocol StaveDelegate : NSObjectProtocol {
    func staveDidChangeCurrentNote(_ note: NoteObject)
}

class Stave: UIView {

    @IBOutlet weak var imgClef: UIImageView!
    
    var note1: UIImageView! = UIImageView()
    var note2: UIImageView! = UIImageView()
    var staveLines: [UIView]! = [UIView]()
    var aboveStaveLines: [UIView]?
    var belowStaveLines: [UIView]?
    
    var delegate: StaveDelegate?
    var currentInstrument: InstrumentObject?
    var currentNote: NoteObject? {
        didSet {
            // Push the update to the delegate whenever a change is detected
            if currentNote != nil && delegate?.staveDidChangeCurrentNote != nil {
                delegate?.staveDidChangeCurrentNote(currentNote!)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateWithInstrument(instrument: String) {
        
        // Read in the instrument JSON data and build the set of notes inside the instrumnet
        if let instrumentData = readJSONFile(filename: instrument) {
            currentInstrument = InstrumentObject(data: instrumentData)
            
            // Determine the starting note
            let lowestNote = currentInstrument!.notes.first
            let startingNoteIndex = currentInstrument!.startingNoteIndex - lowestNote!.staveIndex
            currentNote = currentInstrument?.notes[startingNoteIndex]

            // Build our UI - must be done programmatically for adapting screen sizes
            buildStaveUI(size: frame.size)
        }
    }
    
    func readJSONFile(filename: String) -> [String:Any]? {
        
        if let file = Bundle.main.path(forResource: filename, ofType: "json"),
            let jsonData = NSData(contentsOfFile: file) as Data? {
        
            do {
                if let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as? [String:Any] {
                    return jsonDic
                } else {
                    return nil
                }
            } catch {
                return nil
            }
            
        } else {
            print("Tried to open file name '\(filename)' which was not a json file, or had no contents")
            return nil
        }
    }
    
    func buildStaveUI(size: CGSize) {
        
        // Some quick constants
        let vHeight = size.height
        let vWidth = size.width
        
        // Clean up any existing UI
        for sl in staveLines {
            sl.removeFromSuperview()
        }
        staveLines.removeAll()
        
        // Set the clef image
        if currentInstrument?.clef == "bass" {
            imgClef.image = UIImage(named: "BassClef")
        } else {
            imgClef.image = UIImage(named: "TrebleClef")
        }
        
        // Get the first 5 lines
        let lineHeight:CGFloat = 2.0
        for i in 0...4 {
            let line = UIView(frame: CGRect.init(x: 0, y: vHeight/4*CGFloat(i), width: vWidth, height: lineHeight))
            line.backgroundColor = UIColor.white
            addSubview(line)
            staveLines?.append(line)
        }
        
        // Update the note image/position
        note1.image = UIImage(named: "note")
        note2.image = UIImage(named: "note")
        if note1.superview == nil {
            addSubview(note1)
        }
        if note2.superview == nil {
            addSubview(note2)
        }
        updateNotePosition(updatedNote: currentNote!)
    }
    
    func updateNotePosition(updatedNote: NoteObject) {
        
        let lineHeight:CGFloat = 2.0
        let heightBetweenLines = frame.size.height/4
        
        // Image size (ratio) is 346 x 181 px
        note1.frame = CGRect.init(x: imgClef.frame.size.width+50, y: CGFloat(updatedNote.stavePosition)*(heightBetweenLines)+lineHeight/2, width: heightBetweenLines/181*346, height: heightBetweenLines)
        
        if updatedNote.isFlat && updatedNote.isSharp {
            note2.isHidden = false
            note2.frame = CGRect.init(x: imgClef.frame.size.width+150, y: CGFloat(updatedNote.stavePosition-0.5)*(heightBetweenLines)+lineHeight/2, width: heightBetweenLines/181*346, height: heightBetweenLines)
        } else {
            note2.isHidden = true
        }
    }
    
    func incrementNote() {
        let currentIndex = currentInstrument?.notes.index(of: currentNote!)
        currentNote = currentInstrument?.notes[currentIndex!+1]
        
        updateNotePosition(updatedNote: currentNote!)
    }
    
    func decrementNote() {
        let currentIndex = currentInstrument?.notes.index(of: currentNote!)
        currentNote = currentInstrument?.notes[currentIndex!-1]
        
        updateNotePosition(updatedNote: currentNote!)
    }
}
