//
//  D3ApiHandler.swift
//  Accounts
//
//  Created by David McRae jr on 8/28/18.
//

import Foundation
import WebKit
import Alamofire
import MobileCoreServices

class D3ApiHandler: NSObject, WKURLSchemeHandler {
    let hostName: String
    
    init(hostName: String) {
        self.hostName = hostName
    }
    
    @available(iOSApplicationExtension 11.0, *)
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        var request = urlSchemeTask.request
        
        if (request.url?.absoluteString.contains("/webComponents/") ?? false) {

            let updatedUrl = URL(
                string: request.url!.absoluteString.replacingOccurrences(of: "d3scheme://\(self.hostName)", with: "file://")
            )
            
            let data = try? Data(contentsOf: updatedUrl!)
            
            if data != nil {
                let headerFields = [
                    "Content-Type": "\(mimeType(pathExtension: request.url!.pathExtension)); charset=utf-8",
                    "Content-Length": "\(data!.count)"
                ]
                guard let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: "1.1",
                    headerFields: headerFields
                    ) else { return }
                
                urlSchemeTask.didReceive(response)
                urlSchemeTask.didReceive(data!)
                urlSchemeTask.didFinish()
            }
        } else {
            request.url = URL(string: request.url!.absoluteString.replacingOccurrences(of: "d3scheme", with: "https"))
    //        Native needs to add the cookies
            request.httpShouldHandleCookies = true
    //        Remove origin header
            request.setValue(nil, forHTTPHeaderField: "origin")
            
            Alamofire.request(request).response(queue: .main) { res in
                if let error = res.error {
                    urlSchemeTask.didFailWithError(error)
                    return
                }
                let origResponse = res.response!
                
                var headerFields = origResponse.allHeaderFields
                
                headerFields.updateValue("null", forKey: "Access-Control-Allow-Origin")
                headerFields.updateValue("Origin", forKey: "Vary")
                headerFields.updateValue("true", forKey: "Access-Control-Allow-Credentials")
                
                let response = HTTPURLResponse(
                    url: origResponse.url!,
                    statusCode: origResponse.statusCode,
                    httpVersion: "1.1",
                    headerFields: (headerFields as! [String: String])
                )
                
                urlSchemeTask.didReceive(response!)
                urlSchemeTask.didReceive(res.data!)
                urlSchemeTask.didFinish()
            }
        }
    }
    
    private func mimeType(pathExtension: String) -> String {
        guard let id = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            pathExtension as CFString, nil
            )?.takeRetainedValue() else { return "text/html" }
        guard let contentType = UTTypeCopyPreferredTagWithClass(
            id,
            kUTTagClassMIMEType
            )?.takeRetainedValue() else { return "text/html" }
        
        return contentType as String
    }
    
    @available(iOSApplicationExtension 11.0, *)
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {

    }
}
