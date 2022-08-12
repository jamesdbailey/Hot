//
//  TemperatureWithDefaultsToString.swift
//

import Cocoa

@objc( TemperatureWithDefaultsToString )
public class TemperatureWithDefaultsToString: ValueTransformer {
    public override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    public override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    public override func transformedValue( _ value: Any? ) -> Any? {
        guard var temperature = value as? Int, temperature > 0 else {
            return "--" as NSString
        }
        
        if UserDefaults.standard.bool( forKey: "toDegF" ) {
            temperature = Int( Double( temperature ) * 1.8 + 32 )
        }
        
        let degree = UserDefaults.standard.bool( forKey: "toDegF" ) ? "F" : "C"
        
        return "\( temperature )°\( degree )" as NSString
    }
}
