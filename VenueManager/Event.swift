
import Foundation

class Event {

    var id : String!
    var name : String!
    var priceCategories = [String: PriceCategory]()
    
    init(eventDictionary : Dictionary<String, AnyObject>) {
        
        
        
        self.id = eventDictionary["id"]! as! String
        self.name = eventDictionary["name"]! as! String
        
        let priceCategoryDictionaries  = eventDictionary["priceCategories"]! as!  [Dictionary<String, AnyObject>]
        
        for priceCategoryDictionary in priceCategoryDictionaries {
            
            let priceCategory = PriceCategory(priceCategoryDictionary: priceCategoryDictionary);
            priceCategories[priceCategory.name] = priceCategory
        }
        
    }
    
    
    
}