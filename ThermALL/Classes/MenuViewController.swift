//
//  MenuViewController.swift
//

import Cocoa

public class MenuViewController: NSViewController {
    private var timer: Timer?
    private var observations: [ NSKeyValueObservation ] = []
    
    @objc public private( set ) dynamic var sensors = SensorsUpdate()
    @objc public private( set ) dynamic var socTemperature: Int = 0

    @IBOutlet private var graphView: GraphView!
    @IBOutlet private var graphViewHeight: NSLayoutConstraint!
    
    public var onUpdate: ( () -> Void )?
    let kTimerInterval = 5.0
    let kTimerTolerance = 0.5
    let kGraphHeight = 100.0
    
    public override var nibName: NSNib.Name? {
        "MenuViewController"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.graphViewHeight.constant = 0
        
        self.setTimer()
        self.sensors.update {
            DispatchQueue.main.async
            {
                self.update()
            }
        }
    }
    
    private func setTimer() {
        self.timer?.invalidate()
        let interval = kTimerInterval
        let timer = Timer( timeInterval: Double( interval ), repeats: true ) {
            _ in self.sensors.update {
                DispatchQueue.main.async {
                    self.update()
                }
            }
        }
        
        timer.tolerance = kTimerTolerance
        RunLoop.main.add( timer, forMode: .common )
        self.timer = timer
    }
    
    private func update() {
        if let temperature = self.sensors.socTemperature?.intValue {
            self.socTemperature = temperature
        }
        
        if self.socTemperature > 0 {
            self.graphView.addData( temperature: self.socTemperature )
        }
        
        if graphView.canDisplay {
            self.graphViewHeight.constant = kGraphHeight
        }

        self.onUpdate?()
    }
}
