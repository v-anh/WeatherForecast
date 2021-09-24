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
    let cache: Cacheable

    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral),
         enviroment: EnvironmentProtocol = APIEnvironment.development,
         cache: Cacheable = URLResponseCache.default) {
        self.session = session
        self.environment = enviroment
        self.cache = cache
    }
    
}

extension URLSessionNetworkService {
    func request<T:Decodable>(_ request: RequestType, type: T.Type) -> Observable<APIResponse<T>> {
        guard let request = request.urlRequest(with: self.environment) else {
            return .just(.failure(APIError.badRequest))
        }
        if let url = request.url,
           let cacheData = cache.object(ofType: type.self, forKey: url) {
            return .just(.success(cacheData))
        }
        return session.rx.response(request: request)
            .map { [weak self] response,data  -> APIResponse<T> in
                guard let self = self else {return .failure(.unknown)}
                let result = self.verify(data: data, urlResponse: response)
                switch result {
                case .success(let data):
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        if let url = request.url {
                            self.cache.setObject(decodedData, forKey: url)
                        }
                        return .success(decodedData)
                    } catch {
                        return .failure(APIError.invalidResponse)
                    }
                case .failure(let error):
                    return .failure(error)

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
