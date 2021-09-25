//
//  URLSessionNetworkService.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift
import RxCocoa

final class URLSessionNetworkService: NetworkServiceType {
    
    var environment: EnvironmentProtocol
    
    private let session: URLSession
    
    public convenience init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        
        let environment = APIEnvironment.development
        self.init(session: URLSession(configuration: config),
                  enviroment: environment)
    }

    init(session: URLSession,
         enviroment: EnvironmentProtocol) {
        self.session = session
        self.environment = enviroment
    }
    
}

extension URLSessionNetworkService {
    func request<T:Decodable>(_ request: RequestType, type: T.Type) -> Observable<APIResponse<T>> {
        guard let request = request.urlRequest(with: self.environment) else {
            return .just(.failure(APIError.badRequest))
        }
        return Observable<APIResponse<T>>.create { [weak self] observer in
            return URLSession.shared.rx.response(request: request).subscribe { [weak self] response, data in
                guard let self = self else {return observer.onNext(.failure(.badRequest))}
                let result = self.verify(data: data, urlResponse: response)
                switch result {
                case .success(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        return observer.onNext(.success(decodedData))
                    } catch {
                        return observer.onNext(.failure(APIError.invalidResponse))
                    }
                case .failure(let error):
                    return observer.onNext(.failure(error))
                    
                }
            }
        }
            
    }
    
    private func verify(data: Data?, urlResponse: HTTPURLResponse) -> Result<Data, APIError> {
        switch urlResponse.statusCode {
        case 200...299:
            if let data = data {
                return .success(data)
            } else {
                return .failure(APIError.noData)
            }
        case 400...499:
            return .failure(APIError.badRequest)
        case 500...599:
            return .failure(APIError.serverError)
        default:
            return .failure(APIError.unknown)
        }
    }
    
}
