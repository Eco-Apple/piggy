//
//  BudgetScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/31/25.
//

import SwiftUI

struct BudgetScreen: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: viewModel.columns, spacing: 15) {
                    ForEach(viewModel.items) { item in
                        NavigationLink(destination: ListScreen(item: item)) {
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

private struct BudgetCard: View {
    let item: BudgetItem
    
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
