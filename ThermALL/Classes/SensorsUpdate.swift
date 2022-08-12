//
//  SensorsUpdate.swift
//

import Foundation

public class SensorsUpdate: NSObject {
    @objc public dynamic var socTemperature: NSNumber?
    @objc public dynamic var sensors: [ String : Double ] = [:]
    
    private var updating = false
    
    private static var queue = DispatchQueue( label: "com.jamesdbailey.ThermALL.SensorsUpdate", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: nil )
    
    func readSensors(smc: SMC, prefix: String) -> Dictionary<String, Double> {
        var dict = [String: Double]()
        var keys = smc.getAllKeys()
        keys = keys.filter{ $0.hasPrefix(prefix)}
        keys.forEach {
            (key: String) in
            let value = smc.getValue(key)
            dict[key] = value
        }
        
        return dict
    }

    public override init() {
        super.init()
    }
    
    private func readSMCTemperatureSensors() -> [ String :  Double ] {
        let smc = SMC()

        return Dictionary( uniqueKeysWithValues:
            readSensors(smc: smc, prefix: "T").map {
                ( $0.key, $0.value )
            }
        )
    }
    
    private func readHIDTemperatureSensors() -> [ String :  Double ] {
        return Dictionary( uniqueKeysWithValues:
            readHIDAppleSMCTemperatureSensors().map {
                ( $0.key, $0.value )
            }
        )
    }
    
    public func update( completion: @escaping () -> Void ) {
        SensorsUpdate.queue.async {
            if self.updating {
                completion()

                return
            }
            
            self.updating = true
            
            let sensors = self.readHIDTemperatureSensors()
            let all = sensors.mapValues { $0 }
            var temperature = 0.0
            
            temperature = all.filter {
                let key = $0.key.lowercased()
                return key.hasSuffix( "tcal" ) == false && key.hasSuffix( "tr0z" ) == false
            }.reduce( 0.0 ) { r, v in v.value > r ? v.value : r }
            
            if temperature > 0 {
                self.sensors = sensors.filter {
                    let key = $0.key.lowercased()
                    return key.hasSuffix( "tcal" ) == false && key.hasSuffix( "tr0z" ) == false
                }
                
                self.socTemperature = NSNumber( value: temperature )
            }

            self.updating = false

            completion()
        }
    }
}
