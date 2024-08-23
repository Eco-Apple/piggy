//
//  AddExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var amount = 0.0
    @State var reasonForExpense = ""
    
    @State var isConfirmAlertPresented = false
    
    var expenses: Expenses
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount", value: $amount, formatter: .currencyWithSeparator   )
                    .keyboardType(.decimalPad)
                TextField("Reason for expense", text: $reasonForExpense)
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        isConfirmAlertPresented = true
                    }.disabled(isConfirmDisabled())
                }
            }
            .alert(isPresented: $isConfirmAlertPresented){
                Alert(
                    title: Text("Add Item"),
                    message: Text("Are you sure do you want this expense ?"),
                    primaryButton: .default(Text("Yes")) {
                        let expense = ExpenseItem(amount: amount, reasonForExpense: reasonForExpense, createdDate: Date(), updateDate: Date())
                        
                        expenses.items.append(expense)
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func isConfirmDisabled() -> Bool {
        return !(reasonForExpense.isNotEmpty && amount > 0)
    }
}

#Preview {
    AddExpenseView(expenses: Expenses())
}
