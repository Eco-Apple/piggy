//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI

struct ExpenseView: View {
    var expenseItem: ExpenseItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expenseItem.reasonForExpense)
                    .font(.headline)
                Text(expenseItem.createdDate.formattedDate)
                    .font(.caption)
            }
            Spacer()
            Text(expenseItem.amount, format: .currency(code: "PHP")).foregroundStyle(.red)
                .font(.headline)
        }
    }
    
    init(_ expenseItem: ExpenseItem) {
        self.expenseItem = expenseItem
    }
}

#Preview {
    ExpenseView(ExpenseItem(amount: 40, reasonForExpense: "Test", createdDate: Date(), updateDate: Date()))
}
