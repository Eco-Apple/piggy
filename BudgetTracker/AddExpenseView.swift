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
    @State var amount: Decimal? = nil
    
    @FocusState private var isNameFocus: Bool
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                        .focused($isNameFocus)
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                }
                Section("Description") {
                    TextField("Description", text: $description, axis: .vertical)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        let newExpense = Expense(name: name, desc: description, amount: amount!, createdDate: Date(), updateDate: Date())
                        
                        modelContext.insert(newExpense)
                        dismiss()
                    }.disabled(isConfirmDisabled())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isNameFocus = true
                }
            }
        }
    }
    
    func isConfirmDisabled() -> Bool {
        name.isEmpty || description.isEmpty || amount == nil || amount! <= 0
    }
}

#Preview {
    return AddExpenseView()
}
