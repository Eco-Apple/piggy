//
//  SeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/30/24.
//

import SwiftUI

struct ExpenseSeeMoreView: View {
    var date: Date
    var expenses: [Expense]
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                NavigationLink(value: NavigationRoute.expense(.detail(expense))) {
                    ExpensItemView(expense: expense)
                }
            }
        }
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
}

#Preview {
    ExpenseSeeMoreView(date: .now, expenses: [Expense.previewItem])
}
