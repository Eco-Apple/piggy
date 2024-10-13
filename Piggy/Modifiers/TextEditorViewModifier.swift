//
//  TextFieldViewModifier.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/5/24.
//

import SwiftUI

fileprivate struct Placeholder: ViewModifier {
    var placeholder: String
    @Binding var text: String
    
    func body(content: Content) -> some View {
        
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                VStack {
                    HStack {
                        Text(placeholder)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }

                    Spacer()
                }
            }
            
            content
                .offset(x: -5, y: -8)
        }
    }
}


extension TextEditor {
    func placeHolder(_ placeHolder: String, text: Binding<String>) -> some View {
        modifier(Placeholder(placeholder: placeHolder, text: text))
    }
}
