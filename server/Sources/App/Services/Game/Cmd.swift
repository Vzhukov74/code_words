//
//  Cmd.swift
//  code_word_server
//
//  Created by Владислав Жуков on 13.11.2024.
//

enum Team: String {
    case red
    case blue
    
    init?(rawValue: String) {
        switch rawValue {
        case "red":
            self = .red
        case "blue":
            self = .blue
        default:
            return nil
        }
    }
    
    var teamIndex: Int {
        switch self {
        case .red:
            return 0
        case .blue:
            return 1
        }
    }
    
    var oppositeTeamIndex: Int {
        switch self {
        case .red:
            return 1
        case .blue:
            return 0
        }
    }
}

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
