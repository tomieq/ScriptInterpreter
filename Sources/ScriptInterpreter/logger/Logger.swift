//
//  Logger.swift
//
//
//  Created by Tomasz on 09/11/2022.
//

import Foundation

struct Logger {
    private init() {}

    static func v(_ label: String, _ log: String) {
        Self.log(label, log)
    }

    static func e(_ label: String, _ log: String) {
        Self.log(label + "❗", log)
    }

    static func log(_ label: String, _ log: String) {
        let log = log.replacingOccurrences(of: "\\/", with: "/")
        let localMessage = "\(Self.logDate()) [\(label)] \(log)"
        print(localMessage)
    }

    private static func logDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
}
