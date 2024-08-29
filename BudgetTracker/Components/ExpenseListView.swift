//
//  ExpenseListView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/27/24.
//

import SwiftData
import SwiftUI

struct ExpenseSectionListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var expenses: [Expense]
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []
    
    
    var filterDate: Date
    
    var body: some View {
        if expenses.isNotEmpty {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
                ForEach(expenses) { expense in
                    NavigationLink(value: expense) {
                        ExpensListItemView(expense: expense)
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
                        primaryButton: .destructive(Text("Delete")) {
                            for expense in expensesToDelete {
                                modelContext.delete(expense)
                            }
                            
                            dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    init(of filterDate: Date) {
        self.filterDate = filterDate
        
        let normalizedDate = Calendar.current.startOfDay(for: filterDate)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: normalizedDate)!
        
        _expenses = Query(filter: #Predicate<Expense> { expense in
            
            return expense.createdDate >= normalizedDate && expense.createdDate < nextDay
        })
    }
}

struct ExpenseListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [Expense]
    
    let sectionsDate: [Date] = [
        Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date.now)!,
    ]
        
    var body: some View {
        if expenses.isNotEmpty{
            List {
                ExpenseSectionListView(of: Date.now)
                ExpenseSectionListView(of: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!)
                ForEach(sectionsDate, id: \.self) { date in
                    ExpenseSectionListView(of: date)
                }
            }
        } else {
            Text("No expenses")
               .foregroundColor(.gray)
               .font(.headline)
        }
    }
}

#Preview {
    ExpenseListView()
}
