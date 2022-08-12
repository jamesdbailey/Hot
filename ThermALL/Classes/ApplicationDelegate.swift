//
//  ApplicationDelegate.swift
//

import Cocoa

@NSApplicationMain
class ApplicationDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var aboutBoxController: AboutBoxController?
    private var preferencesPaneController: PreferencesPaneController?
    private var observations: [ NSKeyValueObservation ] = []
    private var sensorViewControllers: [ SensorViewController  ] = []
    
    @IBOutlet private var menu: NSMenu!
    @IBOutlet private var sensorsMenu: NSMenu!
    
    @objc public private( set ) dynamic var menuViewController: MenuViewController?
    
    deinit {
        UserDefaults.standard.removeObserver( self, forKeyPath: "displaySoCTemperature" )
        UserDefaults.standard.removeObserver( self, forKeyPath: "hideMenuIcon" )
        UserDefaults.standard.removeObserver( self, forKeyPath: "toDegF" )
    }
    
    func applicationDidFinishLaunching( _ notification: Notification ) {
        if UserDefaults.standard.object( forKey: "LastLaunch" ) == nil {
            UserDefaults.standard.setValue( true, forKey: "displaySoCTemperature" )
            UserDefaults.standard.setValue( NSDate(), forKey: "LastLaunch" )
        }
        
        self.aboutBoxController  = AboutBoxController()
        self.preferencesPaneController = PreferencesPaneController()
        self.statusItem = NSStatusBar.system.statusItem( withLength: NSStatusItem.variableLength )
        self.statusItem?.button?.font = NSFont.monospacedDigitSystemFont( ofSize: NSFont.smallSystemFontSize, weight: .light )
        self.statusItem?.button?.image = NSImage( systemSymbolName: "flame.fill", accessibilityDescription: nil )
        self.statusItem?.button?.imagePosition = .imageLeading
        
        let menuViewController  = MenuViewController()
        self.menuViewController = menuViewController
        self.menu.item( withTag: 1 )?.view = menuViewController.view
        
        self.statusItem?.menu = self.menu

        self.menuViewController?.onUpdate  = { [ weak self ] in
            guard let self = self else {
                return
            }
            
            self.updateTitle()
            self.updateSensors()
        }

        UserDefaults.standard.addObserver( self, forKeyPath: "displaySoCTemperature", options: [], context: nil )
        UserDefaults.standard.addObserver( self, forKeyPath: "hideMenuIcon", options: [], context: nil )
        UserDefaults.standard.addObserver( self, forKeyPath: "toDegF", options: [], context: nil )
    }
    
    override func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [ NSKeyValueChangeKey : Any ]?, context: UnsafeMutableRawPointer? ) {
        let keyPaths = [
            "displaySoCTemperature",
            "hideMenuIcon",
            "toDegF"
        ]
        
        if let keyPath = keyPath, let object = object as? NSObject, object == UserDefaults.standard && keyPaths.contains( keyPath ) {
            self.updateTitle()
            self.updateSensors()
        } else {
            super.observeValue( forKeyPath: keyPath, of: object, change: change, context: context )
        }
    }
    
    @IBAction public func showAboutBox( _ sender: Any? ) {
        guard let window = self.aboutBoxController?.window else {
            return
        }
        
        if window.isVisible == false {
            window.layoutIfNeeded()
            window.center()
        }
        
        NSApp.activate( ignoringOtherApps: true )
        window.makeKeyAndOrderFront( nil )
    }
    
    @IBAction public func showPreferencesPane( _ sender: Any? ) {
        guard let window = self.preferencesPaneController?.window else {
            return
        }
        
        if window.isVisible == false {
            window.layoutIfNeeded()
            window.center()
        }
        
        NSApp.activate( ignoringOtherApps: true )
        window.makeKeyAndOrderFront( nil )
    }
        
    private func updateTitle() {
        var title = ""
        let transformer = TemperatureWithDefaultsToString()
        
        if let n = self.menuViewController?.socTemperature,
                UserDefaults.standard.bool( forKey: "displaySoCTemperature" ),
                n > 0 {
            title = transformer.transformedValue( n ) as? String ?? "--"
        }
        
        if title.count == 0 {
            self.statusItem?.button?.title = ""
        } else {
            let color: NSColor = {
                .controlTextColor
            }()
            
            self.statusItem?.button?.attributedTitle = NSAttributedString( string: title, attributes: [ .foregroundColor : color ] )
        }
        
        if UserDefaults.standard.bool( forKey: "hideMenuIcon" ) && title.count > 0 {
            self.statusItem?.button?.image = nil
        } else {
            self.statusItem?.button?.image = NSImage( systemSymbolName: "flame.fill", accessibilityDescription: nil )
        }
    }
    
    private func updateSensors() {
        self.sensorsMenu.removeAllItems()
        self.sensorViewControllers.removeAll()
        
        self.menuViewController?.sensors.sensors.sorted {
            $0.key.lowercased().compare( $1.key.lowercased() ) == .orderedAscending
        }.forEach {
            let controller = SensorViewController()
            controller.name  = $0.key
            controller.value = Int( $0.value )
            let item = NSMenuItem( title: $0.key, action: nil, keyEquivalent: "" )
            item.view  = controller.view
            
            self.sensorsMenu.addItem( item )
        }
    }
}
