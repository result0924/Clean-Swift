//
//  WisdomCoreDataStoreTests.swift
//  VIPDemoTests
//
//  Created by justin on 2019/6/19.
//  Copyright © 2019 jlai. All rights reserved.
//

import XCTest
import CoreData

@testable import RealtimeTrafficInfomation

class WisdomCoreDataStoreTests: XCTestCase {
    lazy var sut: WisdomCoreDataStore = {
        return WisdomCoreDataStore(container: mockPersistantContainer)
    }()
    
    //MARK: mock in-memory persistant store
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    let mockQuote = Quote(text: "quote", author: "author", title: "title", date: "date", image: "imagePath", copyright: "copy right")
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RealtimeTrafficInfomation", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        initStubs()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        flushData()
        
        super.tearDown()
    }
    
    func testCreateQuote() {
        let quoteFromCoreData = sut.saveQuoteToCoreData(quote: mockQuote)
        XCTAssertEqual(quoteFromCoreData?.title, mockQuote.title)
        XCTAssertEqual(quoteFromCoreData?.text, mockQuote.text)
        XCTAssertEqual(quoteFromCoreData?.author, mockQuote.author)
        XCTAssertEqual(quoteFromCoreData?.image, mockQuote.image)
        XCTAssertEqual(quoteFromCoreData?.copyright, mockQuote.copyright)
        XCTAssertEqual(quoteFromCoreData?.date, mockQuote.date)
    }

    func testFetchQuote() {
        let allQuoteFromCoreData = sut.fetchQuoteFromDatabase()
        XCTAssertEqual(allQuoteFromCoreData.count, 2)
    }
}

// MARK: Create fakes

extension WisdomCoreDataStoreTests {
    
    func initStubs() {
        let quote1 = Quote(text: "abc", author: "author", title: "title", date: "date", image: "imagePath", copyright: "copy right")
        let quote2 = Quote(text: "abc", author: "authord", title: "title", date: "date", image: "imagePath", copyright: "copy right")
        let quote3 = Quote(text: "ddd", author: "author", title: "title", date: "date", image: "imagePath", copyright: "copy right")
        sut.saveQuoteToCoreData(quote: quote1)
        sut.saveQuoteToCoreData(quote: quote2)
        sut.saveQuoteToCoreData(quote: quote3)
    }
    
    func flushData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Quotes")
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistantContainer.viewContext.delete(obj)
        }
        
        try! mockPersistantContainer.viewContext.save()
    }
}
