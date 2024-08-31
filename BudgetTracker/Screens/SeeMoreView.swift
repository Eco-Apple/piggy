//
//  SeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/30/24.
//

import SwiftUI

struct SeeMoreView: View {
    var date: Date
    var expenses: [Expense]
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                NavigationLink(value: NavigationRoute.expense(.detail(expense))) {
                    ExpensListItemView(expense: expense)
                }
            }
        }
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
}

#Preview {
    SeeMoreView(date: .now, expenses: [Expense.previewItem])
}
