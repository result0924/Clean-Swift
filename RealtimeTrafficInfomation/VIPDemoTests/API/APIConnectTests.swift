//
//  APIConnectTests.swift
//  VIPDemoTests
//
//  Created by justin on 2019/6/18.
//  Copyright © 2019 jlai. All rights reserved.
//

import XCTest

class APIConnectTests: XCTestCase {
    let session = MockURLSession()
    lazy var httpClient: HttpClient = {
        return HttpClient(session: session)
    }()
    
    let expectedData = """
        {
            "success": {"total": 1},
            "contents": {
                "quotes": [
                {
                    "quote": "A successful man is one who can lay a firm foundation with the bricks that others throw at him.",
                    "length": "95",
                    "author": "Sidney Greenberg",
                    "tags": [
                        "inspire",
                        "success",
                        "tso-life"
                    ],
                    "category": "inspire",
                    "date": "2019-06-18",
                    "permalink": "https://theysaidso.com/quote/O8OiauUuV2FEq8DZElUNwQeF/sidney-greenberg-a-successful-man-is-one-who-can-lay-a-firm-foundation-with-the",
                    "title": "Inspiring Quote of the day",
                    "background": "https://theysaidso.com/img/bgs/man_on_the_mountain.jpg",
                    "id": "O8OiauUuV2FEq8DZElUNwQeF"
                }],
                "copyright": "2017-19 theysaidso.com"
            }
        }
        """

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchQuoteShouldReturnData() {
        let data = expectedData.data(using: .utf8)
        
        session.nextData = data
        
        guard let url = URL(string: "http://quotes.rest/qod.json") else {
            fatalError("URL can't be empty")
        }
        
        var actualData: Data?
        httpClient.get(url: url) { (data, error) in
            actualData = data
        }
        XCTAssertNotNil(actualData)
        
        if let data = actualData {
            do {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any], let contents: [String: Any] = jsonDictionary["contents"] as? [String: Any], let quotes: [[String: Any]] = contents["quotes"] as? [[String: Any]] {
                        let quote: Quote = Quote(text: quotes.first?["quote"] as? String ?? "", author: quotes.first?["author"] as? String ?? "", title: quotes.first?["title"] as? String ?? "", date: quotes.first?["date"] as? String ?? "", image: quotes.first?["background"] as? String ?? "", copyright: contents["copyright"] as? String ?? "")
                        XCTAssertEqual(quote.text, "A successful man is one who can lay a firm foundation with the bricks that others throw at him.")
                        XCTAssertEqual(quote.author, "Sidney Greenberg")
                        XCTAssertEqual(quote.date, "2019-06-18")
                        XCTAssertEqual(quote.copyright, "2017-19 theysaidso.com")
                        XCTAssertEqual(quote.title, "Inspiring Quote of the day")
                        XCTAssertEqual(quote.image, "https://theysaidso.com/img/bgs/man_on_the_mountain.jpg")
                    }
            } catch(let error) {
                print("decode josn error:\(error)")
                XCTAssert(false)
            }
        }
    }
}

// Protocol for MOCK/Real
protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

//MARK: HttpClient Implementation
class HttpClient {
    
    typealias completeClosure = (_ data: Data?, _ error: Error?) -> Void
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func get( url: URL, callback: @escaping completeClosure ) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) { (data, response, error) in
            callback(data, error)
        }
        task.resume()
    }
    
}

//MARK: Conform the protocol
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping URLSessionProtocol.DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

//MARK: MOCK
class MockURLSession: URLSessionProtocol {
    
    var nextDataTask = MockURLSessionDataTask()
    var nextData: Data?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        
        completionHandler(nextData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }
    
}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}
