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
        
    @State var filterDate: Date?
    @State var limit: Int?
    var title: String?
    
    private var initialLimitValue: Int?
    var showTotal: Bool
    var showDate: Bool
    
    var body: some View {
        ExpenseSectionListView(of: title, filterDate: filterDate, limit: $limit, sortDescriptors: sortDescriptors, initialLimitValue: initialLimitValue, showTotal: showTotal, showDate: showDate)
    }
    
    init(of title: String? = nil, filterDate: Date? = nil, sortDescriptors: [SortDescriptor<Expense>] = [], limit: Int? = nil, showTotal: Bool = true, showDate: Bool = false) {
        self.title = title
        self.filterDate = filterDate
        self.sortDescriptors = sortDescriptors
        self.limit = limit
        self.initialLimitValue = limit
        self.showTotal = showTotal
        self.showDate = showDate
    }
}

fileprivate struct ExpenseSectionListView: View {
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @Query var expenses: [Expense]
    
    @Binding private var limit: Int?
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []
    @State private var isTotalSheetPresented = false
    
    private var limitToExpand: Int = 10 // default 10; test 4
    
    var initialLimitValue: Int?
    
    var filterDate: Date?
    
    var title: String?
    
    var showTotal: Bool
    var showDate: Bool
    
    var body: some View {
        if expenses.isNotEmpty {
            Section(header: title.map { Text($0) }) {
                if showTotal {
                    HStack {
                        InfoTextView(label: "Total", currency: total())
                            .font(.headline)
                    }
                }
                
                ForEach(expenses.prefix(limit ?? Int.max)) { expense in
                    NavigationLink(value: NavigationRoute.expense(.detail(expense))) {
                        let caption = expense.isTimeEnabled ? expense.date.format(.dateAndTime) : expense.date.format(.dateOnly)
                        
                        ExpenseItemView(expense: expense, caption: showDate ? caption : nil)
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
                if var limit, let initialLimitValue, let filterDate, expenses.count > limit || expenses.count > initialLimitValue {
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
            Section(header: title.map { Text($0) }) {
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
    
    init(of title: String?, filterDate : Date? = nil, limit: Binding<Int?>, sortDescriptors: [SortDescriptor<Expense>] = [], initialLimitValue: Int? = nil, showTotal: Bool, showDate: Bool) {
        self.title = title
        self.filterDate = filterDate
        self.initialLimitValue = initialLimitValue
        self._limit = limit
        self.showTotal = showTotal
        self.showDate = showDate
        
        if let filterDate {
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: filterDate)!
            
            var fetchDescriptor = FetchDescriptor<Expense>(predicate: #Predicate<Expense> { expense in
                return expense.date >= filterDate && expense.date < nextDay
            }, sortBy: sortDescriptors)
            
            if let value = limit.wrappedValue {
                fetchDescriptor.fetchLimit = value + limitToExpand
            }
            
            _expenses = Query(fetchDescriptor)
        } else {
            var fetchDescriptor = FetchDescriptor<Expense>(sortBy: sortDescriptors)
            
            if let value = limit.wrappedValue {
                fetchDescriptor.fetchLimit = value + limitToExpand
            }
            
            _expenses = Query(fetchDescriptor)
        }
        
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
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @State private var selectedDateFilter = "This Week"
    
    var sortDescriptors: [SortDescriptor<Expense>]
    var sectionsDate: [Date] = []
        
    var body: some View {
        List {
            Picker("Select a segment", selection: $selectedDateFilter) {
                Text("This Week")
                    .tag("This Week")
                Text("All Time")
                    .tag("All Time")
             }
             .pickerStyle(SegmentedPickerStyle())
             .frame(width: 250)
             .listRowInsets(EdgeInsets())
             .listRowBackground(Color.clear)
            
            
            
            if selectedDateFilter == "This Week" {
                Section {
                    InfoTextView(label: "Overall", currency: Decimal(string: totalWeekExpenses)!)
                        .font(.headline)
                }
                
                ForEach(sectionsDate, id: \.self) { date in
                    ExpenseSectionListViewWrapper(of: date.format(.dateOnly, descriptive: true), filterDate: date, sortDescriptors: sortDescriptors, limit: Calendar.current.startOfDay(for:date) == Calendar.current.startOfDay(for: Date.today) ? 5 : 3)
                }
            } else if selectedDateFilter == "All Time" {
                ExpenseSectionListViewWrapper(showDate: true)
            }
        }
        .listSectionSpacing(.compact)
    }
    
    init(sortDescriptors: [SortDescriptor<Expense>]) {
        self.sortDescriptors = sortDescriptors
        
        self.sectionsDate = Date.getDatesUntilLastMonday()
    }
    
}

#Preview {
    let container = try! ModelContainer(for: Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    let context = container.mainContext
    let sampleExpense: Expense = .previewItem
    context.insert(sampleExpense)
    
    let standard = UserDefaults.standard
    standard.set(false, forKey: "isWeekExpenseEmpty")
    standard.set("99.99", forKey: "totalWeekExpenses")
    
    return ExpenseListView(sortDescriptors: [SortDescriptor(\Expense.title)])
        .modelContainer(container)
}
