//
//  BudgetSeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct BudgetSeeMoreView: View {
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    var date: Date
    @State var budgets: [Budget]
    
    @State private var isAlertPresented = false
    @State private var budgetsToDelete: [Budget] = []
    
    var body: some View {
        List {
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
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
    
    
    func actionDelete() {
        var totalDeletedBudgets: Decimal = 0.0
        
        for budget in budgetsToDelete {
//            totalDeletedBudgets = totalDeletedBudgets + budget.estimatedAmount TODO: Total budgets
            modelContext.delete(budget)
        }
        
        
        budgets.removeAll { budget in
            budgetsToDelete.contains(budget)
        }

        
        totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: totalDeletedBudgets, .sub)!
        
        do {
            let fetchDescriptor = FetchDescriptor<Budget>()
            let fetchBudgets = try modelContext.fetch(fetchDescriptor)
            
            if fetchBudgets.isEmpty {
                isBudgetsEmpty = true
            }
            
        } catch {
            fatalError("Error deleting budget")
        }
    }

}

#Preview {
    BudgetSeeMoreView(date: .now, budgets: [Budget.previewItem])
}
