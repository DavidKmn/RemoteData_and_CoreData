//
//  DataProvider.swift
//  RemoteData_and_CoreData
//
//  Created by David on 01/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import CoreData

class DataProvider {
    
    private let persistentContainer: NSPersistentContainer
    private let repository: ApiRepository
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(persistentContainer: NSPersistentContainer, repository: ApiRepository) {
        self.persistentContainer = persistentContainer
        self.repository = repository
    }
    
    func fetchFilms(competion: @escaping (Error?) -> Void) {
        repository.getFilms { (result) in
            switch result {
            case .success(let jsonDict):
               
                let taskContext = self.persistentContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil
                
                _ = self.syncFilms(jsonDictionary: jsonDict, taskContext: taskContext)
                
                competion(nil)
            case .failure(let error):
                competion(error)
                break
            }
        }
    }
    
    private func syncFilms(jsonDictionary: [[String: Any]], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Film")
            let episodeIds = jsonDictionary.map { $0["episode_id"] as? Int }.compactMap { $0 }
            matchingEpisodeRequest.predicate = NSPredicate(format: "episodeId in %@", argumentArray: [episodeIds])
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIds = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIds], into: [self.persistentContainer.viewContext])
                }
            } catch {
                print("Error: \(error)\nCould not batch delete existing records.")
                return
            }
            
            for filmDict in jsonDictionary {
                
//                guard let entityDescription = NSEntityDescription.entity(forEntityName: "Film", in: taskContext), let film = NSManagedObject(entity: entityDescription, insertInto: taskContext) as? Film else { return }
                
                
                guard let film = NSEntityDescription.insertNewObject(forEntityName: "Film", into: taskContext) as? Film else {
                    print("Error: Failed to create a new Film object!")
                    return
                }
                
                do {
                    try film.update(with: filmDict)
                } catch {
                    print("Error: \(error)\nThe film object will be deleted.")
                    taskContext.delete(film)
                }
            }
            
            // Save all the changes just made and reset the taskContext to free up the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                // Reset the context to clean up the cache and low the memory footprint.
                taskContext.reset()
            }
            successfull = true
        }
        return successfull
    }
}
