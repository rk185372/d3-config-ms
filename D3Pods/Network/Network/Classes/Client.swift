//
//  Client.swift
//  Network
//
//  Created by Chris Carranza on 12/21/17.
//

import Alamofire
import Foundation
import Logging
import RxSwift
import Utilities

public enum ResponseError: Error {
    case invalidData
    case failureWithMessage(String)
    case unauthenticated(String)
    case invalidMethod
    case requiresReCaptcha(String)
    case systemMaintenance
}

extension ResponseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidData:
            return "[ResponseError] Invalid data"
        case let .failureWithMessage(message):
            return "[ResponseError] Failure occured with message: \(message)"
        case let .unauthenticated(message):
            return "[ResponseError] Unauthenticated with message: \(message)"
        case .invalidMethod:
            return "[ResponseError] Invalid method for request"
        case let .requiresReCaptcha(message):
            return "[ResponseError] Requires ReCaptcha, error message: \(message)"
        case .systemMaintenance:
            return "[ResponseError] System Maintenance"
        }
    }
}

public typealias Result = Alamofire.Result
public typealias RequestCompletion<Response> = (Result<Response>) -> Void

public protocol ClientProtocol {
    var cookies: [HTTPCookie] { get }
    var domain: URL { get }

    func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response>
    func request<Response>(_ endpoint: Endpoint<Response>, acceptableStatusCodes: [Int]) -> Single<Response>
}

public final class Client {
    private let manager: Alamofire.SessionManager
    private let queue = DispatchQueue(label: "com.d3banking.mobileapp.network-decode-queue", qos: .utility)
    private let requestTransformer: RequestTransformer?

    public let domain: URL

    fileprivate var standardStatusCodes = Array(200..<300)

    public init(domain: URL,
                requestAdapter: RequestAdapter? = nil,
                trustPolicyManager: ServerTrustPolicyManager? = nil,
                requestTransformer: RequestTransformer? = nil) {
        self.domain = domain

        let configuration = URLSessionConfiguration.default
        
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        self.manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: trustPolicyManager)
        self.manager.adapter = requestAdapter
        // We do not want the tasks to start immediately because of the way the request transformer
        // may need to copy the url request and modify it with additional headers. This copying process
        // will send a request for both the original request and the copied request if startRequestsImmediately
        // is true.
        self.manager.startRequestsImmediately = false

        self.requestTransformer = requestTransformer
    }
    
    func dataRequestObject<Response>(for endpoint: Endpoint<Response>) throws -> Single<DataRequest> {
        // Before we can adequately set up the DataRequest here, there are additional headers
        // that may or may not be added by the RequestTransformer. Unfortunately, once a
        // DataRequest object is made, it's URLRequest is immutable and cannot have any additional
        // headers set. To fix this problem, we create a DataRequest whose URLRequest is provided
        // to the RequestTransformer. The RequestTransformer then returns additional headers needed
        // for the URLRequest. Once we have obtained these additional headers, we make a copy of
        // the DataRequest's URLRequest, set the additional headers on the copy, then create a new
        // DataRequest using the copy of the original URLRequest. It is this DataRequest that is actually
        // returned.
        let intermediateRequest: DataRequest

        switch endpoint.parameters() {
        case .dictionary(let dict):
            intermediateRequest = manager.request(
                url(path: endpoint.path),
                method: endpoint.method,
                parameters: dict,
                encoding: (endpoint.method == .post || endpoint.method == .put)
                    ? JSONEncoding.default
                    : URLEncoding.default,
                headers: endpoint.headers
            )
        case .data(let data):
            guard let data = data else {
                intermediateRequest = manager.request(
                    url(path: endpoint.path),
                    method: endpoint.method,
                    parameters: nil,
                    encoding: (endpoint.method == .post || endpoint.method == .put)
                        ? JSONEncoding.default
                        : URLEncoding.default,
                    headers: endpoint.headers
                )

                break
            }
            
            guard endpoint.method != .get else {
                log.debug("Attempt to send a get request with an httpBody")
                throw ResponseError.invalidMethod
            }
            
            // This is mimicking the same behavior that Alamofire is using to JSONEncode
            var urlRequest = try URLRequest(url: url(path: endpoint.path), method: endpoint.method, headers: endpoint.headers)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
            intermediateRequest = manager.request(urlRequest)
        }

        // If we are here and the DataRequest's URLRequest is nil
        // we assume that there is nothing to do and we return the DataRequest Object
        // Otherwise we make a copy of the DataRequest's URLRequest so that it can be
        // mutated.
        guard let urlRequest = intermediateRequest.request else {
            intermediateRequest.resume()

            return Single.just(intermediateRequest)
        }

        // If there is a requestTransformer, we are mapping the Single<URLRequest> returned
        // by the call to the requestTransformer's transform method to a DataRequest
        if let transformer = requestTransformer {
            return transformer
                .transform(urlRequest)
                .map({ [unowned self] urlRequest in
                    let requestToSend = self.manager.request(urlRequest)
                    requestToSend.resume()

                    return requestToSend
                })
        }

        let requestToSend = manager.request(urlRequest)
        requestToSend.resume()

        return Single.just(requestToSend)
    }
    
    func sendDataRequest(request: DataRequest,
                         queue: DispatchQueue? = nil,
                         acceptableStatusCodes: [Int],
                         completionHandler: @escaping (DataResponse<Data>) -> Void) {
        
        //Array(200..<300)
        let acceptableContentType: [String]
        
        if let accept = request.request?.value(forHTTPHeaderField: "Accept") {
            acceptableContentType = accept.components(separatedBy: ",")
        } else {
            acceptableContentType = ["*/*"]
        }

        request
            .validate(statusCode: acceptableStatusCodes)
            .validate(contentType: acceptableContentType)
            .responseData(queue: queue) { dataResponse in
                self.requestTransformer?.process(dataResponse.response)
                let dataResponseHandlers = [
                    self.handleUnauthentication,
                    self.handleFailureWithMessage
                ]
                let processedResponse = dataResponseHandlers.reduce(dataResponse, { response, closure in closure(response) })
                completionHandler(processedResponse)
        }
    }
    
    func url(path: Path) -> URL {
        return domain.appendingPathComponent(path)
    }
}

