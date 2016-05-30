import Cocoa
import Foundation

class Location {

    var type : String!
    var coordinates = [CGPoint]()

    init(locationDictionary : Dictionary<String, AnyObject>) {
        
        self.type = locationDictionary["type"]! as! String
        
        let jsonCoordinatesList = locationDictionary["coordinates"]! as! [[Array<Double>]]
        
        for jsonCoordinates in jsonCoordinatesList{
            
            for pointValues in jsonCoordinates {
                
                coordinates.append(CGPointMake(CGFloat(pointValues[0]), CGFloat(pointValues[1])))
            }
            
        }
        
    }
    
    
    init(type : String, coordinates : [CGPoint]){
        self.type = type
        self.coordinates = coordinates
    }
}
