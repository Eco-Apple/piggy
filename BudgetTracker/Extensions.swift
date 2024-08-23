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

extension Formatter {
    static var currencyWithSeparator: Formatter {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.currencyCode = Locale.current.currency?.identifier ?? "USD" // Default to USD if currency identifier is unavailable
      formatter.maximumFractionDigits = 2
      formatter.minimumFractionDigits = 2
      formatter.usesGroupingSeparator = true
      return formatter
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
