//
//  RoomView.swift
//
//
//  Created by Владислав Жуков on 19.08.2024.
//

import SwiftUI

final class RoomViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var state: State?
    
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
            isLoading = false
        }
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
    
    func onHint() {}
}

public struct RoomView: View {
    @StateObject var vm = RoomViewModel(network: DI.shared.network, cmdService: CmdService(), roomId: DI.shared.roomId!, user: DI.shared.user!)
    
    public var body: some View {
        Group {
            if vm.isLoading {
                VStack(alignment: HorizontalAlignment.center, spacing: CGFloat(16)) {
                    ProgressView()
                    Text("Подключаемся...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
                    .frame(maxHeight: CGFloat.infinity)
            } else {
                if let state = vm.state {
                    gameView(state)
                } else {
                    Text("Ошибка...")
                        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.center)
                }
            }
        }.onAppear { vm.start() }
    }
    
    private func gameView(_ state: State) -> some View {
        VStack {
            TeamsView(
                state: state, 
                onBecameRedLeader: {},
                onJoinRed: {},
                onBecameBlueLeader: {},
                onJoinBlue: {}
            )
            GameWordsView(words: state.words, canSelect: false, onSelect: { _ in })
            Spacer()
        }
            .padding(.horizontal, 8)
    }
}

struct GameWordsView: View {
    
    let words: [Word]
    let canSelect: Bool
    let onSelect: (Word) -> Void
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40))),
        GridItem(.flexible(minimum: CGFloat(40)))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: CGFloat(8)) {
            ForEach(words, id: \.self) { word in
                wordCard(word)
            }
        }
    }
    
    private func wordCard(_ word: Word) -> some View {
        Text(word.word)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cyan)
            }
            .onTapGesture { onSelect(word) }
    }
}

#Preview {
    RoomView()
}

final class GameEngine {
    
}

enum Team: String {
    case red
    case blue
}

final class CmdService {
    private enum Cmd {
        case jounTeam(String)
        case becameTeamLeader(String)
        case selectWord(String)
        case writeDownWord(String)
        
        var cmd: String {
            switch self {
            case let .jounTeam(team): return "jounTeam:\(team)"
            case let .becameTeamLeader(team): return "becameReadTeamLeader:\(team)"
            case let .selectWord(wordId): return "selectWord:\(wordId)"
            case let .writeDownWord(word): return "writeDownWord:\(word)"
            }
        }
    }
    
    private let socketService = SocketService()
    
    func start(gameId: String, userId: String) {
        socketService.connect(to: gameId, userId: userId, onReceive: onReceive)
    }
    
    func joun(team: Team) {
        socketService.send(msg: Cmd.jounTeam(team.rawValue).cmd)
    }
    
    func becameTeamLeader(team: Team) {
        socketService.send(msg: Cmd.becameTeamLeader(team.rawValue).cmd)
    }
    
    func selectWord(wordId: String) {
        socketService.send(msg: Cmd.selectWord(wordId).cmd)
    }
    
    func writeDownWord(word: String) {
        socketService.send(msg: Cmd.writeDownWord(word).cmd)
    }
    
    private func onReceive(_ msg: String) {
        //let parts = msg.split(separator: ":")
        
        print(msg)
        
        //guard parts.count == 2 else { return }
    }
}

final class SocketService {
    private let baseUrl = URL(string: "http://127.0.0.1:8080/socket/play")!
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var onReceive: ((String) -> Void)?
    
    func connect(to gameId: String, userId: String, onReceive: @escaping (String) -> Void) {
        let url = baseUrl.appendingPathComponent("\(gameId)/\(userId)")
        let request = URLRequest(url: url)
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        self.onReceive = onReceive
        
        receive()
        webSocketTask!.resume()
    }
    
    func send(msg: String) {
        Task {
            try await webSocketTask!.send(URLSessionWebSocketTask.Message.string(msg))
        }
    }
    
    private func receive() {
        Task {
            let result = try? await webSocketTask?.receive()
            if result != nil {
                switch result {
                case let .string(msg):
                    onReceive?(msg)
                default: break
                }
            }
            receive()
        }
    }
}
