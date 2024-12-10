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
    
    func createAndJoinRoom(with user: User) async throws {
        let roomId = try await network.createRoom(with: user)
        DI.shared.roomId = roomId
        DI.shared.user = user
        
        joinToRoom(id: roomId, with: user)
    }
    
    func joinToRoom(id: String, with user: User) {
        DI.shared.roomId = id
        DI.shared.user = user
        navigation.joinToRoom()
    }
    
    func configureUser() {
        navigation.onUserConfiguration()
    }
}
