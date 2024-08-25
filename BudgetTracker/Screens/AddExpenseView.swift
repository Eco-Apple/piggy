//
//  AddExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var description: String = ""
    @State var amount: Decimal = 0.0
    
    @State var isConfirmAlertPresented: Bool = false
    
    @Binding var expenses: Expenses
    
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
                        isConfirmAlertPresented = true
                    }.disabled(isConfirmDisabled())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $isConfirmAlertPresented){
                Alert(
                    title: Text("Add Item"),
                    message: Text("Are you sure do you want this expense ?"),
                    primaryButton: .default(Text("Yes")) {
                        let expense = ExpenseItem(name: name, description: description, amount: amount, createdDate: Date(), updateDate: Date())
                        
                        expenses.items.append(expense)
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func isConfirmDisabled() -> Bool {
        name.isEmpty || description.isEmpty || amount <= 0
    }
}

#Preview {
    @State var expenses = Expenses()
    return AddExpenseView(expenses: $expenses)
}
