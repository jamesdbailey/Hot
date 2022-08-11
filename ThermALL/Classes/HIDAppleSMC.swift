//
//  HIDAppleSMC.swift
//  ThermALL
//
//  Created by jdb on 8/10/22.
//

let kIOHIDEventTypeTemperature = 15
let kAppleSMCUsagePage = 0xff00
let kAppleSMCUsage = 5
let kAppleSMCCalibrationSensors = ["tcal", "TR0Z"]

func IOHIDEventField(type: Int) -> Int32 {
    return Int32(type << 16)
}

func readHIDAppleSMCTemperatureSensors() -> Dictionary<String, Double> {
    let sensors = [ "PrimaryUsagePage": kAppleSMCUsagePage, "PrimaryUsage": kAppleSMCUsage ]
    
    let system = IOHIDEventSystemClientCreate(
        CFAllocatorGetDefault().takeRetainedValue()
    ).takeRetainedValue()
    
    IOHIDEventSystemClientSetMatching(system, sensors as CFDictionary)
    
    let matching_srvs = IOHIDEventSystemClientCopyServices(system)!
    let matchingCount = CFArrayGetCount(matching_srvs) - 1
    var sensorDictionary: [String : Double] = [:]
    for i in 0...matchingCount {
        let sc = unsafeBitCast(CFArrayGetValueAtIndex(matching_srvs, i), to:  IOHIDServiceClient.self)
        if let p = IOHIDServiceClientCopyProperty(sc, __CFStringMakeConstantString("Product")) {
            let name = p as!String
            let event = IOHIDServiceClientCopyEvent(sc, Int64(kIOHIDEventTypeTemperature), 0, 0)
            
            if (event != nil && !name.hasSuffix(kAppleSMCCalibrationSensors[0]) && !name.hasSuffix(kAppleSMCCalibrationSensors[1])) {
                let temp = IOHIDEventGetFloatValue(event, IOHIDEventField(type: kIOHIDEventTypeTemperature));
                if (temp > 0) {
                    sensorDictionary[name] = temp;
                }
            }
        }
    }
    
    return sensorDictionary
}
