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
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    var date: Date
    @State var expenses: [Expense]
    
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
        var totalDeletedExpenses: Decimal = 0.0
        
        for expense in expensesToDelete {
            totalDeletedExpenses = totalDeletedExpenses + expense.amount
            modelContext.delete(expense)
        }
        
        expenses.removeAll { expense in
            expensesToDelete.contains(expense)
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: totalDeletedExpenses, .sub)!
        
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
