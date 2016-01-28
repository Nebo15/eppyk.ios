//
//  QAManager.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 28/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import CoreData


class QAManager {
    static let sharedInstance = QAManager()
    
    func addAnswer(text: String) {
        
        // create an instance of our managedObjectContext
        let moc = agManagedObjectContext!
        let entity = NSEntityDescription.insertNewObjectForEntityForName("AnswerEntity", inManagedObjectContext: moc) as! Answer
        
        // add a data
        entity.setValue(text, forKey: "text")
        
        // Save the entity
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    func fetchAnswer() ->String {
        guard let dbAnswer = self.fetchAnswerDB() else {
            return self.fetchAnswerL10n()
        }
        return dbAnswer
    }

    func fetchAnswerL10n() -> String {
        let answersCount = Int.init("count".localizedAnswer)!
        let answerId = Int(arc4random_uniform(UInt32.init(answersCount)))
        let text = "answer\(answerId)".localizedAnswer
        return text
    }
    
    
    func fetchAnswerDB() -> String? {
        let moc = agManagedObjectContext!
        let personFetch = NSFetchRequest(entityName: "AnswerEntity")
        var answerText: String? = nil
        do {
            let fetchedAnswer = try moc.executeFetchRequest(personFetch) as! [Answer]
            
            if !fetchedAnswer.isEmpty {
                let position = Int(arc4random_uniform(UInt32.init(fetchedAnswer.count)))
                answerText = fetchedAnswer[position].text
            }
        } catch {}
        return answerText
    }
    
    
}