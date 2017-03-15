//
//  Person.swift
//  StarWarsDirectory
//
//  Created by Toby Youngberg on 3/8/17.
//  Copyright © 2017 Toby Youngberg. All rights reserved.
//

import UIKit
import RealmSwift

enum PersonAffiliation : String {
    case jedi = "JEDI"
    case resistance = "RESISTANCE"
    case firstOrder = "FIRST_ORDER"
    case sith = "SITH"
    case unknown = "UNKNOWN"
}

class Person: Object {
    static let birthdayDisplayFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    static let birthdayParseFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd"
        return dateFormatter
    }()
    
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var birthdate : Date?
    dynamic var profilePicture = ""
    dynamic var forceSensitive = false
    dynamic var affiliation = ""
    
    // MARK: - Ignored properties
    
    override static func ignoredProperties() -> [String] {
        return ["affiliationType", "name", "affiliationImage", "birthdayString", "forceSensitiveString"]
    }
    
    var affiliationType : PersonAffiliation {
        switch (self.affiliation) {
        case "JEDI", "RESISTANCE", "FIRST_ORDER", "SITH":
            return PersonAffiliation(rawValue: self.affiliation)!
        default:
            return .unknown
        }
    }
    
    var name : String {
        get {
            let returnString = "\(self.firstName) \(self.lastName)"
            return returnString.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var affiliationImage : UIImage? {
        get {
            switch (self.affiliationType) {
            case .resistance:
                return #imageLiteral(resourceName: "resistance")
            case .firstOrder:
                return #imageLiteral(resourceName: "firstorder")
            case .jedi:
                return #imageLiteral(resourceName: "jedi")
            case .sith:
                return #imageLiteral(resourceName: "sith")
            case .unknown:
                return nil
            }
        }
    }
    
    var birthdayString : String {
        get {

            if let date = self.birthdate {
                return Person.birthdayDisplayFormatter.string(from: date)
            } else {
                return NSLocalizedString("Unknown", comment: "Information unknown.")
            }
        }
    }
    
    var forceSensitiveString : String {
        get {
            let yesString = NSLocalizedString("YES", comment: "Is force sensitive.")
            let noString = NSLocalizedString("NO", comment: "Is not force sensitive.")
            
            return (forceSensitive == true) ? yesString : noString
        }
    }
    
    // MARK: - Parsing Functions
    
    class func parsePeople(realm: Realm, personArray: [Any]) {
        for person in personArray {
            var personCopy = person as? [String : Any]
            
            let dateString = personCopy?[WebPersonManager.personBirthDateKey] as? String
            personCopy?[WebPersonManager.personBirthDateKey] = self.convertDate(dateString)
            if let personCopy = personCopy {
                realm.create(Person.self, value: personCopy)
            }
        }
    }
    
    class func convertDate(_ string: String?) -> Date {
        guard let dateString = string else { return Date() }
        
        return Person.birthdayParseFormatter.date(from: dateString) ?? Date()
    }
}
