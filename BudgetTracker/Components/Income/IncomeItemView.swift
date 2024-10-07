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
    
    var caption: String? = nil
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading, spacing: 1) {
                Text(income.title)
                     .font(.headline)
                if let caption = caption {
                    Text(caption)
                        .font(.caption)
                        .lineLimit(1)
                } else {
                    if income.note.isNotEmpty {
                        Text(income.note)
                            .font(.caption)
                            .lineLimit(1)
                    } else if income.isTimeEnabled {
                        Text(income.date.format(.timeOnly))
                            .font(.caption)
                    }
                }
            }
            Spacer()
            Text(income.amount.toCurrency).foregroundStyle(Color.incomeFontColor(amount: income.amount))
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
