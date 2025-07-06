//
//  HomeView+Functions.swift
//  Piggy
//
//  Created by Jerico Villaraza on 7/6/25.
//

import SwiftUI

extension HomeView {    
    func processStartOfTheWeek() {
        if expenseFirstDayOfWeek == "" {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            
            let weekday = calendar.component(.weekday, from: .today)
            let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
            
            let monday = calendar.date(byAdding: .day, value: daysToMonday, to: .today)!.startOfDay
            
            let dateString = isoFormatter.string(from: monday)
            
            expenseFirstDayOfWeek = dateString
        } else {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            let date = isoFormatter.date(from: expenseFirstDayOfWeek)!.startOfDay
            
            let components = calendar.dateComponents([.day], from: date, to: .today)
            
            if let daysAhead = components.day, daysAhead >= 7 {
                totalWeekExpenses = "0.0"
                isWeekExpenseEmpty = true
                
                let dateString = isoFormatter.string(from: .today)
                expenseFirstDayOfWeek = dateString
            }
        }
        
        if incomeFirstDayOfWeek == "" {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            
            let weekday = calendar.component(.weekday, from: .today)
            let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
            
            let monday = calendar.date(byAdding: .day, value: daysToMonday, to: .today)!.startOfDay
            
            let dateString = isoFormatter.string(from: monday)
            
            incomeFirstDayOfWeek = dateString
        } else {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            let date = isoFormatter.date(from: incomeFirstDayOfWeek)!.startOfDay
            
            let components = calendar.dateComponents([.day], from: date, to: .today)
            
            if let daysAhead = components.day, daysAhead >= 7 {
                totalWeekIncomes = "0.0"
                isWeekExpenseEmpty = true
                
                let dateString = isoFormatter.string(from: .today)
                incomeFirstDayOfWeek = dateString
            }
        }
    }
}
