//
//  RoomView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

public struct RoomView: View {
    @StateObject var vm: RoomViewModel
    
    // MARK: State
    
    @State var isLoading: Bool = false
    @State var state: GState?
    
    // MARK: UI
    
    public var body: some View {
        Group {
            if isLoading {
                VStack(alignment: HorizontalAlignment.center, spacing: CGFloat(16)) {
                    ProgressView()
                    Text("Подключаемся...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
                    .frame(maxHeight: CGFloat.infinity)
            } else {
                if let state = state {
                    gameView(state)
                } else {
                    Text("Ошибка...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
            }
        }.onAppear { prepare() }
    }
    
    private var headerView: some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: { vm.startGame() }) {
                Text("menu")
            }
        }
            .frame(height: 44)
            .padding(.horizontal, 8)
    }
    
    private func gameView(_ state: GState) -> some View {
        VStack(spacing: 0) {
            headerView
            TeamsView(
                state: state, 
                onBecameRedLeader: vm.onBecameRedLeader,
                onJoinRed: vm.onJoinRed,
                onBecameBlueLeader: vm.onBecameBlueLeader,
                onJoinBlue: vm.onJoinBlue
            )
            //if vm.hasWordInput {
                LeaderHitnInputView(vm: vm.leaderHitnInputVM)
            //}
            GameWordsView(words: state.words, canSelect: false, onSelect: vm.onSelect(_:))
            Spacer()
        }
    }
    
    // MARK: Functions
    
    private func prepare() {
        Task { @MainActor in
            isLoading = true
            self.state = try! await vm.start { state in
                Task { @MainActor in
                    self.state = state
                }
            }
            isLoading = false
        }
    }
    
}

final class CmdService {
    enum Cmd {
        case start(String, String)
        case joinTeam(String, String)
        case becameTeamLeader(String, String)
        case selectWord(String, String)
        case writeDownWord(String, String)
        case restart(String, String)
        
        var cmd: String {
            switch self {
            case let .start(user, dictionary): return "start:\(user):\(dictionary)"
            case let .joinTeam(user, team): return "joinTeam:\(user):\(team)"
            case let .becameTeamLeader(user, team): return "becameTeamLeader:\(user):\(team)"
            case let .selectWord(user, wordId): return "selectWord:\(user):\(wordId)"
            case let .writeDownWord(user, word): return "writeDownWord:\(user):\(word)"
            case let .restart(user, _): return "restart:\(user):temp"
            }
        }
        
        init?(rawValue: String) {
            let split = rawValue.split(separator: ":")
            guard split.count == 3 else { return nil }
            
            let cmdStr = split[0]
            let userId = split[1]
            let data = split[2]
            
            switch cmdStr {
            case "start":
                self = .start(String(userId), String(data))
            case "joinTeam":
                self = .joinTeam(String(userId), String(data))
            case "becameTeamLeader":
                self = .becameTeamLeader(String(userId), String(data))
            case "selectWord":
                self = .selectWord(String(userId), String(data))
            case "writeDownWord":
                self = .writeDownWord(String(userId), String(data))
            case "restart":
                self = .restart(String(userId), "temp")
            default:
                return nil
            }
        }
    }
    
    private let socketService: SocketService
    private var userId: String!
    private var onCmd: ((GState) -> Void)!
    
    init(socketService: SocketService) {
        self.socketService = socketService
    }
    
    func start(gameId: String, userId: String, onCmd: @escaping (GState) -> Void) {
        self.userId = userId
        self.onCmd = onCmd
        socketService.connect(to: gameId, userId: userId, onReceive: onReceive)
    }
    
    func startGame() {
        socketService.send(msg: Cmd.start(userId, "temp").cmd)
    }
    
    func joun(team: Team) {
        socketService.send(msg: Cmd.joinTeam(userId, team.rawValue).cmd)
    }
    
    func becameTeamLeader(team: Team) {
        socketService.send(msg: Cmd.becameTeamLeader(userId, team.rawValue).cmd)
    }
    
    func selectWord(wordId: String) {
        socketService.send(msg: Cmd.selectWord(userId, wordId).cmd)
    }
    
    func writeDownWord(word: String, number: Int) {
        socketService.send(msg: Cmd.writeDownWord(word, "\(number)").cmd)
    }
    
    private func onReceive(_ msg: String) {

    }
    
    private func onReceive(_ data: Data) {
        logger.info("onReceive")
        guard let newState = try? JSONDecoder().decode(GState.self, from: data) else { return }
        onCmd(newState)
    }
}
