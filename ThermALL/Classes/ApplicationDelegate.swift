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

@NSApplicationMain
class ApplicationDelegate: NSObject, NSApplicationDelegate
{
    private var statusItem:                  NSStatusItem?
    private var aboutWindowController:       AboutWindowController?
    private var preferencesWindowController: PreferencesWindowController?
    private var observations:                [ NSKeyValueObservation ] = []
    private var sensorViewControllers:       [ SensorViewController  ] = []
    
    @IBOutlet private var menu:        NSMenu!
    @IBOutlet private var sensorsMenu: NSMenu!
    
    @objc public private( set ) dynamic var infoViewController: InfoViewController?
    
    deinit
    {
        UserDefaults.standard.removeObserver( self, forKeyPath: "displayCPUTemperature" )
        UserDefaults.standard.removeObserver( self, forKeyPath: "convertToFahrenheit" )
        UserDefaults.standard.removeObserver( self, forKeyPath: "hideStatusIcon" )
    }
    
    func applicationDidFinishLaunching( _ notification: Notification )
    {
        if UserDefaults.standard.object( forKey: "LastLaunch" ) == nil
        {
            UserDefaults.standard.setValue( true,     forKey: "displayCPUTemperature" )
            UserDefaults.standard.setValue( NSDate(), forKey: "LastLaunch" )
        }
        
        self.aboutWindowController             = AboutWindowController()
        self.preferencesWindowController       = PreferencesWindowController()
        self.statusItem                        = NSStatusBar.system.statusItem( withLength: NSStatusItem.variableLength )
        self.statusItem?.button?.image         = NSImage( systemSymbolName: "flame.fill", accessibilityDescription: nil )
        self.statusItem?.button?.imagePosition = .imageLeading
        self.statusItem?.button?.font          = NSFont.monospacedDigitSystemFont( ofSize: NSFont.smallSystemFontSize, weight: .light )
        self.statusItem?.menu                  = self.menu
        
        let infoViewController             = InfoViewController()
        self.infoViewController            = infoViewController
        self.menu.item( withTag: 1 )?.view = infoViewController.view
        
        self.infoViewController?.onUpdate  =
        {
            [ weak self ] in
            
            self?.updateTitle()
            self?.updateSensors()
        }

        UserDefaults.standard.addObserver( self, forKeyPath: "displayCPUTemperature",  options: [], context: nil )
        UserDefaults.standard.addObserver( self, forKeyPath: "convertToFahrenheit",    options: [], context: nil )
        UserDefaults.standard.addObserver( self, forKeyPath: "hideStatusIcon",         options: [], context: nil )
    }
    
    override func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [ NSKeyValueChangeKey : Any ]?, context: UnsafeMutableRawPointer? )
    {
        let keyPaths =
        [
            "displayCPUTemperature",
            "convertToFahrenheit",
            "hideStatusIcon"
        ]
        
        if let keyPath = keyPath, let object = object as? NSObject, object == UserDefaults.standard && keyPaths.contains( keyPath )
        {
            self.updateTitle()
            self.updateSensors()
        }
        else
        {
            super.observeValue( forKeyPath: keyPath, of: object, change: change, context: context )
        }
    }
    
    @IBAction public func showAboutWindow( _ sender: Any? )
    {
        guard let window = self.aboutWindowController?.window else
        {
            NSSound.beep()
            
            return
        }
        
        if window.isVisible == false
        {
            window.layoutIfNeeded()
            window.center()
        }
        
        NSApp.activate( ignoringOtherApps: true )
        window.makeKeyAndOrderFront( nil )
    }
    
    @IBAction public func showPreferencesWindow( _ sender: Any? )
    {
        guard let window = self.preferencesWindowController?.window else
        {
            NSSound.beep()
            
            return
        }
        
        if window.isVisible == false
        {
            window.layoutIfNeeded()
            window.center()
        }
        
        NSApp.activate( ignoringOtherApps: true )
        window.makeKeyAndOrderFront( nil )
    }
        
    private func updateTitle()
    {
        var title       = ""
        let transformer = TemperatureToString()
        
        if let n = self.infoViewController?.cpuTemperature,
                UserDefaults.standard.bool( forKey: "displayCPUTemperature" ),
                n > 0
        {
            title = transformer.transformedValue( n ) as? String ?? "--"
        }
        
        if title.count == 0
        {
            self.statusItem?.button?.title = ""
        }
        else
        {
            let color: NSColor =
            {
                return .controlTextColor
            }()
            
            self.statusItem?.button?.attributedTitle = NSAttributedString( string: title, attributes: [ .foregroundColor : color ] )
        }
        
        if UserDefaults.standard.bool( forKey: "hideStatusIcon" ) && title.count > 0
        {
            self.statusItem?.button?.image = nil
        }
        else
        {
            self.statusItem?.button?.image = NSImage( systemSymbolName: "flame.fill", accessibilityDescription: nil )
        }
    }
    
    private func updateSensors()
    {
        self.sensorsMenu.removeAllItems()
        self.sensorViewControllers.removeAll()
        
        self.infoViewController?.log.sensors.sorted
        {
            $0.key.lowercased().compare( $1.key.lowercased() ) == .orderedAscending
        }
        .forEach
        {
            let controller   = SensorViewController()
            controller.name  = $0.key
            controller.value = Int( $0.value )
            let item         = NSMenuItem( title: $0.key, action: nil, keyEquivalent: "" )
            item.view        = controller.view
            
            self.sensorsMenu.addItem( item )
        }
    }
}