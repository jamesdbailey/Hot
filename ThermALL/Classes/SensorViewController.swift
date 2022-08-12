//
//  SensorViewController.swift
//

import Cocoa

public class SensorViewController: NSViewController {
    @objc private dynamic var icon  = NSImage( systemSymbolName: "questionmark", accessibilityDescription: nil )
    @objc private dynamic var label = "Unknown:"
    @objc public  dynamic var value = 0
    
    @objc public  dynamic var name  = "Unknown" {
        didSet {
            self.label = self.name.hasSuffix( ":" ) ? self.name : "\( self.name ):"
            
            if self.name.lowercased().hasPrefix( "nand" ) {
                self.icon = NSImage( systemSymbolName: "memorychip", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix( "gas" ) {
                self.icon = NSImage( systemSymbolName: "battery.100.bolt", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix("pmu") {
                if self.name.lowercased().hasPrefix("pmu2") {
                    self.icon = NSImage( systemSymbolName: "cpu.fill", accessibilityDescription: nil )
                } else {
                    self.icon = NSImage( systemSymbolName: "cpu", accessibilityDescription: nil )
                }
            } else if self.name.lowercased().hasPrefix( "eacc" ) {
                self.icon = NSImage( systemSymbolName: "leaf.fill", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix( "pacc" ) {
                self.icon = NSImage( systemSymbolName: "bolt.fill", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix( "tcxc" ) {
                self.icon = NSImage( systemSymbolName: "cpu.fill", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix( "soc" )
                        || self.name.lowercased().hasPrefix( "pmgr" )
                        || self.name.lowercased().hasPrefix( "gpu" ) {
                self.icon = NSImage( systemSymbolName: "cpu", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix( "ane" ) {
                self.icon = NSImage( systemSymbolName: "brain", accessibilityDescription: nil )
            } else if self.name.lowercased().hasPrefix( "isp" ) {
                self.icon = NSImage( systemSymbolName: "camera", accessibilityDescription: nil )
            } else {
                self.icon = NSImage( systemSymbolName: "cpu", accessibilityDescription: nil )
            }
        }
    }
    
    public override var nibName: NSNib.Name? {
        "SensorViewController"
    }
}
