//
//  UpdateManager.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 14/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import AFNetworking

enum UMRequest: String {
    case Answers = "/locales/%@/answers"
    case L10Ns = "/locales"
}

class UpdateManager: NSObject {

    static let sharedInstance = UpdateManager()
    private let manager = AFHTTPRequestOperationManager()
    private let url = "http://128.199.50.95/api/v1"
    
    
    func updateAnswers(l10n: String) {
        
        var params : Dictionary<String, String>? = nil
        if let date = SettingsManager.sharedInstance.getValue(SettingsManager.UpdateAfter) {
            if let currentL10n = SettingsManager.sharedInstance.getValue(SettingsManager.SelectedL10N) where currentL10n == l10n {
                params = ["updated_after": date]
            }
        }
        
        print( String(format: "%@%@", url, String(format: UMRequest.Answers.rawValue, l10n)))
        manager.GET( String(format: "%@%@", url, String(format: UMRequest.Answers.rawValue, l10n)),
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                print("JSON: " + responseObject.description)
                var currentL10n = ""
                if let curr = SettingsManager.sharedInstance.getValue(SettingsManager.SelectedL10N) {
                    currentL10n = curr
                }
                
                var clearList = true;
                if let _clearList = (responseObject as! NSDictionary).objectForKey("meta")!.objectForKey("append") {
                    clearList = !(_clearList as! Bool)
                }
                
                let code = responseObject["meta"]!!["code"]
                
                if let _code = code where _code as! Int == 200 {
                    SettingsManager.sharedInstance.setValue(l10n, key: SettingsManager.SelectedL10N)
                    let data: Array<Dictionary<String, String>> = responseObject["data"] as! Array
                    
                    if clearList == true || (!data.isEmpty && l10n != currentL10n) {
                        QAManager.sharedInstance.deleteAllData()
                    }
                    for item in data {
                        let author = item["author"] == nil ? "" : item["author"]
                        guard let dbAnswer = QAManager.sharedInstance.findAnswerById(item["id"]!) else {
                            QAManager.sharedInstance.addAnswer(item["id"]!, text: item["text"]!, author: author)
                            continue
                        }
                        dbAnswer.text = item["text"]!
                        dbAnswer.author = author
                        QAManager.sharedInstance.editAnswer(dbAnswer)
                    }
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:s"
                    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
                    SettingsManager.sharedInstance.setValue(dateFormatter.stringFromDate(NSDate()), key: SettingsManager.UpdateAfter)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: NSError!) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    func updateL10ns(completion: (result: Bool, l10ns: [L10n]) -> Void) {

        manager.GET(String(format: "%@%@", url, UMRequest.L10Ns.rawValue),
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                print("JSON: " + responseObject.description)
                
                let code = responseObject["meta"]!!["code"]
                if let _code = code where _code as! Int == 200 {
                    var l10ns = [L10n]()
                    // Data
                    let data: Array<Dictionary<String, String>> = responseObject["data"] as! Array
                    for item in data {
                        let l10n = L10n(code:item["code"]!, id:item["id"]!, title: item["title"]!, description: item["description"])
                        l10ns.append(l10n)
                    }
                    completion(result: true, l10ns: l10ns)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: NSError!) in
                print("Error: " + error.localizedDescription)
                completion(result: false, l10ns: [L10n]())
        })
    }
    
    

}