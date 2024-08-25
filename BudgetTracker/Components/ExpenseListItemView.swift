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
            VStack(alignment: .leading) {
                Text(expense.name)
                    .font(.headline)
                Text(expense.createdDate.formattedDate)
                    .font(.caption)
            }
            Spacer()
            Text(expense.amount, format: .currency(code: "PHP")).foregroundStyle(.red)
                .font(.headline)
        }
    }
}

#Preview {
    ExpensListItemView(expense: Expense(name: "Test", desc: "...", amount: 40, createdDate: Date(), updateDate: Date()))
}
