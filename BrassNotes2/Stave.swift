//
//  Stave.swift
//  BrassNotes2
//
//  Created by Daniel Sykes-Turner on 7/7/17.
//  Copyright © 2017 Universe Apps. All rights reserved.
//

import UIKit

class Stave: UIView {

    @IBOutlet weak var imgClef: UIImageView!
    
    var note: UIImageView! = UIImageView()
    var staveLines: [UIView]! = [UIView]()
    var aboveStaveLines: [UIView]?
    var belowStaveLines: [UIView]?
    
    var currentInstrument: InstrumentObject?
    var currentNote: NoteObject?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func populateWithInstrument(instrument: String) {
        
        if let instrumentData = readJSONFile(filename: instrument) {
            currentInstrument = InstrumentObject(data: instrumentData)
            for n in currentInstrument!.notes {
                if n.staveIndex == currentInstrument?.startingNoteIndex {
                    currentNote = n
                    break
                }
            }
            buildStaveUI()
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
            print("Tried to open file name \(filename) which was not a json or had no contents.")
            return nil
        }
    }
    
    func buildStaveUI() {
        // Some quick constants
        let vHeight = frame.size.height
        let vWidth = frame.size.width
        
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
        for i in 0...4 {
            let line = UIView(frame: CGRect.init(x: 0, y: vHeight/4*CGFloat(i), width: vWidth, height: 2))
            line.backgroundColor = UIColor.white
            addSubview(line)
            staveLines?.append(line)
        }
        
        // Image size is 346 x 181 px
        let heightBetweenLines = vHeight/4
        note.frame = CGRect.init(x: imgClef.frame.size.width+50, y: CGFloat(currentNote!.stavePosition)*(1.0+heightBetweenLines), width: heightBetweenLines/181*346, height: heightBetweenLines)
        note.image = UIImage(named: "note")
        if note.superview == nil {
            addSubview(note)
        }
    }
    
    func increaseNote() {
        
    }
    
    func decreaseNote() {
        
    }
    
    // TODO: write delegate to notify parent of updated note data to present
}
