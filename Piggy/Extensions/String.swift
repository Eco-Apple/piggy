//
//  StringExtension.swift
//  Piggy
//
//  Created by Jerico Villaraza on 10/3/24.
//

import Foundation

extension String {
    
    enum ArithmeticOperation {
        case add, sub
    }
    
    var toDate: Date? {
        let isoFormatter = ISO8601DateFormatter()
        
        return isoFormatter.date(from: self)
    }
    
    func arithmeticOperation(of decimal: Decimal, _ operation: ArithmeticOperation) -> String? {
        guard let selfDecimal = Decimal(string: self) else { return nil}
        
        switch operation {
        case .add:
            return "\(selfDecimal + decimal)"
        case .sub:
            return "\(selfDecimal - decimal)"
        }
        
    }
    
    
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
