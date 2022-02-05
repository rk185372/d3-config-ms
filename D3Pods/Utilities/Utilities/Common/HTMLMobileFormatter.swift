//
//  HTMLMobileFormatter.swift
//  Utilities
//
//  Created by Chris Carranza on 10/12/18.
//

import Foundation

public final class HTMLMobileFormatter {
    public static func format(_ html: String) -> String {
        return """
        <html><head><meta name=\"viewport\" content=\"user-scalable=1.0,initial-scale=1.0,minimum-
        scale=1.0,maximum-scale=1.0\"><meta name=\"apple-mobile-web-app-capable\" content=\"yes\">
        <style> body { font: -apple-system-body; margin: 20px } </style></head><body>\(html)</body></html>
        """
    }
}
