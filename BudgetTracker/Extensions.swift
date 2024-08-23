//
//  Extensions.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import Foundation


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

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
