//
//  RoomViewModel.swift
//  project-name
//
//  Created by Владислав Жуков on 30.09.2024.
//

import SwiftUI

final class RoomViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var state: State?
    @Published var hasWordInput: Bool = false
    @Published var leaderText: String = ""
    @Published var leaderNumber: Int?
    
    private let network: Network
    private let cmdService: CmdService
    private let roomId: String
    private let user: User
    
    init(network: Network, cmdService: CmdService, roomId: String, user: User) {
        self.network = network
        self.cmdService = cmdService
        self.roomId = roomId
        self.user = user
    }

    func start() {
        isLoading = true
        Task { @MainActor in
            state = try? await network.game(by: roomId)
            cmdService.start(gameId: roomId, userId: user.id) { [weak self] newState in
                Task { @MainActor in
                    guard let self else { return }
                    if newState.phase == .redLeader || newState.phase == .blueLeader {
                        if newState.readTeamLeader?.id == self.user.id || newState.blueTeamLeader?.id == self.user.id {
                            self.hasWordInput = true
                        }
                    } else {
                        self.hasWordInput = false
                        self.leaderText = ""
                    }
                    
                    self.state = newState
                }
            }
            isLoading = false
        }
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
    
    func onSelectNumber(_ number: Int) {
        leaderNumber = number
    }
    
    func onEndOfTurn() {

    }
    
    func onHint() {
        cmdService.writeDownWord(word: leaderText)
    }
}
