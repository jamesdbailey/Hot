//
//  HIDAppleSMC.swift
//  ThermALL
//
//  Created by jdb on 8/10/22.
//

let kIOHIDEventTypeTemperature = 15

// helper
func IOHIDEventFieldBase(type: Int) -> Int {
    return type << 16
}

func readHIDAppleSMCTemperatureSensors() -> Dictionary<String, Double> {
    let sensors = [ "PrimaryUsagePage" : 0xff00, "PrimaryUsage" : 5 ]
    
    let system = IOHIDEventSystemClientCreate(
        CFAllocatorGetDefault().takeRetainedValue()
    ).takeRetainedValue()
    
    IOHIDEventSystemClientSetMatching(system, sensors as CFDictionary)
    
    let matching_srvs = IOHIDEventSystemClientCopyServices(system)!
    let matchingCount = CFArrayGetCount(matching_srvs) - 1
    var dict: [String : Double] = [:]
    for i in 0...matchingCount {
        let sc = unsafeBitCast(CFArrayGetValueAtIndex(matching_srvs, i), to:  IOHIDServiceClient.self)
        if let p = IOHIDServiceClientCopyProperty(sc, __CFStringMakeConstantString("Product")) {
            let name = p as!String
            let event = IOHIDServiceClientCopyEvent(sc, Int64(kIOHIDEventTypeTemperature), 0, 0)
            
            if (event != nil && !name.hasSuffix("tcal") && !name.hasSuffix("TR0Z")) {
                let temp = IOHIDEventGetFloatValue(event, Int32(IOHIDEventFieldBase(type: kIOHIDEventTypeTemperature)));
                if (temp > 0) {
                    dict[name] = temp;
                }
            }
        }
    }
    
    return dict
}
