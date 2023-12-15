//
//  DateFormatter+.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

extension Date {
    static let nowTime: String = {
        return DateFormatter.customDateTime.string(from: Date())
    }()
}

extension DateFormatter {
    static let customDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()
}
