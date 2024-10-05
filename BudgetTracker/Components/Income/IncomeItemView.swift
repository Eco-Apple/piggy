//
//  BudgetListItemView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct IncomeItemView: View {
    var income: Income
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading) {
                Text(income.title)
                     .font(.headline)
                if income.isTimeEnabled {
                    Text("@" + income.date!.format(.timeOnly))
                        .font(.caption)
                }
            }
            Spacer()
            Text(income.amount.toCurrency).foregroundStyle(amountForegroundColor())
                .font(.headline)
        }
    }
    
    func amountEmoji() -> String {
        if income.amount <= 100 {
            "👍"
        } else if income.amount > 100 && income.amount <= 300  {
            "👌"
        } else if income.amount > 300 && income.amount < 500  {
            "💰"
        } else {
            "🔥"
        }
    }
    
    func amountForegroundColor() -> Color {
        if income.amount <= 200 {
            Color.green
        } else if income.amount > 200 && income.amount <= 500  {
            Color.orange
        } else if income.amount > 500 && income.amount < 1000  {
            Color.purple
        } else {
            Color.red
        }
    }

}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Income.self, configurations: config)
        let example = Income.previewItem
        
        return IncomeItemView(income: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }

}
