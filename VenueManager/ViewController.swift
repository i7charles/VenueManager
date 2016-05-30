//
//  ViewController.swift
//  VenueManager
//
//  Created by Charles Billette on 2015-12-15.
//  Copyright © 2015 Charles Billette. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var event : Event!
    var places = [Place]()
    var venueView : VenueView!
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var buttonBest: NSButton!
    @IBOutlet weak var buttonGood: NSButton!
    @IBOutlet weak var buttonNotBad: NSButton!
    @IBOutlet weak var buttonPit: NSView!
    @IBOutlet weak var sliderZoom: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let httpRequestHandler = HttpRequestHandler.sharedInstance
        httpRequestHandler.setupSession("charles@cbillette.com", password: "toto")
        
        self.fetchEvent("5665ed80d4b0310a6cd98631")
//        self.fetchEvent("5672a1bd566e656c6161c9fb")
        
        
        
        self.scrollView.minMagnification = 0.10
        self.scrollView.maxMagnification = 2.0
        self.scrollView.magnification = 0.50
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func fetchEvent(eventId : String){
        
        HttpRequestHandler.sharedInstance.jsonDictionaryForURLString("http://Charless-MacBook-Pro.local:8080/api/events/\(eventId)", parameters: nil, method: "GET",
            successHandler: {
                (dictionary: [String:AnyObject]) -> Void in
                self.event = Event(eventDictionary: dictionary)
                self.fetchPlaces(self.event.id)
            },
            errorHandler: {
                (error: NSError) -> Void in
                print(error.description)
        });
        
    }

    
    func fetchPlaces(eventId : String){
        
        
        HttpRequestHandler.sharedInstance.jsonDictionaryForURLString("http://Charless-MacBook-Pro.local:8080/api/events/\(eventId)/venueSetup", parameters: nil, method: "GET",
            successHandler: {
                (dictionary: [String:AnyObject]) -> Void in
                
                if let placeDictionaries = dictionary["content"] as? Array<Dictionary<String, AnyObject>> {
                    
                    print("Creating places from dictionary")
                    for placeDictionary in placeDictionaries{
                        let place = Place(placeDictionary: placeDictionary)
                        self.places += [place]
                    }

                    print("Places created")

                    self.venueView = VenueView(event : self.event, places: self.places)

                    self.scrollView.documentView = self.venueView
                    self.scrollView.contentView.scrollToPoint(
                        CGPointMake(
                            (self.venueView.bounds.size.width / 2.0) - (self.scrollView.frame.size.width / 2),
                            (self.venueView.bounds.size.height / 2.0) - (self.scrollView.frame.size.height / 2)
                        )
                    )
                    
                }
                
            },
            errorHandler: {
                (error: NSError) -> Void in
                print(error.description)
        });
        
    }
    
    @IBAction func addToEventsAction(sender: AnyObject) {
        
        for place in places.filter({ (placeToFilter) -> Bool in
            
            placeToFilter.selected
            
        }) {
            
            place.partOfEvent = true
            
        }
        self.venueView.resetSelection()
        
    }
    
    @IBAction func setPriceCategoryAction(sender: AnyObject) {
        
        let priceCategory = (sender as!NSButton).title
        
        for place in places.filter({ (placeToFilter) -> Bool in
            
            placeToFilter.selected && placeToFilter.partOfEvent
            
        }) {
            
            place.priceCategoryName = priceCategory
            
        }
        self.venueView.resetSelection()
    }
    
    @IBAction func zoomAction(sender: AnyObject) {
        scrollView.magnification = CGFloat(self.sliderZoom.doubleValue)
    }
    
    @IBAction func rotateAction(sender: AnyObject) {
        
        let slider = sender as! NSSlider
        venueView.rotateSelection(slider.doubleValue)
    }
}

