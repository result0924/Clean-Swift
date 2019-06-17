//
//  WisdomInteractor.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/6.
//  Copyright (c) 2019 jlai. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol WisdomBusinessLogic {
    func show()
    func showOldQuote()
    func fetchQuoteDataStore()
}

protocol WisdomDataStore {
    var quote: Quote? { get set }
}

class WisdomInteractor: WisdomDataStore {
    var presenter: WisdomPresentationLogic?
    var networkWorker = WisdomNetWorker()
    var databaseWorker = WisdomDatabaseWorker()
    var quote: Quote?
}

// ViewController's output

extension WisdomInteractor: WisdomBusinessLogic {
    func show() {
        networkWorker.fetchQuote(complete: { (response) in
            if response.success {
                self.databaseWorker.saveQuote(response)
            }
            self.presenter?.presentQuoteResult(response: response)
        })
    }
    
    func showOldQuote() {
        quote = databaseWorker.fetchQuote().first
        self.presenter?.presentOldQuoteResult(response: Wisdom.WisdomEvent.cachequote(quote: quote))
    }
    
    func fetchQuoteDataStore() {
        quote = databaseWorker.fetchQuote().first
    }
}
