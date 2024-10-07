//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftData
import SwiftUI

struct ExpenseItemView: View {
    var expense: Expense
    
    var caption: String? = nil
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading, spacing: 1) {
                Text(expense.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if let caption = caption {
                    Text(caption)
                        .font(.caption)
                        .lineLimit(1)
                } else {
                    if expense.note.isNotEmpty {
                        Text(expense.note)
                            .font(.caption)
                            .lineLimit(1)
                    } else if expense.isTimeEnabled {
                        Text(expense.date.format(.timeOnly))
                            .font(.caption)
                    }
                }
            }
            Spacer()
            Text(expense.amount.toCurrency).foregroundStyle(Color.expenseFontColor(amount: expense.amount))
                .font(.headline)
        }
    }
    
    func amountEmoji() -> String {
        if expense.amount <= 200 {
            "🤑"
        } else if expense.amount > 200 && expense.amount <= 500  {
            "🤔"
        } else if expense.amount > 500 && expense.amount < 1000  {
            "😨"
        } else {
            "🥶"
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Expense.self, configurations: config)
        let example = Expense.previewItem
        
        return ExpenseItemView(expense: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }

}
