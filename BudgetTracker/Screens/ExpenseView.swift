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
    @State private var amount: Decimal? = nil
    
    @State private var isEdit: Bool = false
    
    @Bindable var expense: Expense
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        Form {
            Section("Details") {
                if isEdit == false {
                    InfoTextView(label: "Name", text: name)
                    InfoTextView(label: "Amount", currency: amount!)
                } else {
                    TextField("Name", text: $name)
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                }
                    
            }
            Section("Description"){
                if isEdit == false {
                    Text(description)
                } else {
                    TextField("Description", text: $description, axis: .vertical)
                }
            }
        }
        .navigationTitle("Expense")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEdit {
                    Button("Done") {
                        expense.name = name
                        expense.desc = description
                        expense.amount = amount!
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
        
        self._name = State(initialValue: expense.name)
        self._description = State(initialValue: expense.desc)
        self._amount = State(initialValue: expense.amount)
    }
    
    func isDoneButtonDisabled() -> Bool {
        
        guard name.isNotEmpty else { return true }
        guard description.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        
        return false
    }
        
}

#Preview {
    return ExpenseView(Expense(name: "Book", desc: "Buying book", amount: 150.0, createdDate: Date(), updateDate: Date()))
}
