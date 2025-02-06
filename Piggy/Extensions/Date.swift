//
//  DateExtension.swift
//  Piggy
//
//  Created by Jerico Villaraza on 2/6/25.
//

import Foundation

extension Date {
    
    static var today: Date {
        #if DEBUG
            let calendar = Calendar.current

            return calendar.date(byAdding: .day, value: 0, to: .now)!
        #endif
        return Date.now
    }
    
    static var getPreviousStartDayMonday: Date {
        let today = Date.today
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        
        let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)!.startOfDay
        
        return monday
    }
    
    var startOfDay: Date {
        let startOfDate = Calendar.current.startOfDay(for: self)
        
        return startOfDate
    }


    func format(_ dateStyle: DateStyle, descriptive: Bool = false) -> String {
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        
        if descriptive {
            if calendar.startOfDay(for: self) == calendar.startOfDay(for: Date.today) {
                return "Today"
            }
            
            if calendar.startOfDay(for: self) == calendar.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date.today)!) {
                return "Yesterday"
            }
        }
        
        switch dateStyle {
        case .dateAndTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: self)
        case .dateOnly:
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        case .timeOnly:
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
    
    static func getDatesUntilLastMonday() -> [Date] {
        let date = Date.today
        let calendar = Calendar.current
        var dates: [Date] = []
        
        let weekday = calendar.component(.weekday, from: date)

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: date) else { return [] }
        
        var currentDate = monday
        
        while currentDate <= date {
            dates.insert(currentDate.startOfDay, at: 0)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
}
