//
//  WisdomPresenterTests.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/19.
//  Copyright (c) 2019 jlai. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import RealtimeTrafficInfomation
import XCTest

class WisdomPresenterTests: XCTestCase {
    // MARK: Subject under test
  
    var sut: WisdomPresenter!

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        setupWisdomPresenter()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Test setup

    func setupWisdomPresenter() {
        sut = WisdomPresenter()
    }

    // MARK: Test doubles

    class WisdomDisplayLogicSpy: WisdomDisplayLogic {
        var displayOldQuoteCalled = false
        var displayQuoteSuccessCalled = false
        var displayQuoteFailedCalled = false
        var quote: Quote?
        
        func displayOldQuote(viewModel: Wisdom.WisdomEvent.cachequote) {
            quote = viewModel.quote
            displayOldQuoteCalled = true
        }
        
        func displayQuoteSuccess(viewModel: Wisdom.WisdomEvent.ViewModel) {
            quote = viewModel.quote
            displayQuoteSuccessCalled = true
        }
        
        func displayQuoteFailed(viewMode: Wisdom.WisdomEvent.ViewModel) {
            quote = viewMode.quote
            displayQuoteFailedCalled = true
        }
    }

    // MARK: Tests

    func testDisplayOldQuote() {
        // Given
        let spy = WisdomDisplayLogicSpy()
        sut.viewController = spy

        // When
        sut.presentOldQuoteResult(response: Wisdom.WisdomEvent.cachequote(quote: WisdomSeeds().testQuote))

        // Then
        XCTAssertTrue(spy.displayOldQuoteCalled, "display old quote should ask the view controller to display the result")
        equalWithWisdomSeed(quote: spy.quote)
    }
    
    func testDisplayQuoteSuccess() {
        // Given
        let spy = WisdomDisplayLogicSpy()
        sut.viewController = spy
        
        // When
        sut.presentQuoteResult(response: Wisdom.WisdomEvent.Response(quote: WisdomSeeds().testQuote, success: true, errorMsg: nil))
        
        // Then
        XCTAssertTrue(spy.displayQuoteSuccessCalled, "display quote success should ask the view controller to display the result")
        equalWithWisdomSeed(quote: spy.quote)
    }
    
    func testDisplayQuoteFailed() {
        // Given
        let spy = WisdomDisplayLogicSpy()
        sut.viewController = spy
        
        // When
        sut.presentQuoteResult(response: Wisdom.WisdomEvent.Response(quote: nil, success: false, errorMsg: "can't fetche quote"))
        
        // Then
        XCTAssertTrue(spy.displayQuoteFailedCalled, "display quote success should ask the view controller to display the result")
        XCTAssertNil(spy.quote)
    }
    
    private func equalWithWisdomSeed(quote: Quote?) {
        let wisdomSeeds = WisdomSeeds().testQuote
        XCTAssertEqual(wisdomSeeds.title, quote?.title)
        XCTAssertEqual(wisdomSeeds.text, quote?.text)
        XCTAssertEqual(wisdomSeeds.date, quote?.date)
        XCTAssertEqual(wisdomSeeds.image, quote?.image)
        XCTAssertEqual(wisdomSeeds.author, quote?.author)
        XCTAssertEqual(wisdomSeeds.copyright, quote?.copyright)
    }
}
