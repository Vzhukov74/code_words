//
//  Game.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

final class Game {
    let id: String
    let host: Player
    
    var state: State
    var links: [String: WebSocketContext] = [:]
    
    init(id: String, host: Player, state: State) {
        self.id = id
        self.host = host
        self.state = state
    }
    
    func join(player: Player) {
        state.grayTeam.append(player)
    }
    
    func isPlaying(player id: String) -> Bool {
        state.allPlayers.contains { $0.id == id }
    }
    
    func setContext(_ context: WebSocketContext, forPlayer id: String) {
        links[id] = context
    }
}

extension Game {
    struct State: Content {
        let id: String
        let hostId: String
        var readTeamLeader: Player?
        var blueTeamLeader: Player?
        var redTeam: [Player]
        var blueTeam: [Player] = []
        var grayTeam: [Player] = []
        
        var words: [Word] = []
        
        init(id: String, host: Player, words: [Word]) {
            self.id = id
            self.redTeam = [host]
            self.words = words
            self.hostId = host.id
        }
    }
    
    struct Player: Content {
        let id: String
        let name: String
    }
    
    struct Word: Content {
        let word: String
        let color: Int
        var isOpen: Bool
        var elections: [Player]
    }
}

extension Game.State {
    var allPlayers: [Game.Player] {
        var players = blueTeam
        players.append(contentsOf: redTeam)
        players.append(contentsOf: grayTeam)
        if let blueTeamLeader {
            players.append(blueTeamLeader)
        }
        if let readTeamLeader {
            players.append(readTeamLeader)
        }
        
        return players
    }
}
