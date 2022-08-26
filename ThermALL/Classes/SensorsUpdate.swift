//
//  SensorsUpdate.swift
//

import Foundation

let SMCM2TemperatureKeys: [String] = [
    "TPD0",
    "TPD1",
    "TPD2",
    "TPD3",
    "TPD4",
    "TPD5",
    "TPD6",
    "TPD7",
    "TPDX",
    "Te04",
    "Te05",
    "Te06",
    "Tg0e",
    "Tg0f",
    "Tg0m",
    "Tg0n",
    "Tg0q",
    "Tg0r",
    "Th04",
    "Th05",
    "Th06",
    "Th08",
    "Th09",
    "Th0A",
    "Th0C",
    "Th0D",
    "Th0E",
    "Th0G",
    "Th0H",
    "Th0I",
    "Th0K",
    "Th0L",
    "Th0M",
    "Tp00",
    "Tp01",
    "Tp02",
    "Tp04",
    "Tp05",
    "Tp06",
    "Tp08",
    "Tp09",
    "Tp0A",
    "Tp0C",
    "Tp0D",
    "Tp0E",
    "Tp0a",
    "Tp0b",
    "Tp0c",
    "Tp0e",
    "Tp0f",
    "Tp0g",
    "Tp0i",
    "Tp0j",
    "Tp0k",
    "Tp0m",
    "Tp0n",
    "Tp0o",
    "Tp0q",
    "Tp0r",
    "Tp0s",
    "Ts0K",
    "Ts0L",
    "Ts0M",
    "Ts0O",
    "Ts0P",
    "Ts0Q",
    "Ts0S",
    "Ts0T",
    "Ts0U",
    "Ts0W",
    "Ts0X",
    "Ts0Y",
    "Ts0a",
    "Ts0b",
    "Ts0c"
]

let kAppleSMCCalibrationSensors = ["tcal", "TR0Z"]
func skipCalibrationSensors(name: String) -> Bool {
    for match in kAppleSMCCalibrationSensors {
        if name.hasSuffix(match) {
            return false
        }
    }
    
    return true
}

public class SensorsUpdate: NSObject {
    @objc public dynamic var socTemperature: NSNumber?
    @objc public dynamic var sensors: [ String : Double ] = [:]
    
    private var updating = false
    
    private static var queue = DispatchQueue( label: "com.jamesdbailey.ThermALL.SensorsUpdate", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: nil )
    
    func readSensors(smc: SMC, prefix: String) -> Dictionary<String, Double> {
        var dict = [String: Double]()
        var keys = smc.getAllKeys()
        keys = keys.filter {
            $0.hasPrefix(prefix)
        }
        keys.forEach {
            (key: String) in
            let value = smc.getValue(key)
            dict[key] = value
        }
        
        return dict
    }

    func readSensors(smc: SMC) -> Dictionary<String, Double> {
        var dict = [String: Double]()
        var keys = smc.getAllKeys()
        keys = keys.filter {
            SMCM2TemperatureKeys.contains($0)
        }
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
    
    private func readSMCTemperatureSensors() -> [ String : Double ] {
        let smc = SMC()

        return Dictionary( uniqueKeysWithValues:
            readSensors(smc: smc).map {
                ( $0.key, $0.value )
            }
        )
    }
    
    private func readHIDTemperatureSensors() -> [ String : Double ] {
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
            
            let hidSensors = self.readHIDTemperatureSensors()
            let smcSensors = self.readSMCTemperatureSensors()
            let filteredHID: [String:Double] = hidSensors.filter { skipCalibrationSensors(name: $0.key) }.mapValues { $0 }
            let allHID: [String:Double] = hidSensors.mapValues { $0 }
            let allSMC: [String:Double] = smcSensors.mapValues { $0 }
            var temperature = 0.0
            var allSensors: [String:Double] = allSMC
            
            allSensors.merge(filteredHID) { (_, current) in current }
            temperature = allSensors.reduce( 0.0 ) { r, v in v.value > r ? v.value : r }
            
            if temperature > 0 {
                allSensors.merge(allHID) { (_, current) in current }
                self.sensors = allSensors
                
                self.socTemperature = NSNumber( value: temperature )
            }

            self.updating = false

            completion()
        }
    }
}
