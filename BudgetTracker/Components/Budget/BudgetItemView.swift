//
//  BudgetListItemView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct BudgetItemView: View {
    var budget: Budget
    
    var body: some View {
        HStack {
            Text(amountEmoji())
                .font(.title)
            VStack(alignment: .leading) {
                Text(budget.title)
                     .font(.headline)
                if budget.isTimeEnabled {
                    Text("@" + budget.date!.format(.timeOnly))
                        .font(.caption)
                }
            }
            Spacer()
//            Text("+ \(budget.estimatedAmount, format: .currency(code: "PHP"))").foregroundStyle(amountForegroundColor())
//                .font(.headline) // TODO: Budget total item
        }
    }
    
    func amountEmoji() -> String {
        return "💰"
//        if true {estimatedAmount
////        if budget.estimatedAmount <= 100 { TODO: Emoji
//            "👍"
//        } else if budget.estimatedAmount > 100 && budget.estimatedAmount <= 300  {
//            "👌"
//        } else if budget.estimatedAmount > 300 && budget.estimatedAmount < 500  {
//            "💰"
//        } else {
//            "🔥"
//        }
    }
    
    func amountForegroundColor() -> Color {
        return .green
//        if true{
////        if budget.estimatedAmount <= 200 { TODO: Emoji
//            Color.green
//        } else if budget.estimatedAmount > 200 && budget.estimatedAmount <= 500  {
//            Color.orange
//        } else if budget.estimatedAmount > 500 && budget.estimatedAmount < 1000  {
//            Color.purple
//        } else {
//            Color.red
//        }
    }

}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Budget.self, configurations: config)
        let example = Budget.previewItem
        
        return BudgetItemView(budget: example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }

}
