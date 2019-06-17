//
//  APIConnect.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/17.
//  Copyright © 2019 jlai. All rights reserved.
//

import Foundation
import Alamofire

let quoteUrl = "http://quotes.rest/qod.json"

class APIConnect {
    
    func fetchQuote(complete: @escaping responseHandler) {
        Alamofire.request(quoteUrl).validate().responseJSON { (response) in
            if response.result.isSuccess {
                
                if let JSON = response.result.value, let jsonDictionary = JSON as? NSDictionary, let contents: [String: Any] = jsonDictionary["contents"] as? [String: Any], let quotes: [[String: Any]] = contents["quotes"] as? [[String: Any]] {
                    let quote: Quote = Quote(text: quotes.first?["quote"] as? String ?? "", author: quotes.first?["author"] as? String ?? "", title: quotes.first?["title"] as? String ?? "", date: quotes.first?["date"] as? String ?? "", image: quotes.first?["background"] as? String ?? "", copyright: contents["copyright"] as? String ?? "")
                    
                    let wisdomResponse: Wisdom.WisdomEvent.Response = Wisdom.WisdomEvent.Response(quote: quote, success: true, errorMsg: nil)
                    complete(wisdomResponse)
                } else {
                    let wisdomResponse: Wisdom.WisdomEvent.Response = Wisdom.WisdomEvent.Response(quote: nil, success:false, errorMsg: "can't decode quote json")
                    complete(wisdomResponse)
                }
                
            } else {
                let wisdomResponse: Wisdom.WisdomEvent.Response = Wisdom.WisdomEvent.Response(quote: nil, success:false, errorMsg: response.result.error.debugDescription)
                complete(wisdomResponse)
            }
        }
    }
}
