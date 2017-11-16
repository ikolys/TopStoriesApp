//
//  Task1Tests.swift
//  Task1Tests
//
//  Created by user132392 on 11/8/17.
//  Copyright © 2017 user132392. All rights reserved.
//

import XCTest
@testable import Task1
import CoreData

class Task1Tests: XCTestCase {
    var managedObjectContext: NSManagedObjectContext?
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if managedObjectContext == nil {
            managedObjectContext = setUpInMemoryManagedObjectContext()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchAllArticlesFromDatabase() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let articlesUpdater = ArticlesUpdater()
        articlesUpdater.fetchArticlesFromWebAndSave(inContext: managedObjectContext!) { [unowned self] in
            let articles = articlesUpdater.fetchAllArticlesFromDatabase(inContext: self.managedObjectContext!)
            XCTAssert(articles.count > 0)
        }
        
    }
    
    func testFetchAllArticlesFromDatabaseGrouppedByDate() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let articlesUpdater = ArticlesUpdater()
        articlesUpdater.fetchArticlesFromWebAndSave(inContext: managedObjectContext!) { [unowned self] in
            let articles = articlesUpdater.fetchAllArticlesFromDatabaseGrouppedByDate(inContext: self.managedObjectContext!)
            XCTAssert(articles.count > 0)
        }
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

extension XCTestCase {
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
}
