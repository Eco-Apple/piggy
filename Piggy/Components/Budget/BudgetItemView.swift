//
//  BudgetListItemView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct BudgetItemView: View {
    var budget: Budget
    
    
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading) {
                Text(budget.title)
                     .font(.headline)
                if budget.isTimeEnabled {
                    Text("@" + budget.date!.format(.timeOnly))
                        .font(.caption)
                }
            }
            Spacer()
            Text(budget.totalBudget.toCurrency).foregroundStyle(Color.budgetFontColor(amount: budget.totalBudget))
                .font(.headline)
        }
    }
    
    func amountEmoji() -> String {
        if budget.totalBudget < 0 {
            "😭"
        } else if budget.totalBudget == 0 {
            budget.isFresh ? "😐" : "😭"
        } else if budget.totalBudget > 0 && budget.totalBudget <= 100 {
            "👍"
        } else if budget.totalBudget > 100 && budget.totalBudget <= 300  {
            "👌"
        }else if budget.totalBudget > 300 && budget.totalBudget < 500  {
            "💰"
        } else {
            "🔥"
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Budget.self, configurations: config)
        let example = Budget.previewItem
        
        return BudgetItemView(budget: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }

}
