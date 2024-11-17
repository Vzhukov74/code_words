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
}

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
        case let .writeDownWord(word, number): return "writeDownWord:\(word):\(number)"
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
