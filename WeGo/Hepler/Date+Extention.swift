//
//  Date+Extention.swift
//  FFL iOS
//
//  Created by Jude on 10/22/18.
//  Copyright © 2018 PartyApp. All rights reserved.
//

import Foundation

enum TimeOfDay {
    case Morning
    case Afternoon
    case Night
}

extension Date {
    
    var monthMedium: String  { return Formatter.monthMedium.string(from: self) }
    
    func getDateFor(days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func getTimeOfCurrentDay() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0...12:
            return .Morning
        case 13...17:
            return .Afternoon
        default:
            return .Night
        }
    }
    func getWeekend() -> Int {
        let calendar = Calendar.current
        let firstWeekday = calendar.component(.weekday, from: Date.init(timeIntervalSince1970: TimeInterval(1540822825)))
        let weekend = calendar.component(.weekday, from: Date()) - firstWeekday
        return weekend < 0 ? 6:weekend
    }
    
    func getMonth() -> Int {
        let calendar = Calendar.current
        let weekend = calendar.component(.month, from: self)
        return weekend
    }
    func getTimeIntervalString() -> Int {
        let startOfDate = Calendar.current.startOfDay(for: self)
        let timeInterval = Int(startOfDate.timeIntervalSince1970)
        return timeInterval
    }
    
    func getTimeStampFromDate() -> Int {
        let timeInterval = self.timeIntervalSince1970
        return Int(timeInterval)
    }
    
//    func getDateFromTimeStamp(timeStamp: Int) -> String {
//        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale.init(identifier: "vi_VN")
//        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
//        let strDate = dateFormatter.string(from: date)
//        
//        return strDate
//    }
}
extension Formatter {
    static let monthMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }()
}
