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
    
    enum QASource: Int {
        case L10N = 0, DB = 1
    }
    
    static let sharedInstance = QAManager()
    
    
    func findAnswerById(id: String) -> Answer? {
        var answer : Answer? = nil
        let moc = agManagedObjectContext!
        let answerFetch = NSFetchRequest(entityName: "AnswerEntity")
        answerFetch.predicate = NSPredicate(format: "id == %@", id)
        do {
            let fetchedAnswer = try moc.executeFetchRequest(answerFetch) as! [Answer]
            if !fetchedAnswer.isEmpty {
                answer = fetchedAnswer[0]
            }
        } catch {}
        
        return answer
    }
    
    
    func addAnswer(id: String, text: String) {
        
        // create an instance of our managedObjectContext
        let moc = agManagedObjectContext!
        let entity = NSEntityDescription.insertNewObjectForEntityForName("AnswerEntity", inManagedObjectContext: moc) as! Answer
    
        // add a data
        entity.setValue(id, forKey: "id")
        entity.setValue(text, forKey: "text")
        
        // Save the entity
        do {
            try moc.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
    func deleteAllData()
    {
        let moc = agManagedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "AnswerEntity")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try moc.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                moc.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in AnswerEntity error : \(error) \(error.userInfo)")
        }
    }
    
    func editAnswer(answer: Answer) {
        do {
            try answer.managedObjectContext?.save()
        } catch {
            fatalError("Failure to edit context: \(error)")
        }
    }
    
    func getSource() -> QASource {
        let moc = agManagedObjectContext!
        let answerFetch = NSFetchRequest(entityName: "AnswerEntity")
        var count = 0
        var error: NSError? = nil
        count = moc.countForFetchRequest(answerFetch, error: &error)
        return count == 0 ? .L10N : .DB
    }
    
    func fetchAnswer() ->String {
        guard let dbAnswer = self.fetchAnswerDB().1 else {
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
    
    
    func fetchAnswerDB() -> (String?, String?)  {
        let moc = agManagedObjectContext!
        let answerFetch = NSFetchRequest(entityName: "AnswerEntity")
        var answerText: String? = nil
        var answerId: String? = nil
        do {
            let fetchedAnswer = try moc.executeFetchRequest(answerFetch) as! [Answer]
            
            if !fetchedAnswer.isEmpty {
                let position = Int(arc4random_uniform(UInt32.init(fetchedAnswer.count)))
                answerId = fetchedAnswer[position].id
                answerText = fetchedAnswer[position].text
            }
        } catch {}
        return (answerId, answerText)
    }
    
    
}