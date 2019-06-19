//
//  WisdomCoreDataStore.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/17.
//  Copyright © 2019 jlai. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class WisdomCoreDataStore {
    
    let persistentContainer: NSPersistentContainer!
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer?.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cna't get shared app delegate")
        }
        
        self.init(container: appDelegate.persistentContainer)
    }
    
    // MARK: Wisdom
    @discardableResult
    func saveQuoteToCoreData(quote: Quote) -> Quotes? {
        let predicate = NSPredicate(format: "text = %@", String(quote.text))
        let existsQuoteModel = getQuoteByPredicate(predicate)
        let context = backgroundContext
        
        if existsQuoteModel == nil, let entity = NSEntityDescription.entity(forEntityName: "Quotes", in: context) {
            let newQuote = Quotes(entity: entity, insertInto: context)
            newQuote.title = quote.title
            newQuote.text = quote.text
            newQuote.author = quote.author
            newQuote.date = quote.date
            newQuote.copyright = quote.copyright
            newQuote.image = quote.image
        
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not create quote to core data \(error), \(error.userInfo)")
            }
            
            return newQuote
        } else {
            let request = NSFetchRequest<Quotes>(entityName: "Quotes")
            request.predicate = predicate
            
            do {
                let results = try context.fetch(request)
                
                if !results.isEmpty, let oldQuote = results.first {
                    oldQuote.title = quote.title
                    oldQuote.text = quote.text
                    oldQuote.author = quote.author
                    oldQuote.date = quote.date
                    oldQuote.copyright = quote.copyright
                    oldQuote.image = quote.image
                    
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print("Could not save quote to core data \(error), \(error.userInfo)")
                    }
                    
                    return oldQuote
                } else {
                    return nil
                }
            } catch {
                print("Unexpected error: \(error).")
                return nil
            }
        }
    }
    
    func fetchQuoteFromDatabase() -> [Quote] {
        let context = backgroundContext
        let request = NSFetchRequest<Quotes>(entityName: "Quotes")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            
            let quotes: [Quote] = results.compactMap { return convertQuoteResultToModel($0) }
            return quotes
        } catch let error as NSError {
            print("Could not get quote \(error), \(error.userInfo)")
            return []
        }
    }
    
    private func getQuoteByPredicate(_ predicate: NSPredicate) -> Quote? {
        let context = backgroundContext
        let request = NSFetchRequest<Quotes>(entityName: "Quotes")
        
        request.predicate = predicate
        do {
            let results = try context.fetch(request)
            
            if let quote = results.first {
                return convertQuoteResultToModel(quote)
            } else {
                return nil
            }
        } catch {
            print("Unexpected error: \(error).")
            return nil
        }
    }
    
    private func convertQuoteResultToModel(_ result: Quotes) -> Quote? {
        
        let obj: [String: Any?] = [
            "text": result.text,
            "title": result.title,
            "author": result.author,
            "date": result.date,
            "copyright": result.copyright,
            "image": result.image
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted) {
            let decoder = JSONDecoder()
            
            do {
                let quote = try decoder.decode(Quote.self, from: jsonData)
                return quote
            } catch(let error) {
                print("decode json data error when cover quote to model: \(error)")
                return nil
            }
            
        } else {
            print("cover obj to data fail: \(obj)")
            return nil
        }
    }
}
