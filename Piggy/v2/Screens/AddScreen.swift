//
//  AddScreen.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

struct AddScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CurrencyField("eg. 10.00", value: $viewModel.amount)
                    
                    DatePicker(
                        "Date",
                        selection: $viewModel.date,
                        in: ...Date(),
                        displayedComponents: viewModel.isTimeEnabled ? [.date, .hourAndMinute] : .date
                    )
                    
                    Toggle(isOn: $viewModel.isTimeEnabled) {
                        Text("Time")
                    }
                }
                
                Section {
                    Button(action: viewModel.add) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddScreen()
}