extension Client: ClientProtocol {
    
    public func request<Response>(_ endpoint: Endpoint<Response>) -> Single<Response> {
        return request(endpoint, acceptableStatusCodes: standardStatusCodes)
    }
    
    public func request<Response>(_ endpoint: Endpoint<Response>, acceptableStatusCodes: [Int]) -> Single<Response> {
        do {
            return try self.dataRequestObject(for: endpoint)
                .flatMap({ [unowned self] (request) -> Single<Response> in
                    return Single<Response>.create { observer in
                        self.sendDataRequest(
                            request: request,
                            queue: self.queue,
                            acceptableStatusCodes: acceptableStatusCodes
                        ) { response in
                            if case .failure(let error) = response.result {
                                log.error("Failed request:\n\(request)", context: error)
                            }

                            let result = response.result.flatMap(endpoint.decode)

                            switch result {
                            case let .success(value):
                                observer(.success(value))
                            case let .failure(error):
                                observer(.error(error))
                            }
                        }

                        return Disposables.create {
                            request.cancel()
                        }
                    }
                })
                .observeOn(MainScheduler.instance)
        } catch {
            return Single<Response>.create { observer in
                observer(.error(error))

                return Disposables.create {}
            }
        }
    }

    public var cookies: [HTTPCookie] {
        return manager.session.configuration.httpCookieStorage?.cookies ?? []
    }
}

extension Client {
    private func handleUnauthentication(dataResponse: DataResponse<Data>) -> DataResponse<Data> {
        guard
            let response = dataResponse.response,
            let data = dataResponse.data,
            dataResponse.error != nil else {
                return dataResponse
        }
        
        guard response.statusCode == 401 else {
            return dataResponse
        }

        guard let errorMessageResponse = try? JSONDecoder().decode(ErrorMessageResponse.self, from: data) else {
            return dataResponse
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .unauthenticated, object: self, userInfo: ["message": errorMessageResponse.message])
        }

        let result = Result<Data> { throw ResponseError.unauthenticated(errorMessageResponse.message) }
        
        return DataResponse(
            request: dataResponse.request,
            response: dataResponse.response,
            data: dataResponse.data,
            result: result,
            timeline: dataResponse.timeline
        )
    }
    
    private func handleFailureWithMessage(dataResponse: DataResponse<Data>) -> DataResponse<Data> {
        guard
            let data = dataResponse.data,
            let response = dataResponse.response, dataResponse.error != nil else {
                return dataResponse
        }
        
        guard response.statusCode != 401 else {
            return dataResponse
        }
        
        guard let errorMessageResponse = try? JSONDecoder().decode(ErrorMessageResponse.self, from: data) else {
            return dataResponse
        }
        
        // A 503 with message "banking.system.maintenance" indicates a planned maintenance outage.
        var systemMaintenance = false
        if response.statusCode == 503 && errorMessageResponse.code == "banking.system.maintenance" {
            systemMaintenance = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .maintenance,
                    object: self,
                    userInfo: ["message": errorMessageResponse.message]
                )
            }
        }

        let result = Result<Data> {
            // A 412 Status code means that ReCaptcha is required so we throw the error and pass along
            // the message.
            if response.statusCode == 412 {
                throw ResponseError.requiresReCaptcha(errorMessageResponse.message)
            } else if systemMaintenance {
                throw ResponseError.systemMaintenance
            }

            throw ResponseError.failureWithMessage(errorMessageResponse.message)
        }
        
        return DataResponse(
            request: dataResponse.request,
            response: dataResponse.response,
            data: dataResponse.data,
            result: result,
            timeline: dataResponse.timeline
        )
    }
}
