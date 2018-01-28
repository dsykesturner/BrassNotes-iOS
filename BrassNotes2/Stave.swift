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
    var flat: UILabel! = UILabel()
    var sharp: UILabel! = UILabel()
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
        flat.text = "♭"
        flat.textColor = UIColor.white
        flat.font = UIFont(name: "Helvetica", size: 42)
        sharp.text = "♯"
        sharp.textColor = UIColor.white
        sharp.font = UIFont(name: "Helvetica", size: 42)
        if note1.superview == nil {
            addSubview(note1)
        }
        if note2.superview == nil {
            addSubview(note2)
        }
        if flat.superview == nil {
            addSubview(flat)
        }
        if sharp.superview == nil {
            addSubview(sharp)
        }
        updateNotePosition(updatedNote: currentNote!)
    }
    
    func updateNotePosition(updatedNote: NoteObject) {
        
        let lineHeight:CGFloat = 2.0
        let heightBetweenLines = frame.size.height/4
        
        // Note area =         (stave width - clef width) / (2 notes) * (first 1/3 or 1.1/3 of the space) + stave width
        let note1X = (self.frame.size.width - imgClef.frame.size.width) / 2 * (1/3) + imgClef.frame.size.width
        let note2X = (self.frame.size.width - imgClef.frame.size.width) / 2 * (1+1/3) + imgClef.frame.size.width
        // Sharp/flat area =   (stave width - clef width) / (2 notes) * (1.0 of the space) + stave width
        let sharpX = imgClef.frame.size.width
        let flatX = (self.frame.size.width - imgClef.frame.size.width) / 2 + imgClef.frame.size.width
        
        // Image size (ratio) is 346 x 181 px
        note1.frame = CGRect.init(x: note1X, y: CGFloat(updatedNote.stavePosition)*(heightBetweenLines)+lineHeight/2, width: heightBetweenLines/181*346, height: heightBetweenLines)
        
        // Only a second note is required if the note is flat and sharp
        if updatedNote.isFlat && updatedNote.isSharp {
            note2.isHidden = false
            note2.frame = CGRect.init(x: note2X, y: CGFloat(updatedNote.stavePosition-0.5)*(heightBetweenLines)+lineHeight/2, width: heightBetweenLines/181*346, height: heightBetweenLines)
        } else {
            note2.isHidden = true
        }
        
        let sizeDifferenceToNote:CGFloat = 1.5
        if updatedNote.isSharp {
            sharp.isHidden = false
            sharp.frame = CGRect.init(x: sharpX, y: note1.frame.origin.y, width: note1.frame.size.width/sizeDifferenceToNote, height: note1.frame.size.height)

        } else {
            sharp.isHidden = true
        }
        if updatedNote.isFlat {
            flat.isHidden = false
            flat.frame = CGRect.init(x: flatX, y: note2.frame.origin.y, width: note2.frame.size.width/sizeDifferenceToNote, height: note2.frame.size.height)
        } else {
            flat.isHidden = true
        }
    }
    
    func incrementNote() {
        let currentIndex = currentInstrument?.notes.index(of: currentNote!)
        if (currentIndex! < (currentInstrument?.notes.count)!-1) {
            currentNote = currentInstrument?.notes[currentIndex!+1]
            
            updateNotePosition(updatedNote: currentNote!)
        }
    }
    
    func decrementNote() {
        let currentIndex = currentInstrument?.notes.index(of: currentNote!)
        if (currentIndex! > 0) {
            currentNote = currentInstrument?.notes[currentIndex!-1]
            
            updateNotePosition(updatedNote: currentNote!)
        }
    }
}
