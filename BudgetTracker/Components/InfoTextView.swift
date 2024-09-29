//
//  InfoTextView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/1/24.
//

import SwiftUI


struct InfoTextView: View {
    var label: String
    var text: String?
    var value: String?
    var status: String?
    var date: String?
    var currency: String?
    
    var tags: [String] = []
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    var isButton: Bool = false
    var isLink: Bool = false
    
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
                Text( text ?? value ?? status ?? date ?? currency ?? "")
                    .foregroundStyle(foregroundStyleOfValue())
                
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
    }
    
    // Number
    init(label: String, value: Int?) {
        self.label = label
        if let value {
            self.value = String(value)
        }
    }
    
    // Status
    init(label: String, status: Bool) {
        self.label = label
        self.status = status ? "Yes" : "No"
    }
    
    // Date
    init(label: String, date: Date, style: DateStyle) {
        self.label = label
        self.date = date.format(style)
    }
    
    // Tags
    init(label: String, tags: [String]) {
        self.label = label
        self.tags = tags
    }
    
    // Currency
    init(label: String, currency: Decimal, isButton: Bool = false, isLink: Bool = false) {
        self.label = label
        self.currency = currencySymbol + (currency.toStringWithCommaSeparator ?? "")
        self.isButton = isButton
        self.isLink = isLink
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
    InfoTextView(label: "Settings", date: .now, style: .dateOnly)
}
