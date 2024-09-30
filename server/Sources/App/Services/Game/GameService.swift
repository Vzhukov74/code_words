//
//  GameService.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

struct WebSocketContext {
    let webSocket: WebSocket
    let request: Request
}

final class GameService: IGameService {
    private var games: [String: Game] = [:]
    
    func add(game: Game, on req: Request) throws -> EventLoopFuture<Void> {
        self.games[game.id] = game
        return req.eventLoop.makeSucceededFuture(())
    }
    
    func join(gameId: String, player: Game.Player, on req: Request) throws -> EventLoopFuture<Void> {
        self.games[gameId]?.join(player: player)
        return req.eventLoop.makeSucceededFuture(())
    }
    
    func game(by id: String, on req: Request) throws -> EventLoopFuture<Game.State> {
        let game = games[id]!
        return req.eventLoop.makeSucceededFuture(game.state)
    }
    
    func connect(to gameId: String, playerId: String, ws: WebSocket, on req: Request) throws -> EventLoopFuture<Void> {
        guard let game = self.games[gameId] else {
            throw Abort(.badRequest, reason: "game don't exist")
        }
        
        guard game.isPlaying(player: playerId) == true else {
            throw Abort(.forbidden, reason: "Cannot connect to a game you are not a part of")
        }
        
        let wsContext = WebSocketContext(webSocket: ws, request: req)
        games[gameId]?.setContext(wsContext, forPlayer: playerId)

        ws.pingInterval = .seconds(5)
        ws.onText { [unowned self] ws, text in
            
            guard let cmd = Cmd(rawValue: text) else { return }
            guard let game = self.games[gameId] else { return }
            guard let newState = GameActionResolver(state: game.state, userId: playerId).resolve(cmd: cmd) else { return }
            self.games[gameId]?.new(state: newState)
            
            if let newStateData = try? JSONEncoder().encode(newState) {
                ws.send(newStateData)
            }
        }
        _ = ws.onClose.always { [unowned self] _ in
            guard let game = self.games[gameId] else { return }
            //game.state.userDidDisconnect(userId)
            
//            if game.state.host.id == userId {
//                req.eventLoop.scheduleTask(in: .minutes(5)) {
//                    ExpiredGameJob(id: matchId)
//                        .invoke(req.application)
//                }
//            }
        }
        return req.eventLoop.makeSucceededFuture(())
    }
    
    // MARK: helpers
    
    func games(on req: Request) throws -> EventLoopFuture<[String]> {
        req.eventLoop.next().future(Array(games.values).map { $0.id })
    }
    
    func players(gameId: String, on req: Request) throws -> EventLoopFuture<[Game.Player]> {
        if let game = self.games[gameId] {
            var players = game.state.allPlayers
            return req.eventLoop.next().future(players)
        } else {
            return req.eventLoop.next().future([])
        }
    }
}

//protocol GCmd {
//    let cmd: String
//    
//
//}

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
        case let .writeDownWord(word, number): return "writeDownWord:\(word):\(number)"
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

struct GameActionResolver {
    
    let state: Game.State
    let userId: String
    
    func resolve(cmd: Cmd) -> Game.State? {
        var state: Game.State?
        
        switch cmd {
        case .start:
            state = start()
        case let .joinTeam(user, teamStr):
            guard let team = Team(rawValue: teamStr) else { return nil }
            state = joun(team: team, userId: user)
        case let .becameTeamLeader(user, teamStr):
            guard let team = Team(rawValue: teamStr) else { return nil }
            state = becameTeamLeader(team: team, userId: user)
        case let .selectWord(user, wordId):
            state = selectWord(wordId: wordId, userId: user)
        case let .writeDownWord(word, number):
            state = writeDownWord(word: word, number: number)
        }
        
        return state
    }
    
    func start() -> Game.State? {
        guard state.hostId == userId else { return nil }
        guard state.phase == .idle else { return nil }
        
        var state = state
        
        let words = Words.prepareWords()
        let redWords = words.filter({ $0.color == .red }).count
        
        state.words = words
        state.phase = redWords == 9 ? .redLeader : .blueLeader
        
        return state
    }
    
