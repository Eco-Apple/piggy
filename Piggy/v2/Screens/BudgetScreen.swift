//
//  BudgetScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/31/25.
//

import SwiftUI

struct BudgetScreen: View {
    @State private var viewModel = ViewModel()
    
    let items = [100,200,300,400,500,600]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(items, id: \.self) { item in
                        NavigationLink(destination: ListScreen()) {
                            BudgetCard(number: item)
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
    let number: Int
    
    var body: some View {
        VStack {
            Text("Total Income")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
            
            Spacer()
            
            Text("P73,000")
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.blue)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    BudgetScreen()
}
