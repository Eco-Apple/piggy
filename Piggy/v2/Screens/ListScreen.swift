//
//  ListScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

struct ListScreen: View {
    @State private var viewModel: ViewModel
    
    init(item: BudgetItem) {
        _viewModel = State(initialValue: .init(item: item))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header:
                            VStack {
                    Text("500,000.00")
                        .font(.system(size: 35, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text("of 100,000,000")
                        .font(.title2)
                }
                    .frame(maxWidth: .infinity, alignment: .center)
                ) {}
                
                SectionView()
                SectionView()
            }
            .navigationTitle(viewModel.item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        viewModel.showAdd = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAdd) {
                AddScreen()
            }
        }
    }
}

private struct SectionView: View {
    var body: some View {
        Section("August 21, 2025") {
            ItemView()
            ItemView()
            ItemView()
        }
    }
}

private struct ItemView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Paycheck 1")
                    .font(.body)
            }
            Spacer()
            
            Text("P20,000")
                .font(.body)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    ListScreen(item: .example)
}