    func joun(team: Team, userId: String) -> Game.State? {
        var state = state

        switch team {
        case .red:
            if let playerIndex = state.blueTeam.firstIndex(where: { $0.id == userId }) {
                let player = state.blueTeam.remove(at: playerIndex)
                state.redTeam.append(player)
                return state
            }
        case .blue:
            if let playerIndex = state.redTeam.firstIndex(where: { $0.id == userId }) {
                let player = state.redTeam.remove(at: playerIndex)
                state.blueTeam.append(player)
                return state
            }
        }
        
        if let playerIndex = state.grayTeam.firstIndex(where: { $0.id == userId }) {
            let player = state.grayTeam.remove(at: playerIndex)
            switch team {
            case .red:
                state.redTeam.append(player)
                return state
            case .blue:
                state.blueTeam.append(player)
                return state
            }
        }
        
        if state.readTeamLeader?.id == userId {
            if let player = state.readTeamLeader {
                state.readTeamLeader = nil
                switch team {
                case .red:
                    state.redTeam.append(player)
                    return state
                case .blue:
                    state.blueTeam.append(player)
                    return state
                }
            }
        }
        
        if state.blueTeamLeader?.id == userId {
            if let player = state.blueTeamLeader {
                state.blueTeamLeader = nil
                switch team {
                case .red:
                    state.redTeam.append(player)
                    return state
                case .blue:
                    state.blueTeam.append(player)
                    return state
                }
            }
        }
        
        return nil
    }
    
    func becameTeamLeader(team: Team, userId: String) -> Game.State? {
        var state = state
        
        switch team {
        case .red:
            guard state.readTeamLeader == nil else { return nil }
        case .blue:
            guard state.blueTeamLeader == nil else { return nil }
        }
        
        if let playerIndex = state.blueTeam.firstIndex(where: { $0.id == userId }) {
            let player = state.blueTeam.remove(at: playerIndex)
            switch team {
            case .red:
                state.readTeamLeader = player
            case .blue:
                state.blueTeamLeader = player
            }
            return state
        }
        
        if let playerIndex = state.redTeam.firstIndex(where: { $0.id == userId }) {
            let player = state.redTeam.remove(at: playerIndex)
            switch team {
            case .red:
                state.readTeamLeader = player
            case .blue:
                state.blueTeamLeader = player
            }
            return state
        }

        
        if let playerIndex = state.grayTeam.firstIndex(where: { $0.id == userId }) {
            let player = state.grayTeam.remove(at: playerIndex)
            switch team {
            case .red:
                state.readTeamLeader = player
            case .blue:
                state.blueTeamLeader = player
            }
            return state
        }
        
        if state.readTeamLeader?.id == userId {
            if let player = state.readTeamLeader {
                state.readTeamLeader = nil
                switch team {
                case .red:
                    state.readTeamLeader = player
                case .blue:
                    state.blueTeamLeader = player
                }
                return state
            }
        }
        
        if state.blueTeamLeader?.id == userId {
            if let player = state.blueTeamLeader {
                state.blueTeamLeader = nil
                switch team {
                case .red:
                    state.readTeamLeader = player
                case .blue:
                    state.blueTeamLeader = player
                }
                return state
            }
        }
        
        return nil
    }
    
    func selectWord(wordId: String, userId: String) -> Game.State? {
        var state = state
        
        var team: [Game.Player] = []
        var player: Game.Player? = nil
        switch state.phase {
        case .red:
            team = state.redTeam
        case .blue:
            team = state.blueTeam
        default:
            return nil
        }
        
        if let playerIndex = team.firstIndex(where: { $0.id == userId }) {
            player = team[playerIndex]
        }
        
        guard player != nil else { return nil }

        if let wordIndex = state.words.firstIndex(where: { $0.elections.contains(where: { $0.id == player!.id }) }) {
            if state.words[wordIndex].word != wordId {
                state.words[wordIndex].elections.removeAll(where: { $0.id == player!.id })
            }
        }
        
        if let wordIndex = state.words.firstIndex(where: { $0.word == wordId }) {
            state.words[wordIndex].elections.append(player!)
            
            if state.words[wordIndex].elections.count == team.count {
                state.words[wordIndex].elections = []
                state.words[wordIndex].isOpen = true
                state.phase = .blue
            }
        }
        
        return state
    }
    
    func writeDownWord(word: String, number: String) -> Game.State? {
        var state = state
        
        switch state.phase {
        case .redLeader:
            if state.readTeamLeader?.id == userId {
                state.phase = .red
                state.redLeaderWords.append(Game.LeaderWord(word: word, number: number))
            }
        case .blueLeader:
            if state.blueTeamLeader?.id == userId {
                state.phase = .blue
                state.blueLeaderWords.append(Game.LeaderWord(word: word, number: number))
            }
        default:
            return nil
        }
        
        return nil
    }
}
