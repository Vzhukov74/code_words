//
//  Game.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//


import Vapor

final class Game: Sendable {
    let id: String
    let host: Player
    
    private let lock = Lock()
    
    private var _state: State
    private var _links: [String: WebSocketContext]
    
    private(set) var state: State {
        get { _state }
        set {
            lock.lock()
            _state = newValue
            lock.unlock()
        }
    }
    
    private(set) var links: [String: WebSocketContext] {
        get { _links }
        set {
            lock.lock()
            _links = newValue
            lock.unlock()
        }
    }
    
    init(id: String, host: Player, state: State) {
        self.id = id
        self.host = host
        self._state = state
        self._links = [:]
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
    
    func new(state: State) {
        self.state = state
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
        let hostId: String
        var readTeamLeader: Player?
        var blueTeamLeader: Player?
        var redTeam: [Player]
        var blueTeam: [Player] = []
        var grayTeam: [Player] = []
        var phase: Phase = .idle
        
        var redLeaderWords: [LeaderWord] = []
        var blueLeaderWords: [LeaderWord] = []
        
        var words: [Word] = []
        
        init(id: String, host: Player) {
            self.id = id
            self.redTeam = [host]
            self.hostId = host.id
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
