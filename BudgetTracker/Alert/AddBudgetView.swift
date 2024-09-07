//
//  AddBudgetView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftUI

/*
 TODO:
 - Make an optional date picker ( similar to reminders app )
 */

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    
    @State var title: String = ""
    @State var note: String = ""
    @State var amount: Decimal? = nil
    @State var date: Date = .now
    
    @FocusState private var isFocus: Bool
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                        .focused($isFocus)
                }
                
                Section {
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
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
        title.isEmpty || note.isEmpty || amount == nil || amount! <= 0
    }
    
    func addEntry() {
        let newBudget = Budget(title: title, note: note, amount: amount!,date: date, createdDate: .now, updateDate: .now)
        
        modelContext.insert(newBudget)
        isBudgetsEmpty = false
        dismiss()
    }
}

#Preview {
    return AddBudgetView()
}
