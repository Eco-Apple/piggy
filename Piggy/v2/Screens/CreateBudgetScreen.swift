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
                    DatePicker("From", selection: $viewModel.fromDate, in: ...Date(), displayedComponents: .date)
                    
                    DatePicker("To", selection: $viewModel.toDate, in: ...Date(), displayedComponents: .date)
                    
                    CurrencyField("Expected salary", value: $viewModel.expectedIncome)
                }
                
                Section {
                    InfoTextView(label: "Essential (40%):", currency: 100.00)
                    InfoTextView(label: "Non-Essential (40%):", currency: 100.00)
                    InfoTextView(label: "Savings (40%):", currency: 100.00)
                }
                
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
