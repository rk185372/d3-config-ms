//
//  MockServerRule.swift
//  D3 Banking
//
//  Created by Chris Carranza on 8/9/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import XCTest
import MockServer
import Embassy
import EnvoyAmbassador

final class MockServerRule: TestRule, Router {
    private var mockServer: MockServer!
    private var mockResponses: [String: [Method: MockResponse]] = [:]
    
    func setup(_ app: XCUIApplication) {
        do {
            let randomPort: Int = Int.random(in: 1111 ..< 9999)
            mockServer = try MockServer(port: randomPort)
            try mockServer.start()
            print("Started Server on port: \(randomPort)")
        } catch {
            fatalError("Failed to start server: \(error)")
        }
        
        app.launchEnvironment["testingURL"] = "http://localhost:\(mockServer.port)/d3rest"
    }
    
    func rulesHaveBeenSetup(otherRules: [TestRule]) {}
    
    func tearDown(_ app: XCUIApplication) {
        mockServer.stop()
        mockResponses = [:]
    }
    
    func prefix(path: String?, jsonPath: String?, router: (Router) -> Void) {
        router(GroupRouter(parentRouter: self, prefix: path, jsonPrefix: jsonPath))
    }
    
    func get(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status) {
        register(path: path, jsonPath: jsonPath, status: status, method: .GET, delay: delay)
    }
    
    func post(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status) {
        register(path: path, jsonPath: jsonPath, status: status, method: .POST, delay: delay)
    }
    
    func put(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status) {
        register(path: path, jsonPath: jsonPath, status: status, method: .PUT, delay: delay)
    }
    
    private func register(path: String,
                          jsonPath: String,
                          status: Status,
                          method: Method,
                          delay: MockServerRule.Delay) {
        
        let response = MockResponse(jsonPath: jsonPath, status: status, delay: delay)
        
        if mockResponses[path] != nil {
            mockResponses[path]![method] = response
        } else {
            mockResponses[path] = [method: response]
        }
        
        mockServer.router[path] = CustomResponse(path: path, methodResponseMap: mockResponses[path]!)
    }
    
    private final class CustomResponse: WebApp {
        private let path: String
        private let methodResponseMap: [Method: MockResponse]
        
        init(path: String, methodResponseMap: [Method: MockResponse]) {
            self.path = path
            self.methodResponseMap = methodResponseMap
        }
        
        func app(_ environ: [String: Any],
                 startResponse: @escaping ((String, [(String, String)]) -> Void),
                 sendBody: @escaping ((Data) -> Void)) {
            
            let method = MockServerRule.Method(rawValue: environ["REQUEST_METHOD"] as! String)!

            guard let mockResponse = methodResponseMap[method] else {
                let data = DataResponse(
                    statusCode: 404,
                    statusMessage: "Not found"
                )
                return data.app(environ, startResponse: startResponse, sendBody: sendBody)
            }
            
            let jsonResponse = DelayResponse(JSONResponse(statusCode: mockResponse.status.rawValue, handler: { _ -> Any in
                return try! JSONHelper.jsonResource(atPath: mockResponse.jsonPath)
            }), delay: mockResponse.delay)
            
            jsonResponse.app(environ, startResponse: startResponse, sendBody: sendBody)
        }
    }
}

protocol Router {
    func prefix(path: String?, jsonPath: String?, router: (Router) -> Void)
    func get(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status)
    func post(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status)
    func put(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status)
}

extension Router {
    func prefix(path: String, router: (Router) -> Void) {
        prefix(path: path, jsonPath: nil, router: router)
    }
    
    func prefix(jsonPath: String, router: (Router) -> Void) {
        prefix(path: nil, jsonPath: jsonPath, router: router)
    }
    
    func get(_ path: String, jsonPath: String, delay: MockServerRule.Delay = .none, status: MockServerRule.Status = .success) {
        get(path, jsonPath: jsonPath, delay: delay, status: status)
    }
    
    func post(_ path: String, jsonPath: String, delay: MockServerRule.Delay = .none, status: MockServerRule.Status = .success) {
        post(path, jsonPath: jsonPath, delay: delay, status: status)
    }
    
    func put(_ path: String, jsonPath: String, delay: MockServerRule.Delay = .none, status: MockServerRule.Status = .success) {
        put(path, jsonPath: jsonPath, delay: delay, status: status)
    }
}

private final class GroupRouter: Router {
    private let parentRouter: Router
    private let prefix: String?
    private let jsonPrefix: String?
    
    init(parentRouter: Router, prefix: String?, jsonPrefix: String?) {
        self.parentRouter = parentRouter
        self.prefix = prefix
        self.jsonPrefix = jsonPrefix
    }
    
    func prefix(path: String?, jsonPath: String?, router: (Router) -> Void) {
        router(GroupRouter(parentRouter: self, prefix: path, jsonPrefix: jsonPath))
    }
    
    func get(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status) {
        parentRouter.get(prefixPath(path: path), jsonPath: prefixJsonPath(path: jsonPath), delay: delay, status: status)
    }
    
    func post(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status) {
        parentRouter.post(prefixPath(path: path), jsonPath: prefixJsonPath(path: jsonPath), delay: delay, status: status)
    }
    
    func put(_ path: String, jsonPath: String, delay: MockServerRule.Delay, status: MockServerRule.Status) {
        parentRouter.put(prefixPath(path: path), jsonPath: prefixJsonPath(path: jsonPath), delay: delay, status: status)
    }
    
    private func prefixPath(path: String) -> String {
        if let prefix = prefix {
            return sanitizePrefix(prefix: prefix, suffix: path)
        } else {
            return path
        }
    }
    
    private func prefixJsonPath(path: String) -> String {
        if let prefix = jsonPrefix {
            return sanitizePrefix(prefix: prefix, suffix: path)
        } else {
            return path
        }
    }
    
    private func sanitizePrefix(prefix: String, suffix: String) -> String {
        // If either are empty we may end up returning a path that doesn't
        // make sense (i.e. trailing slash), so we don't do any sanitizing
        guard !prefix.isEmpty && !suffix.isEmpty else {
            return prefix + suffix
        }
        
        let pre = prefix.hasSuffix("/") ? String(prefix.dropLast()) : prefix
        let suf = suffix.hasPrefix("/") ? String(suffix.dropFirst()) : suffix
        
        return "\(pre)/\(suf)"
    }
}

extension MockServerRule {
    typealias Delay = DelayResponse.Delay
    enum Status: Int {
        case success = 200
        case unauthenticated = 401
        case failure = 500
    }
    
    enum Method: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    private struct MockResponse {
        var jsonPath: String
        var status: Status
        var delay: Delay
    }
}
