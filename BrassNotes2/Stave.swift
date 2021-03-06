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

    @IBOutlet weak var imgBassClef: UIImageView!
    @IBOutlet weak var imgTrebleClef: UIImageView!
    
    var note1: UIImageView! = UIImageView()
    var note2: UIImageView! = UIImageView()
    var flat: UILabel! = UILabel()
    var sharp: UILabel! = UILabel()
    var staveLines: [UIView]! = [UIView]()
    var aboveStaveLines: [UIView]! = [UIView]()
    var belowStaveLines: [UIView]! = [UIView]()
    
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
        imgBassClef.isHidden = currentInstrument?.clef != "bass"
        imgTrebleClef.isHidden = currentInstrument?.clef == "bass"
        
        // Get the first 5 lines
        let lineHeight:CGFloat = 2.0
        for i in 0...4 {
            let line = UIView(frame: CGRect.init(x: 0, y: vHeight/4*CGFloat(i), width: vWidth, height: lineHeight))
            line.backgroundColor = UIColor.white
            addSubview(line)
            staveLines?.append(line)
        }
        
        let heightBetweenLines = frame.size.height/4
        let accidentalSize = heightBetweenLines*1.7
        // Update the note image/position
        note1.image = UIImage(named: "note")
        note2.image = UIImage(named: "note")
        flat.text = "♭"
        flat.textColor = UIColor.white
        flat.font = UIFont(name: "Helvetica", size: accidentalSize)
        sharp.text = "♯"
        sharp.textColor = UIColor.white
        sharp.font = UIFont(name: "Helvetica", size: accidentalSize)
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
        
        let clefEndCoord = imgBassClef.isHidden ? (imgBassClef.frame.origin.x+imgBassClef.frame.size.width) : (imgTrebleClef.frame.origin.x+imgTrebleClef.frame.size.width)
        
        // Note area =         (stave width - clef end coord) / (2 notes) * (first 1/3 or 1.1/3 of the space) + clef end coord
        let note1X = (self.frame.size.width - clefEndCoord) / 2 * (1/3) + clefEndCoord
        let note2X = (self.frame.size.width - clefEndCoord) / 2 * (1+1/3) + clefEndCoord
        // Sharp/flat area =   (stave width - clef end coord) / (2 notes) * (1.0 of the space) + clef end coord
        let sharpX = clefEndCoord
        let flatX = (self.frame.size.width - clefEndCoord) / 2 + clefEndCoord
        
        // Image size (ratio) is 346 x 181 px
        note1.frame = CGRect.init(x: note1X, y: CGFloat(updatedNote.stavePosition)*(heightBetweenLines)+lineHeight/2, width: heightBetweenLines/181*346, height: heightBetweenLines)
        
        // Only a second note is required if the note is flat and sharp
        if updatedNote.isFlat && updatedNote.isSharp {
            note2.isHidden = false
            note2.frame = CGRect.init(x: note2X, y: CGFloat(updatedNote.stavePosition-0.5)*(heightBetweenLines)+lineHeight/2, width: heightBetweenLines/181*346, height: heightBetweenLines)
        } else {
            note2.isHidden = true
        }
        
        let accidentalSize:CGFloat = heightBetweenLines*1.7
        if updatedNote.isSharp {
            sharp.isHidden = false
            sharp.frame = CGRect.init(x: sharpX, y: note1.frame.origin.y, width: accidentalSize, height: note1.frame.size.height)
        } else {
            sharp.isHidden = true
        }
        if updatedNote.isFlat {
            flat.isHidden = false
            flat.frame = CGRect.init(x: flatX, y: note2.frame.origin.y, width: accidentalSize, height: note2.frame.size.height)
        } else {
            flat.isHidden = true
        }

        
        // First clean out existing above/below stave lines
        for line in aboveStaveLines {
            line.removeFromSuperview()
        }
        aboveStaveLines.removeAll()
        for line in belowStaveLines {
            line.removeFromSuperview()
        }
        belowStaveLines.removeAll()
        
        // Determine whether the notes are in range for an above stave additional line
        if (updatedNote.stavePosition <= -1) {
            
            // Keep track of the remaining steps to check for a line
            var remaining = CGFloat(updatedNote.stavePosition)
            while remaining < 0 {
                
                // Make sure we are on a correct line position to place
                if Int(remaining*2) % 2 == 0 {
                    // Place a line at a note if it's not hidden
                    if !note2.isHidden {
                        // Note 2's turn for a line
                        let line = UIView(frame: CGRect.init(x: note2.frame.origin.x-note2.frame.size.width*0.1, y: heightBetweenLines*remaining, width: note2.frame.size.width*1.2, height: lineHeight))
                        line.backgroundColor = UIColor.white
                        self.addSubview(line)
                        aboveStaveLines?.append(line)
                    }
                }
                if Int(remaining*2) % 2 == -1 {
                    if !note1.isHidden {
                        // Note 1's turn for a line
                        let line = UIView(frame: CGRect.init(x: note1.frame.origin.x-note1.frame.size.width*0.1, y: heightBetweenLines*(remaining+0.5), width: note1.frame.size.width*1.2, height: lineHeight))
                        line.backgroundColor = UIColor.white
                        self.addSubview(line)
                        aboveStaveLines?.append(line)
                    }
                }
                
                remaining += 0.5
            }
        }
        
        // Determine whether the notes are in range for an above stave additional line
        if (updatedNote.stavePosition >= 4.5) {
            
            // Keep track of the remaining steps to check for a line
            var remaining = CGFloat(updatedNote.stavePosition)
            while remaining > 4 {
                
                // Make sure we are on a correct line position to place
                if Int(remaining*2) % 2 == 0 {
                    if !note2.isHidden {
                        // Note 2's turn for a line
                        let line = UIView(frame: CGRect.init(x: note2.frame.origin.x-note2.frame.size.width*0.1, y: frame.size.height+heightBetweenLines*(remaining-4), width: note2.frame.size.width*1.2, height: lineHeight))
                        line.backgroundColor = UIColor.white
                        self.addSubview(line)
                        belowStaveLines?.append(line)
                    }
                }
                if Int(remaining*2) % 2 == 1 {
                    if !note1.isHidden {
                        // Note 1's turn for a line
                        let line = UIView(frame: CGRect.init(x: note1.frame.origin.x-note1.frame.size.width*0.1, y: frame.size.height+heightBetweenLines*(remaining-3.5), width: note1.frame.size.width*1.2, height: lineHeight))
                        line.backgroundColor = UIColor.white
                        self.addSubview(line)
                        belowStaveLines?.append(line)
                    }
                }
                
                remaining -= 0.5
            }
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
