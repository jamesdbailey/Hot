/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2020 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

public class ThermalLog: NSObject
{
    @objc public dynamic var cpuTemperature: NSNumber?
    @objc public dynamic var sensors:        [ String : Double ] = [:]
    
    private var refreshing = false
    
    private static var queue = DispatchQueue( label: "com.jamesdbailey.Hot.ThermalLog", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: nil )
    
    public override init()
    {
        super.init()
    }
    
    private func readTemperatureSensors() -> [ String :  Double ]
    {
         Dictionary( uniqueKeysWithValues:
            ReadSensors().map
            {
                ( $0.key, $0.value.doubleValue )
            }
        )
    }
    
    public func refresh( completion: @escaping () -> Void )
    {
        ThermalLog.queue.async
        {
            if self.refreshing
            {
                completion()

                return
            }
            
            self.refreshing = true
            
            let sensors = self.readTemperatureSensors()
            let all     = sensors.mapValues { $0 }
            var temp    = 0.0

            temp = all.filter
            {
                let k = $0.key.lowercased()
                return k.hasSuffix( "tcal" ) == false && k.hasSuffix( "tr0z" ) == false
            }
            .reduce( 0.0 )
            {
                r, v in v.value > r ? v.value : r
            }

            if temp > 1
            {
                self.sensors        = sensors
                let n = NSNumber( value: temp )
                self.cpuTemperature = n
            }

            self.refreshing = false

            completion()
        }
    }
}
