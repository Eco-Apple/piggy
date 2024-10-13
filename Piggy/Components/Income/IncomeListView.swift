//
//  BudgetListView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftData
import SwiftUI

fileprivate struct IncomeSectionListViewWrapper: View {
    
    var sortDescriptors: [SortDescriptor<Income>]
        
    @State var filterDate: Date
    @State var limit: Int
    
    private var initialLimitValue: Int
    
    var body: some View {
        IncomeSectionListView(of: filterDate, limit: $limit, sortDescriptors: sortDescriptors, initialLimitValue: initialLimitValue)
    }
    
    init(of filterDate: Date, sortDescriptors: [SortDescriptor<Income>], limit: Int) {
        self.filterDate = filterDate
        self.sortDescriptors = sortDescriptors
        self.limit = limit
        self.initialLimitValue = limit
    }
}


fileprivate struct IncomeSectionListView: View {
    @Environment(\.navigate) private var navigate
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isWeekIncomeEmpty") var isWeekIncomeEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @Query var incomes: [Income]
    
    @Binding private var limit: Int
    
    @State private var isAlertPresented = false
    @State private var incomesToDelete: [Income] = []
    
    private var limitToExpand: Int = 10 // default 10; test 4
    
    var initialLimitValue: Int
    
    var filterDate: Date
    
    var body: some View {
        if incomes.isNotEmpty {
            Section(filterDate.format(.dateOnly, descriptive: true)) {
                HStack {
                    InfoTextView(label: "Total", currency: total())
                        .font(.headline)
                }
                ForEach(incomes.prefix(limit)) { income in
                    NavigationLink(value: NavigationRoute.income(.detail(income))) {
                        IncomeItemView(income: income)
                    }
                }
                .onDelete { offsets in
                    incomesToDelete = []
                    for index in offsets {
                        let income = incomes[index]
                        isAlertPresented = true
                        incomesToDelete.append(income)
                    }
                }
                .alert(isPresented: $isAlertPresented){
                    Alert(
                        title: Text("Are you sure you want to delete \(incomes.getPluralSuffix(singular: "this", plural: "these")) income\(incomes.getPluralSuffix(singular: "", plural: "s"))?"),
                        message: Text("You cannot undo this action once done."),
                        primaryButton: .destructive(Text("Delete"), action: actionDelete),
                        secondaryButton: .cancel()
                    )
                }
                if incomes.count > limit || incomes.count > initialLimitValue {
                    Button(action: {
                        if incomes.count <= limitToExpand {
                            withAnimation {
                                if limit != limitToExpand {
                                    limit = limitToExpand
                                } else if limit == limitToExpand {
                                    limit = initialLimitValue
                                }
                            }
                        } else if incomes.count > limitToExpand {
                            let title = filterDate.format(.dateOnly, descriptive: true)
                            navigate(.income(.seeMore(title: title, incomes: incomes)))
                        }
                    }) {
                        Text(limit != limitToExpand ? "See More" : "See Less")
                            .font(.subheadline)
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
                    Text("No income.")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
    
    init(of filterDate: Date, limit: Binding<Int>, sortDescriptors: [SortDescriptor<Income>], initialLimitValue: Int) {
        self.filterDate = filterDate
        self.initialLimitValue = initialLimitValue
        self._limit = limit
        
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: filterDate)!
        
        var fetchDescriptor = FetchDescriptor<Income>(predicate: #Predicate<Income> { income in
            return income.date >= filterDate && income.date < nextDay
        }, sortBy: sortDescriptors)
        
        fetchDescriptor.fetchLimit = limit.wrappedValue + limitToExpand
        
        _incomes = Query(fetchDescriptor)
    }
    
    
    func total() -> Decimal {
        var result: Decimal = 0.0
        
        for val in incomes {
            result += val.amount
        }
        
        return result
    }
    
    func actionDelete() {
        incomesToDelete.delete(modelContext: modelContext)
        dismiss()
    }

}

struct IncomeListView: View {
    @AppStorage("isWeekIncomeEmpty") var isWeekIncomeEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    var sortDescriptors: [SortDescriptor<Income>]
    var sectionsDate: [Date] = []
    
    
    var body: some View {
        if !isWeekIncomeEmpty {
            List {
                Section("this week") {
                    InfoTextView(label: "Overall", currency: Decimal(string: totalWeekIncomes)!)
                        .font(.headline)
                }
                
                ForEach(sectionsDate, id: \.self) { date in
                    IncomeSectionListViewWrapper(of: date, sortDescriptors: sortDescriptors, limit: Calendar.current.startOfDay(for:date) == Calendar.current.startOfDay(for: .today) ? 5 : 3)
                }
            }
        } else {
            EmptyMessageView(title: "No Income", message: "Press '+' button at the upper right corner to add new income.")
        }
    }
    
    
    init(sortDescriptors: [SortDescriptor<Income>]) {
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
        
        var currentDate = monday.startOfDay
        
        while currentDate <= date {
            dates.insert(currentDate.startOfDay, at: 0)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    
        return dates
    }

}

#Preview {
    IncomeListView(sortDescriptors: [SortDescriptor(\Income.title)])
}
