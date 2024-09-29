//
//  BudgetListView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftData
import SwiftUI

fileprivate struct BudgetSectionListView: View {
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    @Query var budgets: [Budget]
    
    @State private var isAlertPresented = false
    @State private var budgetsToDelete: [Budget] = []
    
    var fromToDate: (from: Date, to: Date)
    
    var body: some View {
        if budgets.isNotEmpty {
            Section("This week") {
                HStack {
                    InfoTextView(label: "Total", currency: total())
                        .font(.headline)
                }
                ForEach(budgets) { budget in
                    NavigationLink(value: NavigationRoute.budget(.detail(budget))) {
                        BudgetItemView(budget: budget)
                    }
                }
                .onDelete { offsets in
                    budgetsToDelete = []
                    for index in offsets {
                        let budget = budgets[index]
                        isAlertPresented = true
                        budgetsToDelete.append(budget)
                    }
                }
                .alert(isPresented: $isAlertPresented){
                    Alert(
                        title: Text("Are you sure you want to delete \(budgets.getPluralSuffix(singular: "this", plural: "these")) budget\(budgets.getPluralSuffix(singular: "", plural: "s"))?"),
                        message: Text("You cannot undo this action once done."),
                        primaryButton: .destructive(Text("Delete"), action: actionDelete),
                        secondaryButton: .cancel()
                    )
                }
            }
        } else {
            Section("This week") {
                HStack {
                    Spacer()
                    Image(systemName:"tray.fill")
                        .foregroundColor(.secondary)
                    Text("No budget.")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
    
    init(of fromToDate: (from: Date, to: Date), sortDescriptors: [SortDescriptor<Budget>]) {
        self.fromToDate = fromToDate
        
        let normalizedFromDate = fromToDate.from
        let normalizedToDate = fromToDate.to
                
        let fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate<Budget> { budget in
            if let budgetDate = budget.date {
                return budgetDate >= normalizedFromDate && budgetDate <= normalizedToDate
            } else {
                return false
            }
            
        }, sortBy: sortDescriptors)
        
        _budgets = Query(fetchDescriptor)
    }
    
    
    func total() -> Decimal {
        var result: Decimal = 0.0
        
        for val in budgets {
            result += val.totalBudget
        }
        
        return result
    }
    
    func actionDelete() {
        budgetsToDelete.delete(modelContext: modelContext)
        
        dismiss()
    }

}

struct BudgetListView: View {
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    var sortDescriptors: [SortDescriptor<Budget>]
    var fromToDate: (from: Date, to: Date)? = nil
    
    var body: some View {
        if !isBudgetsEmpty {
            List {
                Section("this week") {
                    InfoTextView(label: "Budgets", currency: Decimal(string: totalWeekBudgets)!)
                        .font(.headline)
                }

                if let fromToDate = fromToDate {
                    BudgetSectionListView(of: fromToDate, sortDescriptors: sortDescriptors)
                }
            }
        } else {
            EmptyMessageView(title: "No Budget", message: "Press '+' button at the upper right corner to add new budget.")
        }
    }
    
    init(sortDescriptors: [SortDescriptor<Budget>]) {
        self.sortDescriptors = sortDescriptors
        
        self.fromToDate = setupDate()
    }

    
    func setupDate() -> (from: Date, to: Date)? {
        let today = Date.now
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)?.localStartOfDate else { return nil }
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: today)?.localStartOfDate else { return nil }
        
        return (monday, nextDay)
    }
}

#Preview {
    BudgetListView(sortDescriptors: [SortDescriptor(\Budget.title)])
}
