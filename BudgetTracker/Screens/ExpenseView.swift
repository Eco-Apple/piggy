//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isEdit: Bool = false
    
    @Bindable var expense: Expense
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        Form {
            Section("Details") {
                if isEdit == false {
                    InfoTextView(label: "Name", text: expense.name)
                    InfoTextView(label: "Description", text: expense.desc)
                } else {
                    TextField("Name", text: $expense.name)
                    TextField("Description", text: $expense.desc)
                }
                    
            }
            Section("Amount"){
                if isEdit == false {
                    Text("\(currencySymbol)\(expense.amount.toStringWithCommaSeparator ?? "")")
                } else {
                    CurrencyField("eg. \(currencySymbol)10.00", value: $expense.amount)
                }
            }
        }
        .navigationTitle("Expense")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEdit ? "Done" : "Edit") {
                    isEdit.toggle()
                }
            }
        }
    }
    
    init(_ expense: Expense) {
        self.expense = expense
    }
        
}

#Preview {
    return ExpenseView(Expense(name: "Book", desc: "Buying book", amount: 150.0, createdDate: Date(), updateDate: Date()))
}
