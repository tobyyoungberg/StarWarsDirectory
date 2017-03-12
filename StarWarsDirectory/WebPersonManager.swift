//
//  WebPersonManager.swift
//  StarWarsDirectory
//
//  Created by Toby Youngberg on 3/9/17.
//  Copyright © 2017 Toby Youngberg. All rights reserved.
//

import Foundation
import RealmSwift

enum WebPersonManagerError : Error {
    case invalidJSON
    case httpError
}

let personBirthDateKey = "birthdate"
let personIndividuals = "individuals"

class WebPersonManager {
    static let shared = WebPersonManager()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let url = URL(string: "https://edge.ldscdn.org/mobile/interview/directory")!
    var dataTask : URLSessionDataTask?
    
    func updatePeopleFromWeb(completion: ((_ error: WebPersonManagerError?)->())?) {
        if self.dataTask != nil {
            self.dataTask?.cancel()
        }
        
        self.dataTask = session.dataTask(with: url) { data, response, error in
            if error == nil, let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                guard let personData = try? JSONSerialization.jsonObject(with: data, options: []),
                    JSONSerialization.isValidJSONObject(personData),
                    let personDict = personData as? [String : Any],
                    let personArray = personDict[personIndividuals] as? [Any] else {
                        
                        completion?(WebPersonManagerError.invalidJSON)
                        return
                }
                
                DispatchQueue.global().async {
                    if let realm = try? Realm() {
                        realm.beginWrite()
                        
                        // Currently, the endpoint does not provide unique identifiers for Person objects.
                        // Because of this, we will have to delete all existing data and replace it. When/If
                        // unique identifiers are added to the endpoint, we can support Insert, Update, and
                        // Delete operations on the objects in the database.
                        realm.deleteAll()
                        
                        Person.parsePeople(realm: realm, personArray: personArray)
                        
                        try? realm.commitWrite()
                        completion?(nil)
                    }
                }
            } else {
                NSLog("WebPersonManager: HTTP Error %@", error?.localizedDescription ?? "Unknown Error")
                completion?(WebPersonManagerError.httpError)
            }
            
        }
        self.dataTask?.resume()
    }
    

}
