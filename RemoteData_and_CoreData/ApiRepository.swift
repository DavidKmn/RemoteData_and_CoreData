//
//  ApiRepository.swift
//  RemoteData_and_CoreData
//
//  Created by David on 01/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation

enum ApiError: Error {
    case invalidHttpResonse
    case outOfBoundsStatusCode(Int)
    case fetchIssue(String)
    case emptyData
}

enum DataError: Error {
    case unwrapingError
    case dataDecoding(String)
}

enum ApiResult<T> {
    case success(T)
    case failure(Error)
}

class ApiRepository {
    
    private init() {}
    static let shared = ApiRepository()
    
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://swapi.co/api/")!
    
    func getFilms(completion: @escaping ((ApiResult<[[String: Any]]>) -> Void)) {
        let filmURL = baseURL.appendingPathComponent("films")
        urlSession.dataTask(with: filmURL) { (data, response, error) in
            
            if let error = error {
                completion(.failure(ApiError.fetchIssue(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(ApiError.invalidHttpResonse))
                return
            }
            
            let statusCode = httpResponse.statusCode
            guard (0..<300) ~= statusCode else {
                completion(.failure(ApiError.outOfBoundsStatusCode(statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.emptyData))
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDict = jsonObject as? [String: Any], let result = jsonDict["results"] as? [[String: Any]] else {
                    completion(.failure(DataError.unwrapingError))
                    return
                }
                completion(.success(result))
            } catch let decodingError {
            completion(.failure(DataError.dataDecoding(decodingError.localizedDescription)))
            }
        }.resume()
    }
}
