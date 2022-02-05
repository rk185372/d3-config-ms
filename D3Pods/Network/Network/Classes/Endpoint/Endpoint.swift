//
//  Endpoint.swift
//  Network
//
//  Created by Chris Carranza on 12/21/17.
//

import Foundation
import Alamofire

public typealias Parameters = Alamofire.Parameters

public typealias Path = String

public typealias Method = Alamofire.HTTPMethod

public typealias Headers = Alamofire.HTTPHeaders

public final class Endpoint<Response> {
    public enum ParameterType {
        case dictionary([String: Any]?)
        case data(Data?)
    }
    
    let method: Method
    let path: Path
    let headers: Headers?
    let parameters: (() -> ParameterType)
    let decode: (Data) throws -> Response
    
    public init(method: Method = .get,
                path: Path,
                headers: Headers? = nil,
                parameters: (() -> ParameterType)? = nil,
                decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.headers = headers
        self.parameters = parameters ?? { .dictionary(nil) }
        self.decode = decode
    }
    
    public init(method: Method = .get,
                path: Path,
                headers: Headers? = nil,
                parameters: Parameters?,
                decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.headers = headers
        self.parameters = { .dictionary(parameters) }
        self.decode = decode
    }
    
    public init(method: Method = .get,
                path: Path,
                headers: Headers? = nil,
                parameters: Data?,
                decode: @escaping (Data) throws -> Response) {
        self.method = method
        self.path = path
        self.headers = headers
        self.parameters = { .data(parameters) }
        self.decode = decode
    }
    
    public init(_ configuration: Configuration, decode: @escaping (Data) throws -> Response) {
        self.method = configuration.method
        self.path = configuration.path
        self.headers = configuration.headers
        self.parameters = configuration.parameters
        self.decode = decode
    }
}

extension Endpoint {
    public struct Configuration {
        let method: Method
        let path: Path
        let headers: Headers?
        let parameters: (() -> ParameterType)
        
        public init(method: Method = .get, path: Path, headers: Headers? = nil, parameters: (() -> ParameterType)? = nil) {
            self.method = method
            self.path = path
            self.headers = headers
            self.parameters = parameters ?? { .dictionary(nil) }
        }
        
        public init(method: Method = .get, path: Path, headers: Headers? = nil, parameters: Parameters?) {
            self.method = method
            self.path = path
            self.headers = headers
            self.parameters = { .dictionary(parameters) }
        }
        
        public init(method: Method = .get, path: Path, headers: Headers? = nil, parameters: Data?) {
            self.method = method
            self.path = path
            self.headers = headers
            self.parameters = { .data(parameters) }
        }
    }
}

extension Endpoint where Response == [String: Any] {
    public convenience init(method: Method = .get, path: Path, parameters: (() -> ParameterType)? = nil) {
        self.init(method: method, path: path, parameters: parameters) { data in
            guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ResponseError.invalidData
            }
            
            return dictionary
        }
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Parameters?) {
        self.init(method: method, path: path, parameters: parameters) { data in
            guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ResponseError.invalidData
            }
            
            return dictionary
        }
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Data?) {
        self.init(method: method, path: path, parameters: parameters) { data in
            guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ResponseError.invalidData
            }
            
            return dictionary
        }
    }
    
    public convenience init(_ configuration: Configuration) {
        self.init(configuration) { data in
            guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw ResponseError.invalidData
            }
            
            return dictionary
        }
    }
}

extension Endpoint where Response == Data {
    public convenience init(method: Method = .get, path: Path, parameters: (() -> ParameterType)? = nil) {
        self.init(method: method, path: path, parameters: parameters) { $0 }
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Parameters?) {
        self.init(method: method, path: path, parameters: parameters) { $0 }
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Data?) {
        self.init(method: method, path: path, parameters: parameters) { $0 }
    }
    
    public convenience init(_ configuration: Configuration) {
        self.init(configuration) { $0 }
    }
}

extension Endpoint where Response == Void {
    public convenience init(method: Method = .get, path: Path, parameters: (() -> ParameterType)? = nil) {
        self.init(
            method: method,
            path: path,
            parameters: parameters,
            decode: { _ in () }
        )
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Parameters?) {
        self.init(
            method: method,
            path: path,
            parameters: parameters,
            decode: { _ in () }
        )
    }

    public convenience init(method: Method = .get, path: Path, headers: Headers? = nil, parameters: Parameters? = nil) {
        self.init(
            method: method,
            path: path,
            headers: headers,
            parameters: parameters,
            decode: { _ in () }
        )
    }
    
    public convenience init(method: Method = .get, path: Path, parameters: Data?) {
        self.init(
            method: method,
            path: path,
            parameters: parameters,
            decode: { _ in () }
        )
    }
    
    public convenience init(_ configuration: Configuration) {
        self.init(
            configuration,
            decode: { _ in () }
        )
    }
}
