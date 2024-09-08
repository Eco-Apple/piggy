//
//  BudgetView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct IncomeDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .now
    
    @State private var isEdit: Bool = false
    
    @Bindable var income: Income
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        Form {
            Section("Details") {
                if isEdit == false {
                    InfoTextView(label: "Title", text: name)
                    InfoTextView(label: "Amount", currency: amount!)
                    InfoTextView(label: "Date", date: date)
                } else {
                    TextField("Title", text: $name)
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                    
            }
            Section("Note"){
                if isEdit == false {
                    Text(description)
                        .frame(height: 150, alignment: .topLeading)
                } else {
                    TextEditor(text: $description)
                        .frame(height: 150)
                        .offset(x: -5, y: -8.5)
                }
            }
        }
        .navigationTitle("Income")
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEdit {
                    Button("Done") {
                        income.title = name
                        income.note = description
                        income.amount = amount!
                        income.date = date
                        income.updatedDate = .now
                        isEdit.toggle()
                    }
                    .disabled(isDoneButtonDisabled())
                } else if isEdit == false {
                    Button("Edit" ) {
                        isEdit.toggle()
                    }
                }
            }
        }
    }
    
    init(_ income: Income) {
        self.income = income
        
        self._name = State(initialValue: income.title)
        self._description = State(initialValue: income.note)
        self._amount = State(initialValue: income.amount)
        self._date = State(initialValue: income.createdDate)
    }
    
    func isDoneButtonDisabled() -> Bool {
        
        guard name.isNotEmpty else { return true }
        guard description.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        
        return false
    }
        
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Income.self, configurations: config)
        let example = Income.previewItem
        
        return IncomeDetailView(example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
