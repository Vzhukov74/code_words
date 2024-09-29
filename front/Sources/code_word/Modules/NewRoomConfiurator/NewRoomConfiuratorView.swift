//
//  NewRoomConfiuratorView.swift
//
//
//  Created by Владислав Жуков on 29.08.2024.
//

import SwiftUI

final class NewRoomConfiuratorViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var error: String = ""
    
    private let navigation: Navigation
    private let network: Network
    
    private let user: User
    private var roomId: String?
    
    init(navigation: Navigation, network: Network, user: User) {
        self.navigation = navigation
        self.network = network
        self.user = user
    }
    
    func create() {
        isLoading = true
        Task { @MainActor in
            do {
                self.roomId = try await network.createRoom(with: user)
                DI.shared.roomId = roomId
                navigation.joinToRoom()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
}

struct NewRoomConfiuratorView: View {
    
    @StateObject var vm: NewRoomConfiuratorViewModel
    
    var body: some View {
        VStack {
            Spacer()
            if !vm.error.isEmpty {
                Text(vm.error)
            }
            Button(action: vm.create) {
                Text("Создать игру")
            }
            .disabled(vm.isLoading)
            .padding(.bottom, 32)
        }
    }
}
