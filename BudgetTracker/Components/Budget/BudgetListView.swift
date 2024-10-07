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
    @AppStorage("totalBudget") var totalBudget = "0.0"
    
    @Query var budgets: [Budget]
    
    @State private var isAlertPresented = false
    @State private var budgetsToDelete: [Budget] = []
    
    var body: some View {
        if budgets.isNotEmpty {
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
        } else {
            Section {
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
    
    init(sortDescriptors: [SortDescriptor<Budget>]) {
        let fetchDescriptor = FetchDescriptor<Budget>(sortBy: sortDescriptors)
        
        _budgets = Query(fetchDescriptor)
    }
    
    func actionDelete() {
        budgetsToDelete.delete(modelContext: modelContext)
        
        dismiss()
    }

}

struct BudgetListView: View {
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalBudget") var totalBudget = "0.0"
    
    var sortDescriptors: [SortDescriptor<Budget>]
    
    var body: some View {
        if !isBudgetsEmpty {
            List {
                Section {
                    InfoTextView(label: "Total", currency: Decimal(string: totalBudget)!)
                        .font(.headline)
                    BudgetSectionListView(sortDescriptors: sortDescriptors)
                }
            }
        } else {
            EmptyMessageView(title: "No Budget", message: "Press '+' button at the upper right corner to add new budget.")
        }
    }
    
    init(sortDescriptors: [SortDescriptor<Budget>]) {
        self.sortDescriptors = sortDescriptors
    }
}

#Preview {
    BudgetListView(sortDescriptors: [SortDescriptor(\Budget.title)])
}
