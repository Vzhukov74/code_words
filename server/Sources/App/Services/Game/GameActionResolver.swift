//
//  GameActionResolver.swift
//  code_word_server
//
//  Created by Владислав Жуков on 13.11.2024.
//

struct GameActionResolver {
    
    let state: Game.State
    let userId: String
    let hostId: String
    
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
        guard hostId == userId else { return nil }
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
                return state
            }
        case .blueLeader:
            if state.blueTeamLeader?.id == userId {
                state.phase = .blue
                state.blueLeaderWords.append(Game.LeaderWord(word: word, number: number))
                return state
            }
        default:
            return nil
        }
        
        return nil
    }
}
