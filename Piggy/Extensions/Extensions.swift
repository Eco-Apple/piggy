//
//  Extensions.swift
//  Piggy
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
