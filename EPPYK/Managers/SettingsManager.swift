//
//  SettingsManager.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 19/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation


class SettingsManager: NSObject {
    static let sharedInstance = SettingsManager()
    private static let configFile = "Config.plist"
    
    static let UpdateAfter = "updated_after"
    static let SelectedL10N = "selected_l10n"
    
    
    func getValue(key: String) -> String? {
        var date : String? = nil
        var myDict: NSDictionary?
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent(SettingsManager.configFile)
        myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            date = dict.objectForKey(key) as! String?
        }
        return date
    }
    
    func setValue(date: String, key: String) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent(SettingsManager.configFile)
        
        var currDict = NSMutableDictionary(contentsOfFile: path)
        if currDict == nil {
            currDict = NSMutableDictionary.init(object: "DoNotEverChangeMe", forKey: "XInitializerItem")
        }
        
        currDict!.setObject(date, forKey: key)
        
        //writing to GameData.plist
        currDict!.writeToFile(path, atomically: false)
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved Config.plist file is --> \(resultDictionary?.description)")
        
    }
    
}