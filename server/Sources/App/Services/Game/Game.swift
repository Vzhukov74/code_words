//
//  Game.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//


import Vapor

actor Game {
    let id: String
    let hostId: String
    
    private var _state: State
    private var links: [String: WebSocketContext]
        
    init(id: String, hostId: String, state: State) {
        self.id = id
        self.hostId = hostId
        self._state = state
        self.links = [:]
    }
    
    func state() -> State {
        _state
    }
    
    func join(player: Player) {
        if _state.redTeam.count > _state.blueTeam.count {
            _state.blueTeam.append(player)
        } else {
            _state.redTeam.append(player)
        }
    }
    
    func isPlaying(player id: String) -> Bool {
        _state.allPlayers.contains { $0.id == id }
    }
    
    func setContext(_ context: WebSocketContext, forPlayer id: String) {
        links[id] = context
    }
    
    func new(state: State) {
        self._state = state
        if let stateData = try? JSONEncoder().encode(state) {
            links.values.forEach { wsc in
                wsc.webSocket.send(stateData)
            }
        }
    }
}

extension Game {
    struct State: Content {
        let id: String
        var readTeamLeader: Player?
        var blueTeamLeader: Player?
        var redTeam: [Player] = []
        var blueTeam: [Player] = []
        var phase: Phase = .idle
        
        var redLeaderWords: [LeaderWord] = []
        var blueLeaderWords: [LeaderWord] = []
        
        var words: [Word] = []
        
        init(id: String) {
            self.id = id
        }
    }
    
    struct LeaderWord: Content {
        let word: String
        let number: String
    }
    
    struct Player: Content {
        let id: String
        let name: String
        let icon: Int?
    }
    
    enum WColor: Int, Content {
        case gray
        case red
        case blue
        case black
    }
    
    struct Word: Content {
        let word: String
        let color: WColor
        var isOpen: Bool = false
        var elections: [Player] = []
    }
    
    enum Phase: String, Content {
        case idle
        case redLeader
        case red
        case blueLeader
        case blue
        case end
    }
}

extension Game.State {
    var allPlayers: [Game.Player] {
        var players = blueTeam
        players.append(contentsOf: redTeam)
        if let blueTeamLeader {
            players.append(blueTeamLeader)
        }
        if let readTeamLeader {
            players.append(readTeamLeader)
        }

        return players
    }
}
