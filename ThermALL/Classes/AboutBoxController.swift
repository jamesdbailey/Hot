//
//  AboutBoxController.swift
//

import Cocoa

public class AboutBoxController: NSWindowController {
    @objc private dynamic var name: String?
    @objc private dynamic var version: String?
    @objc private dynamic var copyright: String?
    
    public override var windowNibName: NSNib.Name? {
        return "AboutBoxController"
    }
    
    override public func windowDidLoad() {
        super.windowDidLoad()
        
        let version = Bundle.main.object( forInfoDictionaryKey: "CFBundleShortVersionString" ) as? String ?? "0.0.0"
        
        if let build = Bundle.main.object( forInfoDictionaryKey: "CFBundleVersion" ) as? String {
            self.version = "\(version) (\(build))"
        } else {
            self.version = version
        }
        
        self.name = Bundle.main.object( forInfoDictionaryKey: "CFBundleName" ) as? String
        self.copyright = Bundle.main.object( forInfoDictionaryKey: "NSHumanReadableCopyright" ) as? String
    }
}
