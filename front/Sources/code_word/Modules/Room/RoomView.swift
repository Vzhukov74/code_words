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
    
    @State var isLoading: Bool = true
    @State var state: GState?
    
    private var isLeader: Bool {
        guard let state else { return false }

        return state.teams[0].leader?.id == vm.user.id ||
        state.teams[1].leader?.id == vm.user.id
    }
    
    private var canSelect: Bool {
        guard let state else { return false }
        guard state.phase == .red ||  state.phase == .blue else { return false }
        
        return state.teams[0].players.contains(where: { $0.id == vm.user.id }) || state.teams[1].players.contains(where: { $0.id == vm.user.id })
    }
    
    // MARK: UI
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TeamsBgColors()
                    .ignoresSafeArea(.all)
                    .frame(height: 100)
                Spacer()
            }
            content
        }.onAppear { prepare() }
    }
    
    private var content: some View {
        Group {
            if isLoading {
                VStack(alignment: HorizontalAlignment.center, spacing: CGFloat(16)) {
                    ProgressView()
                    Text("Подключаемся...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
                    .frame(maxHeight: CGFloat.infinity)
            } else {
                if state != nil {
                    gameView(state!)
                } else {
                    Text("Ошибка...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
            }
        }
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
    
    @ViewBuilder
    private func gameView(_ state: GState) -> some View {
        switch state.phase {
        case .idle:
            gameIdle(state)
        case .endBlue, .endRed:
            Text("123")
        case .redLeader, .red, .blueLeader, .blue:
            game(state)
        }
    }
    
    private func gameIdle(_ state: GState) -> some View {
        VStack(spacing: 0) {
            headerView
            RoomGameIdle(
                state: state,
                isHost: true,
                onShareGame: {},
                onStartGame: vm.startGame,
                onBecameRedLeader: vm.onBecameRedLeader,
                onBecameBlueLeader: vm.onBecameBlueLeader,
                onJoinRed: vm.onJoinRed,
                onJoinBlue: vm.onJoinBlue
            )
        }
    }
    
    private func game(_ state: GState) -> some View {
        VStack(spacing: 0) {
            headerView
            TeamsStaticView(
                state: state
            )
            hintInput(state)
            Spacer()
            GameWordsView(
                words: state.words,
                isOpen: isLeader,
                canSelect: canSelect,
                onSelect: vm.onSelect(_:)
            )
                .padding(.horizontal, 8)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func hintInput(_ state: GState) -> some View {
        if (state.phase == .redLeader || state.phase == .blueLeader), isLeader {
            LeaderHitnInputView(vm: vm.leaderHitnInputVM)
                .padding(.horizontal, 8)
        } else {
            EmptyView()
        }
    }
    
    // MARK: Functions
    
    private func prepare() {
        isLoading = true
        Task { @MainActor in
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
        case start(String)
        case joinTeam(String)
        case becameTeamLeader(String)
        case selectWord(String)
        case writeDownWord(String, String)
        case endTurn
        case restart
        
        var cmd: String {
            switch self {
            case let .start(dictionary): return "start:\(dictionary)"
            case let .joinTeam(team): return "joinTeam:\(team)"
            case let .becameTeamLeader(team): return "becameTeamLeader:\(team)"
            case let .selectWord(wordIndex): return "selectWord:\(wordIndex)"
            case let .writeDownWord(word, number): return "writeDownWord:\(word):\(number)"
            case .endTurn: return "endTurn"
            case .restart: return "restart"
            }
        }
        
        init?(rawValue: String) {
            let split = rawValue.split(separator: ":")
            guard split.count > 0 else { return nil }
            
            let cmdStr = String(split[0])
            let data1: String? = split.count >= 2 ? String(split[1]) : nil
            let data2: String? = split.count >= 3 ? String(split[1]) : nil
            
            switch cmdStr {
            case "start":
                guard let data1 else { return nil }
                self = .start(data1)
            case "joinTeam":
                guard let data1 else { return nil }
                self = .joinTeam(data1)
            case "becameTeamLeader":
                guard let data1 else { return nil }
                self = .becameTeamLeader(data1)
            case "selectWord":
                guard let data1 else { return nil }
                self = .selectWord(data1)
            case "writeDownWord":
                guard let data1, let data2 else { return nil }
                self = .writeDownWord(data1, data2)
            case "endTurn":
                self = .endTurn
            case "restart":
                self = .restart
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
        socketService.send(msg: Cmd.start("temp").cmd)
    }
    
    func onBecameRedLeader() {
        socketService.send(msg: Cmd.becameTeamLeader("red").cmd)
    }

    func onJoinRed() {
        socketService.send(msg: Cmd.joinTeam("red").cmd)
    }

    func onBecameBlueLeader() {
        socketService.send(msg: Cmd.becameTeamLeader("blue").cmd)
    }

    func onJoinBlue() {
        socketService.send(msg: Cmd.joinTeam("blue").cmd)
    }
    
    func selectWord(wordIndex: String) {
        socketService.send(msg: Cmd.selectWord(wordIndex).cmd)
    }
    
    func writeDownWord(word: String, number: Int) {
        socketService.send(msg: Cmd.writeDownWord(word, "\(number)").cmd)
    }
    
    func onEndTurn() {
        socketService.send(msg: Cmd.endTurn.cmd)
    }
    
    private func onReceive(_ msg: String) {

    }
    
    private func onReceive(_ data: Data) {
        guard let newState = try? JSONDecoder().decode(GState.self, from: data) else { return }
        onCmd(newState)
    }
}
