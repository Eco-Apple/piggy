//
//  BudgetSeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct IncomeSeeMoreView: View {
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isWeekIncomeEmpty") var isWeekIncomeEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    var title: String
    @State var incomes: [Income]
    var canAdd: Bool
    
    @State private var isAlertPresented = false
    @State private var incomesToDelete: [Income] = []
    @State private var isAddPresented = false
    
    var passedBudget: Budget? = nil
    
    var body: some View {
        VStack {
            if !incomes.isEmpty {
                List {
                    InfoTextView(label: "Total", currency: total())
                    ForEach(incomes) { income in
                        NavigationLink(value: NavigationRoute.income(.detail(income))) {
                            let caption = income.isTimeEnabled ? income.date.format(.dateAndTime) : income.date.format(.dateOnly)
                            IncomeItemView(income: income, caption: caption)
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
                            primaryButton: .destructive(Text("Delete"), action: delete),
                            secondaryButton: .cancel()
                        )
                    }
                }
            } else {
                EmptyMessageView(title: "No Income", message: "Press '+' button at the upper right corner to add new income.")
            }
        }
        .navigationTitle(title)
        .toolbar {
            if canAdd {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add button", systemImage: "plus") {
                        isAddPresented = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddPresented) {
            AddIncomeView(removeBudget: true, passedBudget: passedBudget) { income in
                incomes.append(income)
            }
        }
    }
    
    func total() -> Decimal {
        if let passedBudget = passedBudget {
            return passedBudget.totalIncome
        }
        
        return incomes.reduce(0) { $0 + $1.amount }
    }
    
    func delete() {
        incomesToDelete.delete(modelContext: modelContext)
        incomes.removeAll { income in
            incomesToDelete.contains(income)
        }
    }

}

#Preview {
    IncomeSeeMoreView(title: "Incomes", incomes: [], canAdd: false)
}
