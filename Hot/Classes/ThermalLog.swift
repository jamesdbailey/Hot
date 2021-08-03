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
    @objc public dynamic var gpuTemperature: NSNumber?
    @objc public dynamic var sensors:        [ String : Double ] = [:]
    
    private var refreshing = false
    
    private static var queue = DispatchQueue( label: "com.xs-labs.Hot.ThermalLog", qos: .background, attributes: [], autoreleaseFrequency: .workItem, target: nil )
    
    public override init()
    {
        super.init()
        self.refresh()
    }
    
    private func readTemperatureSensors() -> [ String : Double ]
    {
        #if arch( arm64 )
        
        Dictionary( uniqueKeysWithValues:
            ReadM1Sensors().filter
            {
                $0.key.hasPrefix( "pACC" ) || $0.key.hasPrefix( "eACC" ) ||
            $0.key.hasPrefix( "SOC" ) || $0.key.hasPrefix( "PMGR" ) ||
            $0.key.hasPrefix( "GPU" ) || $0.key.hasPrefix( "ANE" )
            }
            .map
            {
                ( $0.key, $0.value.doubleValue )
            }
        )
        
        #else
        
        [ "TCXC" : SMCGetCPUTemperature() ]
        
        #endif
    }
    
    private func readCPUSensors() -> [ String : Double ]
    {
        #if arch( arm64 )
        
        Dictionary( uniqueKeysWithValues:
            ReadM1Sensors().filter
            {
                $0.key.hasPrefix( "pACC" ) || $0.key.hasPrefix( "eACC" )
            }
            .map
            {
                ( $0.key, $0.value.doubleValue )
            }
        )
        
        #else
        
        [ "TCXC" : SMCGetCPUTemperature() ]
        
        #endif
    }

    private func readGPUSensors() -> [ String : Double ]
    {
        #if arch( arm64 )
        
        Dictionary( uniqueKeysWithValues:
            ReadM1Sensors().filter
            {
                $0.key.hasPrefix( "GPU" )
            }
            .map
            {
                ( $0.key, $0.value.doubleValue )
            }
        )
        
        #else
        
        [ "TCXC" : SMCGetCPUTemperature() ]
        
        #endif
    }
    public func refresh()
    {
        ThermalLog.queue.async
        {
            if self.refreshing
            {
                return
            }
            
            self.refreshing = true
            
            let cpuSensors = self.readCPUSensors()
            let cpuTemp    = cpuSensors.reduce( 0.0 )
            {
                r, v in v.value > r ? v.value : r
            }

            let gpuSensors = self.readGPUSensors()
            let gpuTemp    = gpuSensors.reduce( 0.0 )
            {
                r, v in v.value > r ? v.value : r
            }

            if cpuTemp > 1 || gpuTemp > 1
            {
                DispatchQueue.main.async
                {
                    self.sensors        = self.readTemperatureSensors()
                    self.cpuTemperature = NSNumber( value: cpuTemp )
                    self.gpuTemperature = NSNumber( value: gpuTemp )
                }
            }
            
            self.refreshing = false
        }
    }
}
