//
//  Game.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//


import Vapor

struct WebSocketContext {
    let webSocket: WebSocket
    let request: Request
}

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
        if _state.teams[0].players.count > _state.teams[1].players.count {
            _state.teams[1].players.append(player)
        } else {
            _state.teams[0].players.append(player)
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

        var phase: Phase = .idle
        
        var teams: [Team] = [Team(), Team()] // red = 0, blue = 1
        var words: [Word] = []
        
        init(id: String) {
            self.id = id
        }
    }
    
    struct Team: Content {
        var countWords: Int = 0
        var openWords: Int = 0
        var leader: Player?
        var players: [Player] = []
        var words: [Hint] = []
        var votes: [Vote] = []
        
        var allPlayers: [Player] {
            var all: [Player] = leader != nil ? [leader!] : []
            all.append(contentsOf: players)
            
            return all
        }
    }
    
    struct Vote: Content {
        let playerId: String
        let wordIndex: Int
    }
    
    struct Hint: Content {
        let word: String
        let number: Int
        var numberOfOpenWords: Int
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
        
        var index: Int? {
            switch self {
            case .red:
                return 0
            case .blue:
                return 1
            case .gray:
                return 2
            case .black:
                return 3
            }
        }
    }
    
    struct Word: Content {
        let id: Int
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
        case endRed
        case endBlue
        
        var teamIndex: Int? {
            switch self {
            case .red, .redLeader:
                return 0
            case .blue, .blueLeader:
                return 1
            default:
                return nil
            }
        }
    }
}

extension Game.State {
    var allPlayers: [Game.Player] {
        guard teams.count == 2 else { return [] }
        var players = teams[0].allPlayers
        players.append(contentsOf: teams[1].allPlayers)

        return players
    }
}
