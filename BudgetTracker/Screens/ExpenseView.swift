//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var expenses: Expenses
    var item: ExpenseItem
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var amount: Decimal = 0.0
    
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
                    
                    if let i = expenses.items.firstIndex(of: item) {
                        var expense = item
                        expense.name = name
                        expense.description = description
                        expense.amount = amount
                        expense.updateDate = Date()
                        expenses.items[i] = expense
                    }
                    
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
    
    init(expenses: Binding<Expenses>, item: ExpenseItem) {
        self._expenses = expenses
        self.item = item
        
        self._name = State(initialValue: item.name)
        self._description = State(initialValue: item.description)
        self._amount = State(initialValue: item.amount)
    }
    
    func isSaveDisabled() -> Bool{
        name == item.name && description == item.description && amount == item.amount
    }
}

#Preview {
    @State var expenses = Expenses()
    return ExpenseView(expenses: $expenses, item: ExpenseItem(name: "Test", description: "Test", amount: 10, createdDate: Date(), updateDate: Date()))
}
