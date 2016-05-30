import Cocoa
import Foundation

class Place {
    var id : String
    var venueId : String
    var rareness : Int
    var type : String
    var section : String
    var numericSection: Int
    var row : String
    var numericRow : Int
    var seat : String
    var numericSeat : Int
    var available : Bool
    var partOfEvent : Bool
    var location : Location
    var priceCategoryName : String?
    
    let bounds : CGRect
    var frame : CGRect?
    var selected : Bool = false
    
    var description: String { return "Place section: \(section) row: \(row) seat: \(seat)" }
    
    init(placeDictionary : Dictionary<String, AnyObject>) {
        
        
        guard let id = placeDictionary["id"] as? String else {  }
        self.id = id
        self.venueId = placeDictionary["venueId"]! as! String
        self.rareness = placeDictionary["rareness"]! as! Int
        self.type = placeDictionary["type"]! as! String
        self.section = placeDictionary["section"]! as! String
        self.numericSection = placeDictionary["numericSection"]! as! Int
        self.row = placeDictionary["row"]! as! String
        self.numericRow = placeDictionary["numericRow"]! as! Int
        self.seat = placeDictionary["seat"]! as! String
        self.numericSeat = placeDictionary["numericSeat"]! as! Int
        self.available = placeDictionary["available"]! as! Bool
        self.partOfEvent = placeDictionary["partOfEvent"]! as! Bool
        self.location = Location(locationDictionary: placeDictionary["location"]! as! Dictionary<String, AnyObject>)
        self.bounds = Place.CGRectSmallestWithCGPoints(self.location.coordinates)
        
    }
    
    init(location : Location){
        self.id = "1"
        self.venueId = "1"
        self.rareness = 1
        self.type = "type"
        self.section = "section"
        self.numericSection = 1
        self.row = "row"
        self.numericRow = 1
        self.seat = "seat"
        self.numericSeat = 1
        self.available = true
        self.partOfEvent = true
        self.location = location
        self.bounds = Place.CGRectSmallestWithCGPoints(self.location.coordinates)

    }
    
    func frame(offsetPoint offset : NSPoint) -> NSRect{
        
        guard let _ = frame else{
            return CGRectMake(
                bounds.origin.x + offset.x,
                bounds.origin.y + offset.y,
                bounds.size.width,
                bounds.size.height
            )
        }
        
        return frame!
    }
    
    class func CGRectSmallestWithCGPoints(pointsArray : [CGPoint]) -> CGRect {
        
        var greatestXValue = pointsArray[0].x;
        var greatestYValue = pointsArray[0].y;
        var smallestXValue = pointsArray[0].x;
        var smallestYValue = pointsArray[0].y;
        
        for i in 0 ..< pointsArray.count{
            let point = pointsArray[i];
            greatestXValue = max(greatestXValue, point.x);
            greatestYValue = max(greatestYValue, point.y);
            smallestXValue = min(smallestXValue, point.x);
            smallestYValue = min(smallestYValue, point.y);
        }
        
        
        var rect = CGRect();
        rect.origin = CGPointMake(smallestXValue, smallestYValue);
        rect.size.width = greatestXValue - smallestXValue;
        rect.size.height = greatestYValue - smallestYValue;
        
        return rect;
    }
    
    
    func drawPlace(centerPoint center : NSPoint, event : Event?){
        
        
        let path = self.path(centerPoint: center)
        
        self.frame = path.bounds
        
        path.lineWidth = 1
        //        path.stroke()
        
        if self.partOfEvent {
            if self.available {
                
                if let priceCategoryName = self.priceCategoryName{
                    if let priceCategory = event?.priceCategories[priceCategoryName]{
                        priceCategory.color.setFill()
                    }else{
                        //todo patate
                    }
                }else{
                    NSColor.grayColor().setFill() //category color
                }
                
            }else{
                NSColor.redColor().setFill()
            }
        }else{
            NSColor.grayColor().setFill()
        }
        
        
        if(self.selected){
            let color = NSColor.yellowColor().colorWithAlphaComponent(0.30)
            color.setFill()
            
        }
        
        
        path.fill()
        
        if(!self.partOfEvent){
            
            NSBezierPath.strokeLineFromPoint(offsetPoint(self.location.coordinates[0], centerPoint: center), toPoint: offsetPoint(self.location.coordinates[2], centerPoint: center))
            NSBezierPath.strokeLineFromPoint(offsetPoint(self.location.coordinates[1], centerPoint: center), toPoint: offsetPoint(self.location.coordinates[3], centerPoint: center))
            
        }
        
        
        if(self.selected){
            //            let style = NSMutableParagraphStyle()
            //            style.alignment = .Center
            //            NSString(string: "*").drawInRect(path.bounds, withAttributes: [NSParagraphStyleAttributeName : style])
            NSBezierPath.strokeLineFromPoint(offsetPoint(self.location.coordinates[0], centerPoint: center), toPoint: offsetPoint(self.location.coordinates[1], centerPoint: center))
            NSBezierPath.strokeLineFromPoint(offsetPoint(self.location.coordinates[1], centerPoint: center), toPoint: offsetPoint(self.location.coordinates[2], centerPoint: center))
            NSBezierPath.strokeLineFromPoint(offsetPoint(self.location.coordinates[2], centerPoint: center), toPoint: offsetPoint(self.location.coordinates[3], centerPoint: center))
            NSBezierPath.strokeLineFromPoint(offsetPoint(self.location.coordinates[3], centerPoint: center), toPoint: offsetPoint(self.location.coordinates[0], centerPoint: center))
        }
        
    }
    
    
    func offsetPoint(var point : NSPoint, centerPoint center : NSPoint) -> NSPoint{
        
        point.x += center.x
        point.y += center.y
        
        return point
    }
    
    
    func path(centerPoint center : NSPoint) -> NSBezierPath{
        
        let path = NSBezierPath()
        let points = location.coordinates
        
        
        path.moveToPoint(offsetPoint(points[0], centerPoint: center))
        
        for index in 1 ..< points.count {
            
            path.lineToPoint(offsetPoint(points[index],  centerPoint: center))
            
        }
        
        return path
    }
    
    func rotateAround(centerPoint : NSPoint, withAngle radians : Double){
        
        for (index, point) in location.coordinates.enumerate(){
            
            location.coordinates[index] = rotatePoint(point, aroundPoint: centerPoint, withAngle: radians)
            
        }
        
    }
    
    func rotatePoint2(point : NSPoint, aroundPoint center : NSPoint, withAngle percent: Double) -> NSPoint {
        
        let radians = CGFloat(percent * M_PI * 2)
        let x = point.x - center.x
        let y = point.y - center.y
        let  newX = x * cos(radians) + y * sin(radians);
        let newY = x * -sin(radians) + y * cos(radians);
        return NSMakePoint(center.x + newX, center.y + newY);
    }
    
    func rotatePoint(point : NSPoint, aroundPoint centerPoint : NSPoint, withAngle radians: Double) -> NSPoint {
        
        let temp = CGPointMake(point.x - centerPoint.x, point.y - centerPoint.y);
        let sinAngle = CGFloat(sin(radians));
        let cosAngle = CGFloat(cos(radians));
        
        var result = NSPoint()
        
        result.x = temp.x * cosAngle - temp.y * sinAngle;
        result.y = temp.x * sinAngle + temp.y * cosAngle;
        
        result.x += centerPoint.x;
        result.y += centerPoint.y;
        
        return result
    }
    
}
