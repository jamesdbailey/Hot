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

import Cocoa

public class InfoViewController: NSViewController
{
    private var timer:        Timer?
    private var observations: [ NSKeyValueObservation ] = []
    
    @objc public private( set ) dynamic var log                 = ThermalLog()
    @objc public private( set ) dynamic var cpuTemperature: Int = 0

    @IBOutlet private var graphView:       GraphView!
    @IBOutlet private var graphViewHeight: NSLayoutConstraint!
    
    public var onUpdate: ( () -> Void )?

    let timerInterval = 5.0
    
    public override var nibName: NSNib.Name?
    {
        "InfoViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.graphViewHeight.constant = 0
        
        self.setTimer()
        self.log.refresh
        {
            DispatchQueue.main.async
            {
                self.update()
            }
        }
    }
    
    private func setTimer()
    {
        self.timer?.invalidate()
        let interval = timerInterval
        let timer = Timer( timeInterval: Double( interval ), repeats: true )
        {
            _ in self.log.refresh
            {
                DispatchQueue.main.async
                {
                    self.update()
                }
            }
        }
        
        RunLoop.main.add( timer, forMode: .common )
        
        self.timer = timer
    }
    
    private func update()
    {
        if let n = self.log.cpuTemperature?.intValue
        {
            self.cpuTemperature = n
        }
        
        if self.cpuTemperature > 0
        {
            self.graphView.addData( temperature: self.cpuTemperature )
        }
        
        self.graphViewHeight.constant = self.graphView.canDisplay ? 100 : 0
        
        self.onUpdate?()
    }
}
