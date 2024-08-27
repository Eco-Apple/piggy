//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI

struct ExpensListItemView: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading) {
                Text(expense.name)
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
    ExpensListItemView(expense: Expense(name: "Test", desc: "...", amount: 40, createdDate: Date(), updateDate: Date()))
}
