//
//  MainViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
        
    private let navigation: Navigation
    private let network: Network
    
    init(navigation: Navigation, network: Network) {
        self.navigation = navigation
        self.network = network
    }
    
    func createRoom(with user: User) async throws -> String {
        try await network.createRoom(with: user)
    }
    
    func hasGame(id: String) async -> Bool {
        do {
            _ = try await network.game(by: id)
            return true
        } catch {
            return false
        }
    }
    
    func joinToRoom(id: String, with user: User) {
        DI.shared.roomId = id
        DI.shared.user = user
        Task { @MainActor in
            navigation.joinToRoom()
        }
    }
    
    func configureUser() {
        navigation.onUserConfiguration()
    }
}
