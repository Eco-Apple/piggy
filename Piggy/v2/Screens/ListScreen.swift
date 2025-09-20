//
//  ListScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

struct ListScreen: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        HStack {
                            Text("Budget")
                            Spacer()
                            Text("P5,000")
                        }
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("P5,000")
                        }
                    }
                }
                ItemView()
            }
            .navigationTitle("Income")
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

private struct ItemView: View {
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Paycheck 1")
                Text("August 21, 2025")
            }
            Spacer()
            Text("P20,000")
        }
    }
}

#Preview {
    ListScreen()
}
