//
//  HomeScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/31/25.
//

import SwiftUI

struct HomeScreen: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("August", destination: BudgetScreen())
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Create", systemImage:"plus") {
                        viewModel.showCreateBudget = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateBudget) {
                CreateBudgetScreen()
            }
        }
    }
}

#Preview {
    HomeScreen()
}
