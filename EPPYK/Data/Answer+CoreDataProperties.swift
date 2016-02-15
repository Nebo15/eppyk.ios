//
//  Answer+CoreDataProperties.swift
//  
//
//  Created by Anton Rogachevskiy on 28/01/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Answer {

    @NSManaged var id: String?
    @NSManaged var text: String?

}
