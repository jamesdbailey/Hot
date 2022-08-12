//
//  PreferencesPaneController.swift
//

import Cocoa

public class PreferencesPaneController: NSWindowController {
    @objc public dynamic var displaySoCTemperature = UserDefaults.standard.bool( forKey: "displaySoCTemperature" ) {
        didSet {
            UserDefaults.standard.setValue( self.displaySoCTemperature, forKey: "displaySoCTemperature" )
        }
    }
    
    @objc public dynamic var toDegF = UserDefaults.standard.bool( forKey: "toDegF" ) {
        didSet {
            UserDefaults.standard.setValue( self.toDegF, forKey: "toDegF" )
        }
    }
    
    @objc public dynamic var hideMenuIcon = UserDefaults.standard.bool( forKey: "hideMenuIcon" ) {
        didSet {
            UserDefaults.standard.setValue( self.hideMenuIcon, forKey: "hideMenuIcon" )
        }
    }
    
    public override var windowNibName: NSNib.Name? {
        return "PreferencesPaneController"
    }
}
