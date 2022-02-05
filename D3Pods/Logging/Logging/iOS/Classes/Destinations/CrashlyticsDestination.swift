//
//  CrashlyticsDestination.swift
//  Accounts-iOS
//
//  Created by Branden Smith on 1/30/20.
//

import FirebaseCrashlytics
import Foundation
import SwiftyBeaver

private enum CrashlyticsNonFatalError: Error {
    case generic
}

public final class CrashlyticsDestination: BaseDestination {

    private let crashlytics: Crashlytics

    public init(crashlytics: Crashlytics) {
        self.crashlytics = crashlytics
    }

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

        let additionalInfo: [String: Any] = [
            "message": msg,
            "thread": thread,
            "filename": filename,
            "function": function,
            "line": line
        ]

        switch level {
        case .error:
            var error: Error
            if let contextAsError = context as? Error {
                error = contextAsError
            } else {
                error = CrashlyticsNonFatalError.generic
            }

            let nsError = error as NSError
            let finalError = NSError(domain: nsError.domain, code: nsError.code, userInfo: additionalInfo)
            crashlytics.record(error: finalError)
            
        default:
            // Note that these need to stay in this order for the format string.
            Crashlytics
                .crashlytics()
                .log(format: "Thread: %@, Line: %d, %@ %@\nMessage: %@", arguments: getVaList([
                    thread,
                    line,
                    filename,
                    function,
                    msg
                ])
            )
        }

        return super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
    }
}
