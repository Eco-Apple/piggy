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
                ForEach(budgets.prefix(limit)) { budget in
                    NavigationLink(value: NavigationRoute.budget(.detail(budget))) {
                        BudgetListItemView(budget: budget)
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
    
    func actionDelete() {
        for budget in budgetsToDelete {
            modelContext.delete(budget)
        }
        
        
        do {
            let fetchDescriptor = FetchDescriptor<Budget>()
            let fetchBudgets = try modelContext.fetch(fetchDescriptor)
            
            
            if fetchBudgets.isEmpty {
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
    
    var sortDescriptors: [SortDescriptor<Budget>]
    
    let sectionsDate: [Date] = [
        Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date.now)!,
    ]
    
    
    var body: some View {
        if !isBudgetsEmpty {
            List {
                BudgetSectionListViewWrapper(of: Date.now, sortDescriptors: sortDescriptors, limit: 5)
                BudgetSectionListViewWrapper(of: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, sortDescriptors: sortDescriptors, limit: 3)
                ForEach(sectionsDate, id: \.self) { date in
                    BudgetSectionListViewWrapper(of: date, sortDescriptors: sortDescriptors, limit: 3)
                }
            }
        } else {
            ContentUnavailableView {
                Label("No Budget", systemImage: "tray.fill")
            } description: {
                Text("New budget you added will appear here.")
            }
        }
    }
}

#Preview {
    BudgetListView(sortDescriptors: [SortDescriptor(\Budget.title)])
}
