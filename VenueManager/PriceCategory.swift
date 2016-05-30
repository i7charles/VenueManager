import Cocoa
import Foundation

class PriceCategory {
    
    var level : Int!
    var name : String!
    var color : NSColor!
    var placeCount : Int!
    var minPrice : Double!
    
    init(priceCategoryDictionary : Dictionary<String, AnyObject>) {
        
        
        
        self.level = priceCategoryDictionary["level"]! as! Int
        self.name = priceCategoryDictionary["name"]! as! String
        self.color = NSColor(hexString:  priceCategoryDictionary["color"]! as! String)
        self.placeCount = priceCategoryDictionary["placeCount"]! as! Int
        self.minPrice = priceCategoryDictionary["minPrice"]! as! Double
        
    }
    
    
    
}