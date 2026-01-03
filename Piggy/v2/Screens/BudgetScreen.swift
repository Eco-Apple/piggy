//
//  BudgetScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/31/25.
//

import SwiftUI

struct BudgetScreen: View {
    @State private var viewModel = ViewModel()
    
    let titles = ["Income", "Essentials", "Non-Essentials", "Savings", "Total Expenses", "Extra"]
    
    let items: [BudgetListItem] = [
        .init(title: "Income", amount: 100, icon: "creditcard"),
        .init(title: "Essentials", amount: 200, icon: "basket"),
        .init(title: "Non-Essentials", amount: 300, icon: "gamecontroller"),
        .init(title: "Savings", amount: 400, icon: "wallet.bifold"),
        .init(title: "Total Expenses", amount: 500, icon: "cart"),
        .init(title: "Extra", amount: 600, icon: "heart")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(items) { item in
                        NavigationLink(destination: ListScreen()) {
                            BudgetCard(item: item)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("August")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BudgetListItem: Identifiable {
    let id = UUID()
    let title: String
    var amount: Decimal
    let icon: String
}

private struct BudgetCard: View {
    let item: BudgetListItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 31, height: 31)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Text("\(item.amount)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text(item.title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.top, 5)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.top, 2)
        .padding(.horizontal, 2)
        .shadow(radius: 2)
    }
}

#Preview {
    BudgetScreen()
}
