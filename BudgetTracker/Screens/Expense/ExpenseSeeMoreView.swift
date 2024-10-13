//
//  SeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/30/24.
//

import SwiftData
import SwiftUI

struct ExpenseSeeMoreView: View {
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    var title: String
    @State var expenses: [Expense]
    var canAdd: Bool
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []
    @State private var isAddPresented = false
    
    var passedBudget: Budget? = nil
    
    var body: some View {
        VStack {
            if !expenses.isEmpty {
                List {
                    InfoTextView(label: "Total", currency: total())
                    ForEach(expenses) { expense in
                        NavigationLink(value: NavigationRoute.expense(.detail(expense))) {
                            let caption = expense.isTimeEnabled ? expense.date.format(.dateAndTime) : expense.date.format(.dateOnly)
                            ExpenseItemView(expense: expense, caption: caption)
                        }
                    }
                    .onDelete { offsets in
                        expensesToDelete = []
                        for index in offsets {
                            let expense = expenses[index]
                            isAlertPresented = true
                            expensesToDelete.append(expense)
                        }
                    }
                    .alert(isPresented: $isAlertPresented){
                        Alert(
                            title: Text("Are you sure you want to delete \(expenses.getPluralSuffix(singular: "this", plural: "these")) expense\(expenses.getPluralSuffix(singular: "", plural: "s"))?"),
                            message: Text("You cannot undo this action once done."),
                            primaryButton: .destructive(Text("Delete"), action: delete),
                            secondaryButton: .cancel()
                        )
                    }
                }
            } else {
                EmptyMessageView(title: "No Expense", message: "Press '+' button at the upper right corner to add new expense.")
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if canAdd {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add button", systemImage: "plus") {
                        isAddPresented = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddPresented) {
            AddExpenseView(removeBudget: true, passedBudget: passedBudget) { expense in
                expenses.append(expense)
            }
        }
    }
    
    func total() -> Decimal {
        if let passedBudget = passedBudget {
            return passedBudget.totalExpense
        }
        
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    func delete() {
        expensesToDelete.delete(modelContext: modelContext)
        
        expenses.removeAll { expense in
            expensesToDelete.contains(expense)
        }
    }
}

#Preview {
    ExpenseSeeMoreView(title: "Expenses", expenses: [Expense.previewItem], canAdd: false)
}
