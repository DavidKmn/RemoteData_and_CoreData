//
//  Film.swift
//  RemoteData_and_CoreData
//
//  Created by David on 01/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import CoreData

class Film: NSManagedObject {
    
    @NSManaged var director: String
    @NSManaged var episodeId: NSNumber
    @NSManaged var openingCrawl: String
    @NSManaged var producer: String
    @NSManaged var releaseDate: Date
    @NSManaged var title: String
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()
    
    func update(with jsonDict: [String: Any]) throws {
        guard let director = jsonDict["director"] as? String,
            let episodeId = jsonDict["episode_id"] as? Int,
            let openingCrawl = jsonDict["opening_crawl"] as? String,
            let producer = jsonDict["producer"] as? String,
            let releaseDate = jsonDict["release_date"] as? String,
            let title = jsonDict["title"] as? String else {
                throw NSError(domain: "", code: 100, userInfo: nil)
        }
        self.director = director
        self.episodeId = NSNumber(value: episodeId)
        self.openingCrawl = openingCrawl
        self.producer = producer
        self.releaseDate = Film.dateFormatter.date(from: releaseDate) ?? Date(timeIntervalSince1970: 0)
        self.title = title
    }
}
