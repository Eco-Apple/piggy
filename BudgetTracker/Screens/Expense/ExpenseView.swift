//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import SwiftData
import SwiftUI

/*
    TODO:
    - This should be name ExpenseDetailView
 */


struct ExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .now
    
    @State private var isEdit: Bool = false
    
    @Bindable var expense: Expense
    
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
        .navigationTitle("Expense")
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEdit {
                    Button("Done") {
                        expense.title = name
                        expense.note = description
                        expense.amount = amount!
                        expense.date = date
                        expense.updatedDate = .now
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
    
    init(_ expense: Expense) {
        self.expense = expense
        
        self._name = State(initialValue: expense.title)
        self._description = State(initialValue: expense.note)
        self._amount = State(initialValue: expense.amount)
        self._date = State(initialValue: expense.createdDate)
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
        let container = try ModelContainer(for: Expense.self, configurations: config)
        let example = Expense.previewItem
        
        return ExpenseView(example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
