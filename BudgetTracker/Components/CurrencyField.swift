//
//  CurrencyField.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/23/24.
//

import SwiftUI

struct CurrencyField: View {
    
    var title: String
    @Binding var value: Decimal
    @State private var text = ""
    
    private var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.decimalPad)
            .onChange(of: text) { oldValue, newValue in
                var new = newValue.replacingOccurrences(of: currencySymbol, with: "")
                
                if let formattedString = new.toDecimalWithCommaSeparator {
                    text = currencySymbol + formattedString
                    value = Decimal(Double(formattedString.replacingOccurrences(of: ",", with: "")) ?? 0.0)
                }
            }
    }
    
    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
        self._text = State(initialValue: currencySymbol + (value.wrappedValue.toStringWithCommaSeparator ?? ""))
    }
    
    
}

#Preview {
    @State var amount: Decimal = 0.0
    return CurrencyField("Amount",value: $amount)
}
