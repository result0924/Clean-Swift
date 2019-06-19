//
//  WisdomInteractorTests.swift
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

class WisdomInteractorTests: XCTestCase {
    // MARK: Subject under test

    var sut: WisdomInteractor!

    // MARK: Test lifecycle

    override func setUp() {
        super.setUp()
        setupWisdomInteractor()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: Test setup

    func setupWisdomInteractor() {
        sut = WisdomInteractor()
    }

    // MARK: Test doubles

    class WisdomPresentationLogicSpy: WisdomPresentationLogic {
        var presentSomethingCalled = false

        func presentSomething(response: Wisdom.Something.Response) {
            presentSomethingCalled = true
        }
    }

    // MARK: Tests

    func testDoSomething() {
        // Given
        let spy = WisdomPresentationLogicSpy()
        sut.presenter = spy
        let request = Wisdom.Something.Request()

        // When
        sut.doSomething(request: request)

        // Then
        XCTAssertTrue(spy.presentSomethingCalled, "doSomething(request:) should ask the presenter to format the result")
    }
}