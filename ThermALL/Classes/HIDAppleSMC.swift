//
//  HIDAppleSMC.swift
//

let kIOHIDEventTypeTemperature = 15
let kAppleSMCUsagePage = 0xff00
let kAppleSMCUsage = 5

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
    for matchIdx in 0...matchingCount {
        let serviceClient = unsafeBitCast(CFArrayGetValueAtIndex(matching_srvs, matchIdx), to:  IOHIDServiceClient.self)
        if let product = IOHIDServiceClientCopyProperty(serviceClient, __CFStringMakeConstantString("Product")) {
            let name = product as! String
            let event = IOHIDServiceClientCopyEvent(serviceClient, Int64(kIOHIDEventTypeTemperature), 0, 0)
            
            if event != nil {
                let temperature = IOHIDEventGetFloatValue(event, IOHIDEventField(type: kIOHIDEventTypeTemperature));
                if temperature > 0 {
                    sensorDictionary[name] = temperature;
                }
            }
        }
    }
    
    return sensorDictionary
}
