//
//  RoomViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 30.09.2024.
//

import SwiftUI

final class RoomViewModel: ObservableObject {
        
    let leaderHitnInputVM: LeaderHitnInputViewModel
    
    private let network: Network
    private let cmdService: CmdService
    private let roomId: String
    private let user: User
    
    private var onNewState: ((GState) -> Void)?
    
    init(network: Network, cmdService: CmdService, roomId: String, user: User) {
        self.network = network
        self.cmdService = cmdService
        self.roomId = roomId
        self.user = user
        self.leaderHitnInputVM = LeaderHitnInputViewModel(cmdService: cmdService)
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
        cmdService.becameTeamLeader(team: .red)
    }

    func onJoinRed() {
        cmdService.joun(team: .red)
    }

    func onBecameBlueLeader() {
        cmdService.becameTeamLeader(team: .blue)
    }

    func onJoinBlue() {
        cmdService.joun(team: .blue)
    }

    func onSelect(_ word: Word) {
        cmdService.selectWord(wordId: word.word)
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
