//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Артем Кохан on 04.11.2022.
//

import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
        
    }
    func substraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            handler(num1 - num2)
        }
    }
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            handler(num1 * num2)
        }
        
    }
}

final class MovieQuizTests: XCTestCase {
    
    func testAddition() throws {
        //         Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1, num2 = 2
        
        //        when
        let expectation = expectation(description: "Addition function expectation")
        
        arithmeticOperations.addition(num1: num1, num2: num2) { result in
            //        then
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
        
    }
    
}
