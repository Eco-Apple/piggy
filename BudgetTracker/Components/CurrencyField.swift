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
    
    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.decimalPad)
            .onChange(of: text) { oldValue, newValue in
                if let formattedString = newValue.toDecimalWithCommaSeparator {
                    text = formattedString
                    value = Decimal(Double(formattedString.replacingOccurrences(of: ",", with: "")) ?? 0.0)
                }
            }
    }
    
    init(_ title: String, value: Binding<Decimal>) {
        self.title = title
        self._value = value
        self._text = State(initialValue: value.wrappedValue.toStringWithCommaSeparator ?? "")
    }
    
    
}

#Preview {
    @State var amount: Decimal = 0.0
    return CurrencyField("Amount",value: $amount)
}
