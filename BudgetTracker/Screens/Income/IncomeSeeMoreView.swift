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
    
    @AppStorage("isIncomesEmpty") var isIncomesEmpty = true
    
    var date: Date
    var incomes: [Income]
    
    @State private var isAlertPresented = false
    @State private var incomesToDelete: [Income] = []
    
    var body: some View {
        List {
            ForEach(incomes) { income in
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
        }
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
    
    
    func actionDelete() {
        for income in incomesToDelete {
            modelContext.delete(income)
        }
        
        do {
            let fetchDescriptor = FetchDescriptor<Income>()
            let fetchIncomes = try modelContext.fetch(fetchDescriptor)
            
            if fetchIncomes.isEmpty {
                isIncomesEmpty = true
            }
            
        } catch {
            fatalError("Error deleting expense")
        }
    }

}

#Preview {
    IncomeSeeMoreView(date: .now, incomes: [Income.previewItem])
}
