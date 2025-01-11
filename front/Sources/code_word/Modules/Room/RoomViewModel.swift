//
//  RoomViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 30.09.2024.
//

import SwiftUI

final class RoomViewModel: ObservableObject {
        
    let leaderHitnInputVM: LeaderHitnInputViewModel
    
    private let navigation: Navigation
    private let network: Network
    private let cmdService: CmdService
    private let roomId: String
    let user: User
    
    private var onNewState: ((GState) -> Void)?
    
    init(navigation: Navigation, network: Network, cmdService: CmdService, roomId: String, user: User) {
        self.navigation = navigation
        self.network = network
        self.cmdService = cmdService
        self.roomId = roomId
        self.user = user
        self.leaderHitnInputVM = LeaderHitnInputViewModel(cmdService: cmdService)
    }
    
    func onBack() {
        navigation.back()
    }

    func start(onNewState: ((GState) -> Void)?) async throws -> GState {
        let state = try await network.joinToRoom(id: roomId, with: user)
        
        self.onNewState = onNewState
        subscribeOnRoomEvents()
        
        return state
    }
    
    func startGame() {
        cmdService.startGame()
    }
    
    func onBecameRedLeader() {
        cmdService.onBecameRedLeader()
    }

    func onJoinRed() {
        cmdService.onJoinRed()
    }

    func onBecameBlueLeader() {
        cmdService.onBecameBlueLeader()
    }

    func onJoinBlue() {
        cmdService.onJoinBlue()
    }

    func onSelect(_ word: Word) {
        cmdService.selectWord(wordIndex: String(word.id)) // word.id it is word index
    }

    func onEndOfTurn() {

    }
        
    private func subscribeOnRoomEvents() {
        cmdService.start(gameId: roomId, userId: user.id) { [weak self] newState in
            Task { @MainActor in
                self?.onNewState?(newState)
            }
        }
    }
}
