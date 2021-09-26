//
//  WeatherServiceTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
import RxTest
import RxSwift
@testable import Weather

class WeatherServiceTests: XCTestCase {

    var mockNetworkService: NetworkServiceMock!
    var mockEnvironment: EnvironmentMock!
    var weatherService: WeatherService!
    var disposeBag: DisposeBag!
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        mockEnvironment = EnvironmentMock()
        mockNetworkService = NetworkServiceMock(mockEnvironment)
        weatherService = WeatherService(mockNetworkService)
    }
    
    override func tearDown() {
        mockEnvironment = nil
        mockNetworkService = nil
        disposeBag = nil
    }
    
    func testWeatherServiceShouldMakeSearchRequestBaseOnParameter() {
        //Given request parameter
        let parameter = WeatherSearchParameter(searchTerm: "searchTerm",
                                               unit: "unit",
                                               cnt: 2.0)
        
        //When make request with parameter
        weatherService.getWeather(parameter).subscribe()
            .disposed(by: disposeBag)
        
        //Then WeatherService should make request base on Parameter
        XCTAssertEqual(mockNetworkService.requestHooked?.parameters["q"]?.description, "searchTerm")
        XCTAssertEqual(mockNetworkService.requestHooked?.parameters["units"]?.description, "unit")
        XCTAssertEqual(mockNetworkService.requestHooked?.path, "data/2.0/forecast/daily")
        XCTAssertEqual(mockNetworkService.requestHooked?.method, .get)
        XCTAssertTrue(mockNetworkService.requestHooked?.headers.isEmpty ?? false)
        XCTAssertTrue(mockNetworkService.typeHooked is WeatherResponseModel.Type)
    }

}
class NetworkServiceMock: NetworkServiceType{
    var environment: EnvironmentProtocol
    init(_ environment: EnvironmentProtocol) {
        self.environment = environment
    }
    
    var requestHooked: RequestType?
    var typeHooked:Decodable.Type?
    func request<T:Decodable>(_ request: RequestType, type: T.Type) -> Observable<APIResponse<T>>  {
        self.requestHooked = request
        self.typeHooked = type
        return .empty()
    }
}
