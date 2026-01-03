//
//  CreateBudgetScreen+ViewModel.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

extension CreateBudgetScreen {
    @Observable
    class ViewModel {
        var fromDate: Date = .today
        var toDate: Date = .today
        var expectedIncome: Decimal?
        
        func create() {
            
        }
    }
}
