//
//  MainViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 08.10.2024.
//

import SwiftUI
import Combine

final class MainViewModel: ObservableObject {
    
    @Published var user: User?
    
    private let navigation: Navigation
    private let network: Network
    private let userService: IUserService
    private var cancellable = Set<AnyCancellable>()
    
    init(navigation: Navigation, network: Network, userService: IUserService) {
        self.navigation = navigation
        self.userService = userService
        self.network = network
        
        self.user = userService.user
    }
    
    func createRoom() async throws -> String {
        guard let user = userService.user else { return "" }
        
        let roomId = try await network.createRoom(with: user)
        DI.shared.roomId = roomId
        DI.shared.user = user
        
        return roomId
    }
    
    func joinToRoom(id: String) {
        guard let user = DI.shared.user else { return }
        
        DI.shared.roomId = id
        DI.shared.user = user
        navigation.joinToRoom()
    }
    
    func configureUser() {
        navigation.onUserConfiguration()
    }
}
