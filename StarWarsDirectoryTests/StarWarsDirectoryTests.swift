//
//  StarWarsDirectoryTests.swift
//  StarWarsDirectoryTests
//
//  Created by Toby Youngberg on 3/8/17.
//  Copyright © 2017 Toby Youngberg. All rights reserved.
//

import XCTest
import RealmSwift

@testable import StarWarsDirectory

class StarWarsDirectoryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPersonForceSensitive() {
        let person = Person()
        person.forceSensitive = true
        XCTAssert(person.forceSensitiveString == "YES", "Expected YES, but got: \(person.forceSensitiveString)")
        person.forceSensitive = false
        XCTAssert(person.forceSensitiveString == "NO", "Expected NO, but got: \(person.forceSensitiveString)")
    }
    
    func testPersonBirthday() {
        let person = Person()
        
        XCTAssert(person.birthdayString == "Unknown", "Expected Unknown, but got: \(person.birthdayString)")
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.month = 12
        dateComponents.day = 5
        dateComponents.year = 2015
        
        person.birthdate = Calendar.current.date(from: dateComponents)
        
        XCTAssert(person.birthdayString == "Dec 5, 2015", "Expected Dec 5, 2015, but got: \(person.birthdayString)")
    }
    
    func testPersonAffiliation() {
        let person = Person()
        
        person.affiliation = "RESISTANCE"
        
        XCTAssert(person.affiliationImage == #imageLiteral(resourceName: "resistance"))
        XCTAssert(person.affiliationType == .resistance)
        
        person.affiliation = "FIRST_ORDER"
        
        XCTAssert(person.affiliationImage == #imageLiteral(resourceName: "firstorder"))
        XCTAssert(person.affiliationType == .firstOrder)
        
        person.affiliation = "JEDI"
        
        XCTAssert(person.affiliationImage == #imageLiteral(resourceName: "jedi"))
        XCTAssert(person.affiliationType == .jedi)
        
        person.affiliation = "SITH"
        
        XCTAssert(person.affiliationImage == #imageLiteral(resourceName: "sith"))
        XCTAssert(person.affiliationType == .sith)
        
        person.affiliation = ""
        
        XCTAssert(person.affiliationImage == nil)
        XCTAssert(person.affiliationType == .unknown)
        
        
        person.affiliation = "GEORGE"
        
        XCTAssert(person.affiliationImage == nil)
        XCTAssert(person.affiliationType == .unknown)
    }
    
    func testPersonName() {
        let person = Person()
        
        XCTAssert(person.name == "", "Expected '', but got: \(person.name)")
        
        person.firstName = "John"
        
        XCTAssert(person.name == "John", "Expected 'John', but got: \(person.name)")
        
        person.lastName = "Doe"
        
        XCTAssert(person.name == "John Doe", "Expected 'John Doe', but got: \(person.name)")
    }
    
    func testPersonParse() {
        
        let path = Bundle(for: StarWarsDirectoryTests.self).path(forResource: "directory", ofType: "json", inDirectory: "")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        
        guard let personData = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []),
            JSONSerialization.isValidJSONObject(personData),
            let personDict = personData as? [String : Any],
            let personArray = personDict[personIndividuals] as? [Any] else {
                XCTAssert(false, "Failed to parse xml document")
                return
        }
        
        if let realm = try? Realm() {
            realm.beginWrite()
            realm.deleteAll()
            Person.parsePeople(realm: realm, personArray: personArray)
            try? realm.commitWrite()
            
            let results = try? Realm().objects(Person.self).sorted(byKeyPath: "birthdate")
            
            XCTAssert(results?.count == 8)
            XCTAssert(results?.first?.name == "Chewbacca")
            XCTAssert(results?.last?.name == "General Hux")
            XCTAssert(results?[6].name == "Kylo Ren")
            NSLog("\(results?[6])")
            XCTAssert(results?[6].affiliationType == .unknown)
            
            
            realm.beginWrite()
            realm.deleteAll()
            try? realm.commitWrite()
        }
    }
}
