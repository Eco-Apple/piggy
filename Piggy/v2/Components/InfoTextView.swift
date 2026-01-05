//
//  InfoTextView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/1/24.
//

import SwiftUI

struct InfoTextView: View {
    private var label: String
    private var text: String?
    private var value: String?
    private var status: String?
    private var date: String?
    private var currency: String?
    private var placeholder: String?
    
    private var isField: Bool = false
    @Binding private var bindedCurrency: Decimal?
    private var currencyColor: Color? = nil
    
    private var tags: [String] = []
    
    private var isButton: Bool = false
    private var isLink: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(foregroundStyleOfLabel())
            
            Spacer()
            
            if tags.isNotEmpty { // Coming soon
                ForEach(tags, id: \.self) {
                    Text($0)
                }
            } else {
                
                if let text = text ?? value ?? status ?? date ?? currency {
                    Text(text)
                        .foregroundStyle(currencyColor ?? foregroundStyleOfValue())
                }
                
                if isField {
                    CurrencyField(placeholder ?? "", value: $bindedCurrency)
                        .multilineTextAlignment(.trailing)
                }
                
                if isLink {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(foregroundStyleOfValue())
                }
            }
        }
        .contentShape(Rectangle())  // Makes the entire HStack area tappable
    }
    
    // Text
    init(label: String, text: String) {
        self.label = label
        self.text = text
        
        self._bindedCurrency = .constant(nil)
    }
    
    // Number
    init(label: String, value: Int?) {
        self.label = label
        if let value {
            self.value = String(value)
        }
        
        self._bindedCurrency = .constant(nil)
    }
    
    // Status
    init(label: String, status: Bool) {
        self.label = label
        self.status = status ? "Yes" : "No"
        
        self._bindedCurrency = .constant(nil)
    }
    
    // Date
    init(label: String, date: Date, style: DateStyle) {
        self.label = label
        self.date = date.format(style)
        
        self._bindedCurrency = .constant(nil)
    }
    
    // Tags
    init(label: String, tags: [String]) {
        self.label = label
        self.tags = tags
        
        self._bindedCurrency = .constant(nil)
    }
    
    // Currency
    init(label: String, currency: Decimal, isButton: Bool = false, isLink: Bool = false, prefix: String = "", currencyColor: Color? = nil) {
        self.label = label
        self.currency = prefix + currency.toCurrency
        self.isButton = isButton
        self.isLink = isLink
        self.currencyColor = currencyColor
        
        self._bindedCurrency = .constant(nil)
    }
    
    // Currency Text Field
    init(label: String, currency: Binding<Decimal?>, placeholder: String = "") {
        self.label = label
        self._bindedCurrency = currency
        self.placeholder = placeholder
        self.isField = true
    }
    
    
    func foregroundStyleOfLabel() -> Color {
        
        if isButton {
            return .accentColor
        }
        
        return .primary
    }

    
    func foregroundStyleOfValue() -> Color {
        if status != nil {
            return status == "Yes" ? .green : .red
        }
        
        return .secondary
    }
    
}

#Preview {
    InfoTextView(label: "Settings", currency: .constant(nil), placeholder: "0.00")
}
