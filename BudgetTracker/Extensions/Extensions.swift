//
//  Extensions.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI
import SwiftData

//extension Array where Element: Expense {}

extension Array {
    func getPluralSuffix(singular: String, plural: String) -> String {
        self.count > 1 ? plural : singular
    }
}

extension Collection {
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

extension Decimal {
    var toStringWithCommaSeparator: String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        let result = formatter.string(from: self as NSNumber)

        return result?.toDecimalWithCommaSeparator
    }
    
    var toCurrency: String {
        let currencySymbol = Locale.current.currencySymbol ?? ""
        let isNegative = self.sign == .minus
        
        if isNegative {
            return "- " + currencySymbol + (self * -1).toStringWithCommaSeparator!
        }
        
        return currencySymbol + self.toStringWithCommaSeparator!
    }
}



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
    
}

extension Color {
    static func expenseFontColor(amount: Decimal) -> Color {
        if amount <= 200 {
            Color.green
        } else if amount > 200 && amount <= 500  {
            Color.orange
        } else if amount > 500 && amount < 1000  {
            Color.purple
        } else {
            Color.red
        }
    }
    
    static func incomeFontColor(amount: Decimal) -> Color {
        if amount <= 200 {
            Color.green
        } else if amount > 200 && amount <= 500  {
            Color.orange
        } else if amount > 500 && amount < 1000  {
            Color.purple
        } else {
            Color.red
        }
    }
    
    static func budgetFontColor(amount: Decimal) -> Color {
        if amount <= 200 {
            Color.green
        } else if amount > 200 && amount <= 500  {
            Color.orange
        } else if amount > 500 && amount < 1000  {
            Color.purple
        } else {
            Color.red
        }
    }

}
