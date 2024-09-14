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
    
    @AppStorage("isExpensesEmpty") var isExpensesEmpty = true
    
    var date: Date
    var expenses: [Expense]
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []

    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                NavigationLink(value: NavigationRoute.expense(.detail(expense))) {
                    ExpensItemView(expense: expense)
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
                    primaryButton: .destructive(Text("Delete"), action: actionDelete),
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
    
    
    func actionDelete() {
        for expense in expensesToDelete {
            modelContext.delete(expense)
        }
        
        do {
            let fetchDescriptor = FetchDescriptor<Expense>()
            let fetchExpenses = try modelContext.fetch(fetchDescriptor)
            
            if fetchExpenses.isEmpty {
                isExpensesEmpty = true
            }
            
        } catch {
            fatalError("Error deleting expense")
        }
    }
}

#Preview {
    ExpenseSeeMoreView(date: .now, expenses: [Expense.previewItem])
}
