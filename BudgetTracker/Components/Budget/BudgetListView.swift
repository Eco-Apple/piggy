//
//  BudgetListView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftData
import SwiftUI

fileprivate struct BudgetSectionListViewWrapper: View {
    
    var sortDescriptors: [SortDescriptor<Budget>]
        
    @State var filterDate: Date
    @State var limit: Int
    
    private var initialLimitValue: Int
    
    var body: some View {
        BudgetSectionListView(of: filterDate, limit: $limit, sortDescriptors: sortDescriptors, initialLimitValue: initialLimitValue)
    }
    
    init(of filterDate: Date, sortDescriptors: [SortDescriptor<Budget>], limit: Int) {
        self.filterDate = filterDate
        self.sortDescriptors = sortDescriptors
        self.limit = limit
        self.initialLimitValue = limit
    }
}


fileprivate struct BudgetSectionListView: View {
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    @Query var budgets: [Budget]
    
    @Binding private var limit: Int
    
    @State private var isAlertPresented = false
    @State private var budgetsToDelete: [Budget] = []
    
    private var limitToExpand: Int = 10 // default 10; test 4
    
    var initialLimitValue: Int
    
    var filterDate: Date
    
    var body: some View {
        if budgets.isNotEmpty {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
                HStack {
                    InfoTextView(label: "Total", currency: total())
                        .font(.headline)
                }
                ForEach(budgets.prefix(limit)) { budget in
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
                if budgets.count > limit || budgets.count > initialLimitValue {
                    Button(action: {
                        if budgets.count <= limitToExpand {
                            withAnimation {
                                if limit != limitToExpand {
                                    limit = limitToExpand
                                } else if limit == limitToExpand {
                                    limit = initialLimitValue
                                }
                            }
                        } else if budgets.count > limitToExpand {
                            navigate(.budget(.seeMore(filterDate, budgets)))
                        }
                    }) {
                        Text(limit != limitToExpand ? "See More" : "See Less")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        } else {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
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
    
    init(of filterDate: Date, limit: Binding<Int>, sortDescriptors: [SortDescriptor<Budget>], initialLimitValue: Int) {
        self.filterDate = filterDate
        self.initialLimitValue = initialLimitValue
        self._limit = limit
        
        let normalizedDate = Calendar.current.startOfDay(for: filterDate)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: normalizedDate)!
        
        var fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate<Budget> { budget in
            if let budgetDate = budget.date {
                return budgetDate >= normalizedDate && budgetDate < nextDay
            } else {
                return false
            }
            
        }, sortBy: sortDescriptors)
        
        fetchDescriptor.fetchLimit = limit.wrappedValue + limitToExpand
        
        _budgets = Query(fetchDescriptor)
    }
    
    
    func total() -> Decimal {
        var result: Decimal = 0.0
        
        for val in budgets {
            result += val.amount
        }
        
        return result
    }
    
    func actionDelete() {
        var totalDeletedBudgets: Decimal = 0.0
        
        for budget in budgetsToDelete {
            totalDeletedBudgets = totalDeletedBudgets + budget.amount
            modelContext.delete(budget)
        }
        
        totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: totalDeletedBudgets, .sub)!
        
        do {
            let fetchDescriptor = FetchDescriptor<Budget>()
            let fetchBudget = try modelContext.fetch(fetchDescriptor)
            
            
            if fetchBudget.isEmpty {
                isBudgetsEmpty = true
            }
            
            dismiss()
        } catch {
            fatalError("Error deleting budget.")
        }
    }

}

struct BudgetListView: View {
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    var sortDescriptors: [SortDescriptor<Budget>]
    var sectionsDate: [Date] = []
    
    
    var body: some View {
        if !isBudgetsEmpty {
            List {
                    Section("this week") {
                        InfoTextView(label: "Budgets", currency: Decimal(string: totalWeekBudgets)!)
                            .font(.headline)
                    }
                    
                    ForEach(sectionsDate, id: \.self) { date in
                        BudgetSectionListViewWrapper(of: date, sortDescriptors: sortDescriptors, limit: Calendar.current.startOfDay(for:date) == Calendar.current.startOfDay(for: Date.now) ? 5 : 3)
                    }
            }
        } else {
            EmptyMessageView(title: "No Budget", message: "Press '+' button at the upper right corner to add new budget.")
        }
    }
    
    init(sortDescriptors: [SortDescriptor<Budget>]) {
        self.sortDescriptors = sortDescriptors
        
        self.sectionsDate = setupDates()
    }

    
    func setupDates() -> [Date] {
        var date = Date.now
        let calendar = Calendar.current
        let currentWeekdayNumber = calendar.component(.weekday, from: date)
        
        var dates: [Date] = []
        
        if currentWeekdayNumber == 1 {
            date = calendar.date(byAdding: .day, value: -1, to: date)!
        }
        
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        components.weekday = 2
        
        guard let monday = calendar.nextDate(after: date, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .backward) else {
            return []
        }

        var currentDate = monday
        
        while currentDate <= date {
            dates.insert(currentDate, at: 0)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        if currentWeekdayNumber == 1 {
            dates.insert(Date.now, at: 0)
        }
        
        return dates
    }
}

#Preview {
    BudgetListView(sortDescriptors: [SortDescriptor(\Budget.title)])
}
