//
//  ExpenseListView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/27/24.
//

import StoreKit
import SwiftData
import SwiftUI

fileprivate struct ExpenseSectionListViewWrapper: View {
    
    var sortDescriptors: [SortDescriptor<Expense>]
        
    @State var filterDate: Date
    @State var limit: Int
    
    private var initialLimitValue: Int
    
    var body: some View {
        ExpenseSectionListView(of: filterDate, limit: $limit, sortDescriptors: sortDescriptors, initialLimitValue: initialLimitValue)
    }
    
    init(of filterDate: Date, sortDescriptors: [SortDescriptor<Expense>], limit: Int) {
        self.filterDate = filterDate
        self.sortDescriptors = sortDescriptors
        self.limit = limit
        self.initialLimitValue = limit
    }
}

fileprivate struct ExpenseSectionListView: View {
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @Query var expenses: [Expense]
    
    @Binding private var limit: Int
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []
    @State private var isTotalSheetPresented = false
    
    private var limitToExpand: Int = 10 // default 10; test 4
    
    var initialLimitValue: Int
    
    var filterDate: Date
    
    var body: some View {
        if expenses.isNotEmpty {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
                HStack {
                    InfoTextView(label: "Total", currency: total())
                        .font(.headline)
                }
                ForEach(expenses.prefix(limit)) { expense in
                    NavigationLink(value: NavigationRoute.expense(.detail(expense))) {
                        ExpenseItemView(expense: expense)
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
                            let title = filterDate.format(.dateOnly, descriptive: true)
                            navigate(.expense(.seeMore(title: title, expenses: expenses)))
                        }
                    }) {
                        Text(limit != limitToExpand ? "See More" : "See Less")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onChange(of: expenses) {
                        limit = initialLimitValue
                    }
                }
            }
        } else {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
                HStack {
                    Spacer()
                    Image(systemName:"tray.fill")
                        .foregroundColor(.secondary)
                    Text("No expense.")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
    
    init(of filterDate: Date, limit: Binding<Int>, sortDescriptors: [SortDescriptor<Expense>], initialLimitValue: Int) {
        self.filterDate = filterDate
        self.initialLimitValue = initialLimitValue
        self._limit = limit
        
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: filterDate)!
                
        var fetchDescriptor = FetchDescriptor<Expense>(predicate: #Predicate<Expense> { expense in
            return expense.date >= filterDate && expense.date < nextDay
        }, sortBy: sortDescriptors)
        
        fetchDescriptor.fetchLimit = limit.wrappedValue + limitToExpand
        
        _expenses = Query(fetchDescriptor)
    }
    
    func total() -> Decimal {
        var result: Decimal = 0.0
        
        for val in expenses {
            result += val.amount
        }
        
        return result
    }
    
    func actionDelete() {
        expensesToDelete.delete(modelContext: modelContext)
        dismiss()
    }

}

struct ExpenseListView: View {
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    var sortDescriptors: [SortDescriptor<Expense>]
    var sectionsDate: [Date] = []
        
    var body: some View {
        if !isWeekExpenseEmpty{
            List {
                Section("this week") {
                    InfoTextView(label: "Overall", currency: Decimal(string: totalWeekExpenses)!)
                        .font(.headline)
                }
                
                ForEach(sectionsDate, id: \.self) { date in
                    ExpenseSectionListViewWrapper(of: date, sortDescriptors: sortDescriptors, limit: Calendar.current.startOfDay(for:date) == Calendar.current.startOfDay(for: Date.today) ? 5 : 3)
                }
            }
            .listSectionSpacing(.compact)
        } else {
            EmptyMessageView(title: "No Expense", message: "Press '+' button at the upper right corner to add new expense.")
        }
    }
    
    init(sortDescriptors: [SortDescriptor<Expense>]) {
        self.sortDescriptors = sortDescriptors
        
        self.sectionsDate = setupDates()
    }
    
    
    func setupDates() -> [Date] {
        let date = Date.today
        let calendar = Calendar.current
        var dates: [Date] = []
        
        let weekday = calendar.component(.weekday, from: date)

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: date) else { return [] }
        
        var currentDate = monday
        
        while currentDate <= date {
            dates.insert(currentDate.startOfDay, at: 0)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
}

#Preview {
    ExpenseListView(sortDescriptors: [SortDescriptor(\Expense.title)])
}
