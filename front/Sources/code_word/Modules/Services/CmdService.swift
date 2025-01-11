//
//  CmdService.swift
//  project-name
//
//  Created by Vladislav Zhukov on 11.01.2025.
//

import Foundation

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
