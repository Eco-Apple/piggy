//
//  CurrencyField.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/23/24.
//

import SwiftUI

/*
    TODO:
    - ‼️ Fix user can type alphabets using copy paste ( for simulator, external keyboard can also type alphabets )
 */

struct CurrencyField: View {
    
    var title: String
    @Binding var value: Decimal?
    @State private var text = ""
    
    private var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.decimalPad)
            .onChange(of: text) { oldValue, newValue in
                setStringandFormatValue(of: newValue) { textVal, decimalVal in
                    text = textVal
                    value = decimalVal
                }
            }
            .onAppear {
                
                if var value {
                    let stringAmount = "\(value)"
                    
                    // expense.amount + 0.001 ? this make sure that amount with no decimals has .00
                    value = stringAmount.contains(".") ? value : value + 0.001
                    
                    setStringandFormatValue(of: "\(value)") { textVal, decimalVal in
                        text = textVal
                        value = decimalVal!
                    }
                }
            }
    }
    
    init(_ title: String, value: Binding<Decimal?>) {
        self.title = title
                
        self._value = value
    }
    
    func setStringandFormatValue(of newValue: String, callback: (String, Decimal?) -> Void) {
        
        if newValue.isEmpty {
            callback("", nil)
            return
        }
        
        let new = newValue.replacingOccurrences(of: currencySymbol, with: "")
        
        if let formattedString = new.toDecimalWithCommaSeparator {
            let textVal = currencySymbol + formattedString
            let decimalVal = Decimal(Double(formattedString.replacingOccurrences(of: ",", with: "")) ?? 0.0)
            callback(textVal, decimalVal)
        }
    }
    
    
}

#Preview {
    @Previewable @State var amount: Decimal? = nil
    return CurrencyField("Amount",value: $amount)
}
