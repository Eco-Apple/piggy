//
//  BudgetListView.swift
//  BudgetTracker
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
    
    @AppStorage("isIncomesEmpty") var isIncomesEmpty = true
    
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
                ForEach(incomes.prefix(limit)) { income in
                    NavigationLink(value: NavigationRoute.income(.detail(income))) {
                        IncomeListItemView(income: income)
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
                            navigate(.income(.seeMore(filterDate, incomes)))
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
    
    init(of filterDate: Date, limit: Binding<Int>, sortDescriptors: [SortDescriptor<Income>], initialLimitValue: Int) {
        self.filterDate = filterDate
        self.initialLimitValue = initialLimitValue
        self._limit = limit
        
        let normalizedDate = Calendar.current.startOfDay(for: filterDate)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: normalizedDate)!
        
        var fetchDescriptor = FetchDescriptor<Income>(predicate: #Predicate<Income> { income in
            if let incomeDate = income.date {
                return incomeDate >= normalizedDate && incomeDate < nextDay
            } else {
                return false
            }
            
        }, sortBy: sortDescriptors)
        
        fetchDescriptor.fetchLimit = limit.wrappedValue + limitToExpand
        
        _incomes = Query(fetchDescriptor)
    }
    
    func actionDelete() {
        for income in incomesToDelete {
            modelContext.delete(income)
        }
        
        
        do {
            let fetchDescriptor = FetchDescriptor<Income>()
            let fetchincome = try modelContext.fetch(fetchDescriptor)
            
            
            if fetchincome.isEmpty {
                isIncomesEmpty = true
            }
            
            dismiss()
        } catch {
            fatalError("Error deleting income.")
        }
    }

}

struct IncomeListView: View {
    @AppStorage("isIncomesEmpty") var isIncomesEmpty = true
    
    var sortDescriptors: [SortDescriptor<Income>]
    
    let sectionsDate: [Date] = [
        Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date.now)!,
    ]
    
    
    var body: some View {
        if !isIncomesEmpty {
            List {
                IncomeSectionListViewWrapper(of: Date.now, sortDescriptors: sortDescriptors, limit: 5)
                IncomeSectionListViewWrapper(of: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, sortDescriptors: sortDescriptors, limit: 3)
                ForEach(sectionsDate, id: \.self) { date in
                    IncomeSectionListViewWrapper(of: date, sortDescriptors: sortDescriptors, limit: 3)
                }
            }
        } else {
            ContentUnavailableView {
                Label("No Income", systemImage: "tray.fill")
            } description: {
                Text("New income you added will appear here.")
            }
        }
    }
}

#Preview {
    IncomeListView(sortDescriptors: [SortDescriptor(\Income.title)])
}
