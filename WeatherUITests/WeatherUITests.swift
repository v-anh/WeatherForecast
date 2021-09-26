//
//  WeatherUITests.swift
//  WeatherUITests
//
//  Created by Anh Tran on 23/09/2021.
//

import XCTest

class WeatherUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["testing"]
        app.launch()
    }
    
    func testSearchWeatherScreenAllComponentShouldExist() {
        
        //Given weatherForecastNavigationBar,searchTextField, tableView, cancelButton
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let navStaticTexts = weatherForecastNavigationBar.staticTexts["Weather Forecast"]
        let searchTextField = weatherForecastNavigationBar/*@START_MENU_TOKEN@*/.searchFields["searchTextField"]/*[[".searchFields[\"Search\"]",".searchFields[\"searchTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let tableView = app/*@START_MENU_TOKEN@*/.tables["weatherTableView"]/*[[".tables[\"How is the weather?\"]",".tables[\"weatherTableView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let staticTexts = tableView.staticTexts["How is the weather?"]
        
        //Then those component should be exist
        XCTAssertTrue(weatherForecastNavigationBar.exists)
        XCTAssertTrue(tableView.exists)
        XCTAssertTrue(staticTexts.exists)
        XCTAssertTrue(navStaticTexts.exists)
        XCTAssertTrue(searchTextField.exists)
    }
    
    func testSearchInTextFiledShouldRenderResultInTableView() {
        
        //Given search screen, tableview and cell
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let searchTextField = weatherForecastNavigationBar/*@START_MENU_TOKEN@*/.searchFields["searchTextField"]/*[[".searchFields[\"Search\"]",".searchFields[\"searchTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let tableView = app/*@START_MENU_TOKEN@*/.tables["weatherTableView"]/*[[".tables[\"How is the weather?\"]",".tables[\"weatherTableView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let cell = tableView.cells["WeatherTableViewCell"]
        
        //When type text in search textfield
        searchTextField.tap()
        searchTextField.typeText("saigon")
        
        //Then Tableview shoulf render WeatherTableViewCell
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testSearchHaveError() {
        //Given search screen
        let weatherForecastNavigationBar = app.navigationBars["Weather Forecast"]
        let searchTextField = weatherForecastNavigationBar/*@START_MENU_TOKEN@*/.searchFields["searchTextField"]/*[[".searchFields[\"Search\"]",".searchFields[\"searchTextField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        //When type invalid location in search textfield
        searchTextField.tap()
        searchTextField.typeText("saigon123")
        
        //Then alertController should be shown
        let alertController = app.alerts["alertController"]
        XCTAssertTrue(alertController.waitForExistence(timeout: 10))
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
