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
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if tags.isNotEmpty { // Coming soon
                ForEach(tags, id: \.self) {
                    Text($0)
                }
            } else {
                Text( text ?? value ?? status ?? date ?? currency ?? "")
                    .foregroundStyle(foregroundStyleOfValue())
            }
        }
    }
    
    init(label: String, text: String) {
        self.label = label
        self.text = text
    }
    
    init(label: String, value: Int) {
        self.label = label
        self.value = String(value)
    }
    
    init(label: String, status: Bool) {
        self.label = label
        self.status = status ? "Yes" : "No"
    }
    
    init(label: String, date: Date) {
        self.label = label
        self.date = date.format(.dateAndTime)
    }
    
    init(label: String, tags: [String]) {
        self.label = label
        self.tags = tags
    }
    
    init(label: String, currency: Decimal) {
        self.label = label
        self.currency = currencySymbol + (currency.toStringWithCommaSeparator ?? "")
    }
    
    
    func foregroundStyleOfValue() -> Color {
        if status != nil {
            return status == "Yes" ? .green : .red
        }
        
        return .secondary
    }
    
}

#Preview {
    InfoTextView(label: "Settings", date: .now)
}
