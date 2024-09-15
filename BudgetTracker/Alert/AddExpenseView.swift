//
//  AddExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import StoreKit
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isExpensesEmpty") var isExpensesEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .now
    
    @State private var isTimeEnabled: Bool = false
    
    @FocusState private var isFocus: Bool
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                        .focused($isFocus)
                }
                
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date
                )
                
                Toggle(isOn: $isTimeEnabled) {
                    Text("Time")
                }
                
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $note)
                        .placeHolder("Note", text: $note)
                        .frame(height: 150)
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("New Expense")
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addEntry).disabled(isConfirmDisabled())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocus = true
                }
            }
        }
    }
    
    func isConfirmDisabled() -> Bool {
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        
        return false
    }
    
    func addEntry() {
        let newExpense = Expense(title: title, note: note, amount: amount!,date: date, createdDate: .now, updateDate: .now, isTimeEnabled: isTimeEnabled)
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: newExpense.amount, .add)!
        
        modelContext.insert(newExpense)
        isExpensesEmpty = false
        dismiss()
    }
}

#Preview {
    return AddExpenseView()
}
