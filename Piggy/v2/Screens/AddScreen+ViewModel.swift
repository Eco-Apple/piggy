//
//  AddScreen+ViewModel.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

extension AddScreen {
    @Observable
    class ViewModel {
        var amount: Decimal?
        var date: Date = .today
        var isTimeEnabled = false
        
        func add() {
            
        }
    }
}
