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
                    HStack {
                        DatePicker("From", selection: $viewModel.fromDate, in: ...Date(), displayedComponents: .date)
                        
                        DatePicker("To", selection: $viewModel.toDate, in: ...Date(), displayedComponents: .date)
                    }
                }
                
                Section("Expected Income") {
                    CurrencyField("eg. \(Cons.curr)20,000.00", value: $viewModel.expectedIncome)
                }
                
                Section("Expenses") {
                    InfoTextView(label: "Essential:", currency: $viewModel.essential, placeholder: "eg. \(Cons.curr)10,000.00")
                    InfoTextView(label: "Non-Essential:", currency: $viewModel.nonEssential, placeholder: "eg. \(Cons.curr)6,000.00")
                    InfoTextView(label: "Savings:", currency: $viewModel.saving, placeholder: "eg. \(Cons.curr)4,000.00")
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
