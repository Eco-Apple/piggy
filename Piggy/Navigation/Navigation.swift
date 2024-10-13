//
//  Navigation.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/31/24.
//

import SwiftUI


struct NavigateAction {
    typealias Action = (NavigationRoute) -> ()
    let action: Action
    func callAsFunction(_ route: NavigationRoute){
        action(route)
    }
}

struct NavigateEnvironmentKey: EnvironmentKey {
    static var defaultValue: NavigateAction = NavigateAction(action: {_ in})
}

extension EnvironmentValues {
    var navigate: (NavigateAction) {
        get { self[NavigateEnvironmentKey.self] }
        set { self[NavigateEnvironmentKey.self] = newValue }
    }
}


struct Navigation<Content: View>: View {
    
    @State private var router = NavigationRouter()
    
    let content : Content
    
    init(@ViewBuilder content: () -> Content) {
       self.content = content()
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: NavigationRoute.self) { route in
                    router.destination(for: route)
                }
        }
        .environment(\.navigate, NavigateAction(action: { route in
            router.path.append(route)
        }))
    }
}

