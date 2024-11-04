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
    
//    private func startGame() {
//        //send(msg: Cmd.start.cmd)
//    }
//    
//    private func joun(team: Team) {
//        send(msg: CmdService.Cmd.joinTeam(vm.user.id, team.rawValue).cmd)
//    }
//    
////    func becameTeamLeader(team: Team) {
////        send(msg: Cmd.becameTeamLeader(userId, team.rawValue).cmd)
////    }
////    
////    func selectWord(wordId: String) {
////        send(msg: Cmd.selectWord(userId, wordId).cmd)
////    }
////    
////    func writeDownWord(word: String, number: Int) {
////        send(msg: Cmd.writeDownWord(word, "\(number)").cmd)
////    }
//    
//    private func onReceive(_ msg: String) {
//
//    }
//    
//    private func onReceive(_ data: Data) {
//        logger.info("onReceivenewState")
//        guard let newState = try? JSONDecoder().decode(GState.self, from: data) else { return }
//        //onCmd(newState)
//    }
//    
//#if !SKIP
//private let baseUrl = URL(string: "http://127.0.0.1:8080/socket/connect")!
//#else
//private let baseUrl = URL(string: "http://10.0.2.2:8080/socket/connect")!
//#endif
//    
//    //private let baseUrl = URL(string: "http://127.0.0.1:8080/socket/connect")!
//    private var webSocketTask: URLSessionWebSocketTask?
//    
//    mutating func connect(to gameId: String, userId: String) {
//        let url = baseUrl.appendingPathComponent("\(gameId)/\(userId)")
//        let request = URLRequest(url: url)
//        
//        webSocketTask = URLSession.shared.webSocketTask(with: request)
//        //self.onReceive = onReceive
//        webSocketTask!.resume()
//        receive()
//    }
//    
//    func disconnect() {
//        webSocketTask?.cancel()
//    }
//    
//    func send(msg: String) {
//        Task {
//            logger.info("webSocketTask")
//            //logger.info("\(webSocketTask!.state)")
//            logger.info("\(webSocketTask!.error)")
//            
//            try await webSocketTask!.send(URLSessionWebSocketTask.Message.string(msg))
//        }
//    }
//    
//    private func receive() {
//        Task {
//            let result = try? await webSocketTask?.receive()
//            logger.info("result 22" )
//            if result != nil {
//                switch result {
//                case let .string(msg):
//                    print(msg)
//                case let .data(data):
//                    self.onReceive(data)
//                default: break
//                }
//            }
//            receive()
//        }
//    }
}

final class CmdService {
    enum Cmd {
        case start
        case joinTeam(String, String)
        case becameTeamLeader(String, String)
        case selectWord(String, String)
        case writeDownWord(String, String)
        
        var cmd: String {
            switch self {
            case .start: return "start:temp:temp"
            case let .joinTeam(user, team): return "joinTeam:\(user):\(team)"
            case let .becameTeamLeader(user, team): return "becameTeamLeader:\(user):\(team)"
            case let .selectWord(user, wordId): return "selectWord:\(user):\(wordId)"
            case let .writeDownWord(user, word): return "writeDownWord:\(user):\(word)"
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
                self = .start
            case "joinTeam":
                self = .joinTeam(String(userId), String(data))
            case "becameTeamLeader":
                self = .becameTeamLeader(String(userId), String(data))
            case "selectWord":
                self = .selectWord(String(userId), String(data))
            case "writeDownWord":
                self = .writeDownWord(String(userId), String(data))
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
        socketService.send(msg: Cmd.start.cmd)
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
