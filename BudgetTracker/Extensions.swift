//
//  Extensions.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import Foundation

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
}


extension String {
    var toDecimalWithCommaSeparator: String? {
        let components = self.split(separator: ".")
        let integerPart: Substring? = components.first
        let decimalPart: Substring? = components.count > 1 ? components[1] : nil
        let hasDecimal = self.contains(".")
        var result : String? = nil
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""
        
        
        if let integer = integerPart {
            let val = String(integer).replacingOccurrences(of: ",", with: "")
            
            if let formatted = formatter.string(from: Int(val)! as NSNumber) {
                result = formatted
            }
        }
        
        if hasDecimal {
            if integerPart == nil {
                result = "0"
            }
            result = result! + "."
        }
        
        if let decimal = decimalPart {
            let val = String(decimal).prefix(2)
            
            result = result! + val
        }
        
        return result
    }
}


extension String {
    
    enum ArithmeticOperation {
        case add, sub
    }
    
    func arithmeticOperation(of decimal: Decimal, _ operation: ArithmeticOperation ) -> String? {
        
        guard let selfDecimal = Decimal(string: self) else { return nil}
        
        switch operation {
        case .add:
            return "\(selfDecimal + decimal)"
        case .sub:
            return "\(selfDecimal - decimal)"
        }
        
    }
    
}

extension Date {

    func format(_ dateStyle: DateStyle, descriptive: Bool = false) -> String {
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        
        if descriptive {
            if calendar.startOfDay(for: self) == calendar.startOfDay(for: Date.now) {
                return "Today"
            }
            
            if calendar.startOfDay(for: self) == calendar.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!) {
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

