//
//  File.swift
//
//
//  Created by shutut on 2021/10/7.
//

import Foundation

public extension String {
    
    static let isoDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    static let ustcDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    static let commonDateFormat =  "yyyy-MM-dd HH:mm:ss"
    
    static let chineseDateFormat = "yyyy年MM月dd日 HH时mm分ss秒"
    
    func dateWith(_ format: String, timeZone: TimeZone? = nil) -> Date? {
        let str = self
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let timeZone {
            formatter.timeZone = timeZone
        }
        let date = formatter.date(from: str)
        return date
    }
    
    var isoTimeDate: Date? {
        dateWith(.isoDateFormat, timeZone: TimeZone(secondsFromGMT: 0))
    }
    
    var ustcTimeDate: Date? {
        dateWith(.ustcDateFormat)
    }
    
    var commonDate: Date? {
        return dateWith(.commonDateFormat)
    }
    
    var chineseDate: Date? {
        return dateWith(.chineseDateFormat)
    }
}

public extension Date {
    
    func stringFrom(_ format: String, timeZone: TimeZone? = nil) -> String {
        let date = self
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let timeZone {
            formatter.timeZone = timeZone
        }
        let str = formatter.string(from: date)
        return str
    }
    
    var isoTimeString: String {
        stringFrom(.isoDateFormat, timeZone: TimeZone(secondsFromGMT: 0))
    }
    
    var utcTimeString: String {
        stringFrom(.ustcDateFormat)
    }
    
    var commonDesc: String? {
        return stringFrom(.commonDateFormat)
    }
    
    var chineseDesc: String? {
        return stringFrom(.chineseDateFormat)
    }
}

public extension Date {
    
    static var timestamp: Int {
        let curr = Date().timeIntervalSince1970 * 1000.0
        return Int(curr)
    }
    
    var timestamp: Int {
        let curr = self.timeIntervalSince1970 * 1000.0
        return Int(curr)
    }
}

public extension Int {
    var date: Date? {
        Date(timeIntervalSince1970: TimeInterval(self) / 1000.0)
    }
}

public func currentDateDesc() -> String {
    return Date().chineseDesc ?? "日期"
}
