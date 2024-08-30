//
//  ExpenseListView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/27/24.
//

import SwiftData
import SwiftUI


fileprivate struct ExpenseSectionListViewWrapper: View {
    
    var sortDescriptors: [SortDescriptor<Expense>]
    
    @Binding var path: NavigationPath
    
    @State var filterDate: Date
    @State var limit: Int
    
    private var initialLimitValue: Int
    
    var body: some View {
        ExpenseSectionListView(of: filterDate, limit: $limit, path: $path, sortDescriptors: sortDescriptors, initialLimitValue: initialLimitValue)
    }
    
    init(of filterDate: Date, sortDescriptors: [SortDescriptor<Expense>], limit: Int, path: Binding<NavigationPath>) {
        self.filterDate = filterDate
        self.sortDescriptors = sortDescriptors
        self.limit = limit
        self.initialLimitValue = limit
        self._path = path
    }
}

fileprivate struct ExpenseSectionListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Query var expenses: [Expense]
    
    @Binding private var limit: Int
    @Binding var path: NavigationPath
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []
    
    
    private var limitToExpand: Int = 4 // default 10
    
    var initialLimitValue: Int
    
    var filterDate: Date
    
    var body: some View {
        if expenses.isNotEmpty {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
                ForEach(expenses.prefix(limit)) { expense in
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
                if expenses.count > limit || expenses.count > initialLimitValue {
                    Button(action: {
                        if expenses.count <= limitToExpand {
                            withAnimation {
                                if limit != limitToExpand {
                                    limit = limitToExpand
                                } else if limit == limitToExpand {
                                    limit = initialLimitValue
                                }
                            }
                        } else if expenses.count > limitToExpand {
                            path.append(expenses)
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
    
    init(of filterDate: Date, limit: Binding<Int>, path: Binding<NavigationPath>, sortDescriptors: [SortDescriptor<Expense>], initialLimitValue: Int) {
        self.filterDate = filterDate
        self.initialLimitValue = initialLimitValue
        self._limit = limit
        self._path = path
        
        let normalizedDate = Calendar.current.startOfDay(for: filterDate)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: normalizedDate)!
        
        var fetchDescriptor = FetchDescriptor<Expense>(predicate: #Predicate<Expense> { expense in
            return expense.createdDate >= normalizedDate && expense.createdDate < nextDay
        }, sortBy: sortDescriptors)
        
        fetchDescriptor.fetchLimit = limit.wrappedValue + limitToExpand
        
        _expenses = Query(fetchDescriptor)
    }

}

struct ExpenseListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [Expense]
    
    @Binding var path: NavigationPath
    
    var sortDescriptors: [SortDescriptor<Expense>]
    
    let sectionsDate: [Date] = [
        Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date.now)!,
    ]
        
    var body: some View {
        if expenses.isNotEmpty{
            List {
                ExpenseSectionListViewWrapper(of: Date.now, sortDescriptors: sortDescriptors, limit: 2 /* default 5 */, path: $path)
                ExpenseSectionListViewWrapper(of: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, sortDescriptors: sortDescriptors, limit: 3, path: $path)
                ForEach(sectionsDate, id: \.self) { date in
                    ExpenseSectionListViewWrapper(of: date, sortDescriptors: sortDescriptors, limit: 3, path: $path)
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
    ExpenseListView(path: .constant(NavigationPath()), sortDescriptors: [SortDescriptor(\Expense.name)])
}
