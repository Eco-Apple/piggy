//
//  EmptyMessageView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/13/24.
//

import SwiftUI

struct EmptyMessageView: View {
    let title: String
    let message: String
    
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "tray.fill")
        } description: {
            Text(message)
        }
    }
}

#Preview {
    EmptyMessageView(title: "No Expense", message: "New expenses you added will appear here.")
}
