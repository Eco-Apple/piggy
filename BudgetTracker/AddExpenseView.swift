//
//  AddExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State var name: String = ""
    @State var description: String = ""
    @State var amount: Decimal = 0.0
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                }
                Section("Amount") {
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        let newExpense = Expense(name: name, desc: description, amount: amount, createdDate: Date(), updateDate: Date())
                        
                        modelContext.insert(newExpense)
                        dismiss()
                    }.disabled(isConfirmDisabled())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }        }
    }
    
    func isConfirmDisabled() -> Bool {
        name.isEmpty || description.isEmpty || amount <= 0
    }
}

#Preview {
    return AddExpenseView()
}
