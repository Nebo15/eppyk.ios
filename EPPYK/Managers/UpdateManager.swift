//
//  UpdateManager.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 14/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation

enum UMRequest: String {
    case Answers = "/locales/en_US/answers"
    
}

class UpdateManager: NSObject {

    static let sharedInstance = UpdateManager()
    private let manager = AFHTTPRequestOperationManager()
    private let url = "http://128.199.50.95/api/v1"
    
    
    func updateAnswers() {
        
        var params : Dictionary<String, String>? = nil
        if let date = self.getUpdateAfter() {
            params = ["updated_after": date]
        }
        
        manager.GET( String(format: "%@%@", url, UMRequest.Answers.rawValue),
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                print("JSON: " + responseObject.description)

                let code = responseObject["meta"]!!["code"]
                if let _code = code where _code as! Int == 200 {
                    let data: Array<Dictionary<String, String>> = responseObject["data"] as! Array
                    for item in data {
                        guard let dbAnswer = QAManager.sharedInstance.findAnswerById(item["id"]!) else {
                            QAManager.sharedInstance.addAnswer(item["id"]!, text: item["text"]!)
                            continue
                        }
                        dbAnswer.text = item["text"]!
                        QAManager.sharedInstance.editAnswer(dbAnswer)
                    }
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.setUpdateAfter(dateFormatter.stringFromDate(NSDate()))
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: NSError!) in
                print("Error: " + error.localizedDescription)
        })
    }
    
    private func getUpdateAfter() -> String? {
        var date : String? = nil
        var myDict: NSDictionary?
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Config.plist")
        myDict = NSDictionary(contentsOfFile: path)

        if let dict = myDict {
            date = dict.objectForKey("updated_after") as! String?
        }
        return date
    }
    
    private func setUpdateAfter(date: String) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Config.plist")
        
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        dict.setObject(date, forKey: "updated_after")
        
        //writing to GameData.plist
        dict.writeToFile(path, atomically: false)
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print("Saved Config.plist file is --> \(resultDictionary?.description)")
        
    }
    
    

}