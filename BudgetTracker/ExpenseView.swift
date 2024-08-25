//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var amount: Decimal = 0.0
    
    @Bindable var expense: Expense
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
            }
            Section("Amount"){
                CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
            }
        }
        .navigationTitle("Expense")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    expense.name = name
                    expense.desc = description
                    expense.amount = amount
                    expense.updateDate = Date()
                    dismiss()
                }
                .disabled(isSaveDisabled())
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    init(_ expense: Expense) {
        self.expense = expense
        
        self._name = State(initialValue: expense.name)
        self._description = State(initialValue: expense.desc)
        self._amount = State(initialValue: expense.amount)
    }
    
    func isSaveDisabled() -> Bool{
        if name == expense.name && description == expense.desc && amount == expense.amount {
            return true
        }
        if name.isEmpty || description.isEmpty || amount <= 0 {
            return true
        }
        
        return false
    }
    
}

#Preview {
    return ExpenseView(Expense(name: "Book", desc: "Buying book", amount: 150.0, createdDate: Date(), updateDate: Date()))
}
