//
//  CoreDataStack.swift
//  RemoteData_and_CoreData
//
//  Created by David on 01/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    private init() {}
    static let shared = CoreDataStack()
    
    
    lazy var persistanceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StarWars")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    
}
