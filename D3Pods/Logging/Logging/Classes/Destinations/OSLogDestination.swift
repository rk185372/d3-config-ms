//
//  OSLogDestination.swift
//  Pods
//
//  Created by Branden Smith on 11/29/18.
//

import Foundation
import os
import SwiftyBeaver

public final class OSLogDestination: BaseDestination {

    public override func send(_ level: SwiftyBeaver.Level,
                              msg: String,
                              thread: String,
                              file: String,
                              function: String,
                              line: Int,
                              context: Any?) -> String? {
        // The file parameter is the entire path to the file and we are only interested
        // in the filename. Because we only want the file name, we split the string on
        // path components and then grab the last component (the filename).
        var filename = file
        if let actualFilename = file.split(separator: "/").last {
            filename = String(actualFilename)
        }

        let log = OSLog(
            subsystem: Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "com.d3banking",
            category: "Runtime Log"
        )

        os_log(
            "%{public}@ %{public}@:%i - %{public}@",
            log: log,
            type: logLevel(for: level),
            filename,
            function,
            line,
            msg
        )

        return super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
    }

    private func logLevel(for logType: SwiftyBeaver.Level) -> OSLogType {
        switch logType {
        case .verbose:
            return .default
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .error
        case .error:
            return .fault
        }
    }
}
