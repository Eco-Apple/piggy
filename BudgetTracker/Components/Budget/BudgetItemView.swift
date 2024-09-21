//
//  BudgetListItemView.swift
//  BudgetTracker
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
            Text("+ \(budget.amount, format: .currency(code: "PHP"))").foregroundStyle(amountForegroundColor())
                .font(.headline)
        }
    }
    
    func amountEmoji() -> String {
        if budget.amount <= 100 {
            "👍"
        } else if budget.amount > 100 && budget.amount <= 300  {
            "👌"
        } else if budget.amount > 300 && budget.amount < 500  {
            "💰"
        } else {
            "🔥"
        }
    }
    
    func amountForegroundColor() -> Color {
        if budget.amount <= 200 {
            Color.green
        } else if budget.amount > 200 && budget.amount <= 500  {
            Color.orange
        } else if budget.amount > 500 && budget.amount < 1000  {
            Color.purple
        } else {
            Color.red
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
