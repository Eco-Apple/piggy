//
//  CreateBudgetScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

struct CreateBudgetScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    Button("Save", action: viewModel.create)
                }
            }
            .navigationTitle("Create budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
    }
}

#Preview {
    CreateBudgetScreen()
}
