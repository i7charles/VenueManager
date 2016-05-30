import Cocoa
import Quartz
import Foundation

class VenueView : NSView{
    
    var places = [Place]()
    var event : Event!
    
    var selectionStartPoint : NSPoint?
    var selectionEndPoint : NSPoint?
    var shapeLayer : CAShapeLayer?
    var layoutMode = false
    var center : NSPoint!
    
    override var opaque: Bool {
        get {
            return true
        }
    }
    
    init(event theEvent : Event, places somePlaces: [Place]){
        
        self.places = somePlaces
        self.event = theEvent
    
        self.center = CGPointMake(4000, 4000)
        
        super.init(frame: CGRectMake(0, 0, 8000, 8000))
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        self.center = CGPointMake(self.frame.size.width / 2 , self.frame.size.height / 2)
    }
    
    func offsetPointFromCenter(var point : NSPoint) -> NSPoint{
        
        point.x += (bounds.size.width / 2.0)
        point.y += (bounds.size.height / 2.0)
        return point
    }
    

    override func cancelOperation(sender: AnyObject?) {
        resetSelection()
    }
    

    override func mouseDown(theEvent: NSEvent) {
        
        window?.makeFirstResponder(self)

        let point = convertPoint(theEvent.locationInWindow, fromView: nil);
        
        for place in places{
            
            if CGRectContainsPoint(place.frame(offsetPoint: center), point) && place.selected{
                
                layoutMode = true
                
                break
            }
            
        }
        
        
        
        if let _ = selectionStartPoint{
            return
        }
        
        selectionStartPoint = point
        
        shapeLayer = CAShapeLayer()
        if let layer = shapeLayer{
            layer.lineWidth = 1.0
            layer.strokeColor = NSColor.blackColor().CGColor
            layer.fillColor = NSColor.yellowColor().CGColor
            layer.opacity = 0.2
            self.layer?.addSublayer(layer)
        }
        
    }
    
    
    override func mouseDragged(theEvent: NSEvent) {
        
        if(layoutMode){
            for place in places.filter({ (placeToFilter) -> Bool in
                placeToFilter.selected
            }){
                
                for (index, point) in place.location.coordinates.enumerate(){
                    place.location.coordinates[index] = CGPointMake(point.x + theEvent.deltaX, point.y - theEvent.deltaY)
                }
                
                
                
                let frame = place.frame(offsetPoint: center)
                setNeedsDisplayInRect(CGRectMake(frame.origin.x - 4 , frame.origin.y - 4, frame.size.width + 8 , frame.size.height + 8 ))
                
                setNeedsDisplayInRect(place.path(centerPoint: self.center).bounds)
            }
        }else{
            selectionEndPoint = convertPoint(theEvent.locationInWindow, fromView: nil) ;
            
            if let end = selectionEndPoint{
                if let start = self.selectionStartPoint{
                    
                    let path = CGPathCreateMutable()
                    
                    CGPathMoveToPoint(path, nil, start.x, start.y)
                    CGPathAddLineToPoint(path, nil, start.x, end.y);
                    CGPathAddLineToPoint(path, nil, end.x, end.y);
                    CGPathAddLineToPoint(path, nil, end.x, start.y);
                    CGPathCloseSubpath(path);
                    
                    self.shapeLayer!.path = path;
                    
                }
            }
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        
        if let _ = selectionEndPoint{
            
            
            
            if let layer = self.shapeLayer{
                
                let rect = CGPathGetPathBoundingBox(layer.path)
                layer.removeFromSuperlayer()
                
                for place in self.placesInRect(rect){
                    place.selected = true
                    self.setNeedsDisplayInRect(place.frame(offsetPoint: center
                        ))
                }
            }
            
            
            selectionStartPoint = nil
            selectionEndPoint = nil
            return
        }
    }
    
    
    func placesInRect(rect : CGRect) -> [Place]{
    
        return self.places.filter({ (place) -> Bool in
            
            return CGRectIntersectsRect(place.frame(offsetPoint: center), rect)
            
        })
    }
    
    
    override func drawRect(dirtyRect: NSRect) {
    
        let backgroundColor = NSColor.whiteColor()
        backgroundColor.setFill()
        NSRectFill(dirtyRect)
        
        for place in self.placesInRect(dirtyRect){
            
            place.drawPlace(centerPoint: self.center, event: event)

        }
        
    }
    
    
    func rotateSelection(angle : Double){
        
        let centerPoint = places[0].location.coordinates[0]
        
        for place in places.filter({ (place) -> Bool in
            place.selected
        }){
            
            place.rotateAround(centerPoint, withAngle: (M_PI * 2) / (360 / angle))
//            place.rotateAround(centerPoint, withAngle: M_PI  / 180)

            let placeFrame = place.frame(offsetPoint: center)
            setNeedsDisplayInRect(CGRectMake(placeFrame.origin.x - 1 , placeFrame.origin.y - 1, placeFrame.size.width + 2 , placeFrame.size.height + 2 ))
            
            setNeedsDisplayInRect(place.path(centerPoint: self.center).bounds)
            
        }
        
    }
    
    func resetSelection() {
        
        layoutMode = false
        
        selectionStartPoint = nil
        selectionEndPoint = nil
        
        for place in places.filter({ (placeToFilter) -> Bool in
            
            placeToFilter.selected
            
        }) {
            place.selected = false
            self.setNeedsDisplayInRect(place.frame(offsetPoint: self.center))
            
        }
        
    }
}