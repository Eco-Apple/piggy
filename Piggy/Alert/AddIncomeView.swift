//
//  AddIncomeView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isWeekIncomeEmpty") var isWeekIncomeEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @Query var budgets: [Budget]
    
    @State var title: String = ""
    @State var note: String = ""
    @State var amount: Decimal? = nil
    @State var date: Date = .today
    @State private var budget: Budget?
    
    @State private var isTimeEnabled: Bool = false
    
    @State private var isAddBudgetPresented: Bool = false
    
    @FocusState private var isFocus: Bool
    
    var saveLater: Bool = false
    var removeBudget: Bool = false
    var passedBudget: Budget? = nil

    var callback: (Income) -> Void = { _ in }
        
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount*") {
                    CurrencyField("eg. 10.00", value: $amount)
                        .focused($isFocus)
                }
                                
                Section {
                    DatePicker(
                        "Date",
                        selection: $date,
                        in: ...Date(),
                        displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date
                    )
                    
                    Toggle(isOn: $isTimeEnabled) {
                        Text("Time")
                    }
                }
                
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $note)
                        .placeHolder("Note", text: $note)
                        .frame(height: 150)
                }
                
                if passedBudget == nil && !removeBudget {
                    if budget != nil {
                        Picker("Budget", selection: $budget) {
                            ForEach(budgets) { budget in
                                Text(budget.title).tag(budget)
                            }
                        }
                    } else {
                        Button("Add Budget") {
                            isAddBudgetPresented = true
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("New Income")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $isAddBudgetPresented) {
                AddBudgetView(removeIncome: true, removeExpense: true) { newBudget in
                    budget = newBudget
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocus = true
                }
                
                if passedBudget == nil {
                    budget = budgets.first
                }
            }
        }
    }
    
    init(saveLater: Bool = false, removeBudget: Bool = false, passedBudget: Budget? = nil, callback: @escaping (Income) -> Void = { _ in}) {
        self.callback = callback
        self.saveLater = saveLater
        self.removeBudget = removeBudget
        
        self.passedBudget = passedBudget
        
        if let passedBudget = passedBudget {
            self._budget = State(initialValue: passedBudget)
        }
    }
    
    func isConfirmDisabled() -> Bool {
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        guard budget != nil || removeBudget else { return true }
        
        return false
    }
    
    func addEntry() {
        
        let newIncome = Income(title: title, note: note, amount: amount!,date: date, createdDate: .today, updatedDate: .today, isTimeEnabled: isTimeEnabled, budget: budget ?? .placeholder)
        
        if saveLater {
            dismiss()
            
            callback(newIncome)
            return
        }
        
        guard budget != nil else {
            debugPrint("Budget must not be nil")
            return
        }
        
        newIncome.save(modelContext: modelContext)
        dismiss()
        callback(newIncome)
    }
}

#Preview {
    return AddIncomeView()
}
