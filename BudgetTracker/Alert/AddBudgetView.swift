//
//  AddBudgetView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftUI

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    @State var title: String = ""
    @State var note: String = ""
    @State var amount: Decimal? = nil
    @State var date: Date = .now
    
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
            .navigationTitle("New Budget")
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
        let newBudget = Budget(title: title, note: note, amount: amount!,date: date, createdDate: .now, updatedDate: .now, isTimeEnabled: isTimeEnabled)
        
        totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: newBudget.amount, .add)!
        
        modelContext.insert(newBudget)
        isBudgetsEmpty = false
        dismiss()
    }
}

#Preview {
    return AddBudgetView()
}
