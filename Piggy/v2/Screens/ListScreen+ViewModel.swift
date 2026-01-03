//
//  ListScreen+ViewModel.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/14/25.
//

import SwiftUI

extension ListScreen {
    @Observable
    class ViewModel {
        var showAdd: Bool
        let item: BudgetItem
        
        init(showAdd: Bool = false, item: BudgetItem) {
            self.showAdd = showAdd
            self.item = item
        }
    }
}
