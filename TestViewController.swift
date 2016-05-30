//
//  ViewController.swift
//  VenueManager
//
//  Created by Charles Billette on 2015-12-15.
//  Copyright © 2015 Charles Billette. All rights reserved.
//

import Cocoa

class TestViewController: NSViewController {
    
    @IBOutlet weak var viewVenue: VenueView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let location = Location(type: "aType", coordinates:[
            CGPointMake(10, 10),
            CGPointMake(10, 20),
            CGPointMake(20, 20),
            CGPointMake(20, 10)
            ]
        )
        viewVenue.places.append(Place(location: location))

        let location2 = Location(type: "aType", coordinates:[
            CGPointMake(23, 10),
            CGPointMake(23, 20),
            CGPointMake(33, 20),
            CGPointMake(33, 10)
            ]
        )
        
        
        
        viewVenue.places.append(Place(location: location2))
        
        
    }
    
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    @IBAction func rotateAction(sender: AnyObject) {
        
        viewVenue.rotateSelection(45.0)
        
    }
    
    @IBAction func layoutToggleAction(sender: AnyObject) {
        
        let check = sender as! NSButton
        
        viewVenue.layoutMode = check.state == NSOnState
        
    }
}