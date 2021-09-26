//
//  URLSessionNetWorkServiceTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
import RxSwift
import RxBlocking
@testable import Weather
class URLSessionNetWorkServiceTests: XCTestCase {
    var disposeBag: DisposeBag!
    var urlsessionNetwork: URLSessionNetworkService!
    var mockEnvironment: EnvironmentMock!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        mockEnvironment = EnvironmentMock()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        urlsessionNetwork = URLSessionNetworkService(session: urlSession,
                                                     enviroment: mockEnvironment)
    }
    
    func testShouldMakeCorrectUrlRequest() {
        
        //Given Mock URLSession respnse
        let expectation = expectation(description: "testShouldMakeCorrectUrlRequest")
        var hookedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            hookedRequest = request
            expectation.fulfill()
            return (HTTPURLResponse(url: request.url!,
                                    statusCode: 200,
                                    httpVersion: nil,
                                    headerFields: nil)!, nil)
        }
        let request = WeatherRequest(searchTerm: "searchTerm", units: "units", cnt: 2.5)
        
        //When trigger request
        urlsessionNetwork.request(request, type: WeatherResponseModel.self)
            .subscribe()
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
        
        //Then Expect UrlRequest should be corect with Request Parameter
        XCTAssertEqual(hookedRequest?.url?.path,"baseURLdata/2.5/forecast/daily")
        XCTAssertTrue(hookedRequest?.url?.query?.contains("q=searchTerm") ?? false)
        XCTAssertTrue(hookedRequest?.url?.query?.contains("units=units") ?? false)
        XCTAssertTrue(hookedRequest?.url?.query?.contains("appid=apiKey") ?? false)
    }

    func testURlSessionNetworkSuccess() {
        //Given URLSession mock with success
        MockURLProtocol.requestHandler = MockURLProtocol.mockSuccess
        let request = WeatherRequest(searchTerm: "searchTerm", units: "units", cnt: 2.5)
        
        //When trigger request
        let result = urlsessionNetwork.request(request, type: WeatherResponseModel.self)
        
        //Then network should reponse correct object
        XCTAssertEqual(try? result.toBlocking().first(), .success(WeatherResponseModel.stub()))
    }
    
    func testURlSessionNetworkFailedWhichError() {
        //Given Status code and correctsponse error
        [(200,APIError.invalidResponse),
         (400,APIError.badRequest),
         (500,APIError.serverError),
         (600,APIError.unknown)
        ].forEach { code, error in
            //Mock URLSession with folowing Status and Error
            MockURLProtocol.requestHandler = MockURLProtocol.mockFailure(code: code)
            
            //When triger request
            let request = WeatherRequest(searchTerm: "searchTerm", units: "units", cnt: 2.5)
            let result = urlsessionNetwork.request(request, type: WeatherResponseModel.self)
            
            //Then result should be Error
            XCTAssertEqual(try? result.toBlocking().first(), .failure(error))
        }
    }
}
