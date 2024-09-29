//
//  File.swift
//  
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

struct MainNavigationView: View {
    
    @StateObject var navigation: Navigation
    
    var body: some View {
        NavigationStack(path: $navigation.path) {
            MainView(vm: DI.shared.mainViewModel())
                .navigationDestination(for: Navigation.Destination.self) { destination in
                    switch destination {
                    case .createNewRoom:
                        NewRoomConfiuratorView(vm: DI.shared.newRoomConfiuratorViewModel())
                            .toolbar(Visibility.hidden, for: ToolbarPlacement.navigationBar)
                    case .joinToRoom:
                        RoomView()
                            .toolbar(Visibility.hidden, for: ToolbarPlacement.navigationBar)
                    case .userConfiguration:
                        UserConfiuratorView(navigation: navigation)
                            .toolbar(Visibility.hidden, for: ToolbarPlacement.navigationBar)
                    }
                }
        }
    }
}
