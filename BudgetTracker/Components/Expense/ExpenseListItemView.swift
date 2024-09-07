//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftData
import SwiftUI

struct ExpensListItemView: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading) {
                Text(expense.title)
                     .font(.headline)
                Text("@" + expense.createdDate.format(.timeOnly))
                    .font(.caption)
            }
            Spacer()
            Text(expense.amount, format: .currency(code: "PHP")).foregroundStyle(amountForegroundColor())
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
    
    func amountForegroundColor() -> Color {
        if expense.amount <= 200 {
            Color.green
        } else if expense.amount > 200 && expense.amount <= 500  {
            Color.orange
        } else if expense.amount > 500 && expense.amount < 1000  {
            Color.purple
        } else {
            Color.red
        }
    }

}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Expense.self, configurations: config)
        let example = Expense.previewItem
        
        return ExpensListItemView(expense: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }

}
