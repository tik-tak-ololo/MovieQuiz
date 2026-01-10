//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Сергей Хмелёв on 06.01.2026.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        app = XCUIApplication()
        app.launch()
        
        let questionLabel = app.staticTexts["Question Label"]
        let existsPredicate = NSPredicate(format: "label != ''")
        
        // Создаем ожидание на основе состояния элемента
        let expectation = XCTNSPredicateExpectation(predicate: existsPredicate, object: questionLabel)
        
        // Ждем выполнения условия 10 сек.
        let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
        
        if result == .timedOut {
            XCTFail("Приложение слишком долго загружалось!")
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        // находим кнопку `Да` и нажимаем её
        let yesButton = app.buttons["Yes"]
        yesButton.tap()
        
        // Создаем предикат: ждем, когда кнопка снова станет активной (isEnabled == true)
        let predicate = NSPredicate(format: "isEnabled == true")
        
        // Создаем ожидание на основе состояния элемента
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: yesButton)
        
        // Ждем выполнения условия 10 сек.
        let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
        
        if result == .timedOut {
            XCTFail("После нажатия кнопка \"Да\" не была разблокирована!")
        }
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
        
    }
    
    func testNoButton() {
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        // находим кнопку `Нет` и нажимаем её
        let noButton = app.buttons["No"]
        noButton.tap()
        
        // Создаем предикат: ждем, когда кнопка снова станет активной (isEnabled == true)
        let predicate = NSPredicate(format: "isEnabled == true")
        
        // Создаем ожидание на основе состояния элемента
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: noButton)
        
        // Ждем выполнения условия 10 сек.
        let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
        
        if result == .timedOut {
            XCTFail("После нажатия кнопка \"Нет\" не была разблокирована!")
        }
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        
        for _ in 1...10 {
            // находим кнопку `Нет` и нажимаем её
            let noButton = app.buttons["No"]
            noButton.tap()
            
            // Создаем предикат: ждем, когда кнопка снова станет активной (isEnabled == true)
            let predicate = NSPredicate(format: "isEnabled == true")
            
            // Создаем ожидание на основе состояния элемента
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: noButton)
            
            // Ждем выполнения условия 10 сек.
            let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
            
            if result == .timedOut {
                XCTFail("После нажатия кнопка \"Нет\" не была разблокирована!")
            }
        }
        
        let alert = app.alerts["Game results"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        for _ in 1...10 {
            // находим кнопку `Нет` и нажимаем её
            let noButton = app.buttons["No"]
            noButton.tap()
            
            // Создаем предикат: ждем, когда кнопка снова станет активной (isEnabled == true)
            let predicate = NSPredicate(format: "isEnabled == true")
            
            // Создаем ожидание на основе состояния элемента
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: noButton)
            
            // Ждем выполнения условия 10 сек.
            let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
            
            if result == .timedOut {
                XCTFail("После нажатия кнопка \"Нет\" не была разблокирована!")
            }
        }
        
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        
        let indexLabel = app.staticTexts["Index"]
        
        let predicate = NSPredicate(format: "label == '1/10'")
        // Создаем ожидание на основе состояния элемента
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: indexLabel)
        
        // Ждем выполнения условия 10 сек.
        let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
        
        if result == .timedOut {
            XCTFail("Перезапуск игры не удался!")
        }
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
}
