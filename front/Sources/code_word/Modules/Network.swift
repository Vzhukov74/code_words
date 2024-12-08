//
//  File.swift
//  
//
//  Created by Владислав Жуков on 29.08.2024.
//

import Foundation

struct Result: Codable {
    let id: String
}

struct Request: Codable {
    let gameId: String
    let player: User
}

struct GState: Codable {
    let id: String

    var phase: Phase = .idle
    
    var teams: [Team] = [Team(), Team()] // red = 0, blue = 1
    var words: [Word] = []
    
    init(id: String) {
        self.id = id
    }
}

struct Team: Codable {
    var countWords: Int = 0
    var openWords: Int = 0
    var leader: Player?
    var players: [Player] = []
    var words: [Hint] = []
    var votes: [Vote] = []
    var endTurn: [Player] = []
}

struct Vote: Codable {
    let playerId: String
    let wordIndex: Int
}

struct Hint: Codable {
    let word: String
    let number: Int
    var numberOfOpenWords: Int
}

struct Player: Codable, Hashable {
    let id: String
    let name: String
    let icon: Int?
}

enum Phase: String, Codable {
    case idle
    case redLeader
    case red
    case blueLeader
    case blue
    case endRed
    case endBlue
}

enum WColor: Int, Codable {
    case gray
    case red
    case blue
    case black
}

struct Word: Codable, Hashable {
    let id: Int
    let word: String
    let color: WColor
    var isOpen: Bool = false
}

final class Network {
    
    #if !SKIP
    private let baseUrl = URL(string: "http://127.0.0.1:8080/")!
    #else
    private let baseUrl = URL(string: "http://192.168.31.236:8080/")!
    #endif
    
    /// return game id
    func createRoom(with host: User) async throws -> String {
        let body = try JSONEncoder().encode(host)
        let path = "api/games/create"
        
        let url = baseUrl.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(Result.self, from: data).id
    }
    
    /// join to selected game room
    func joinToRoom(id: String, with user: User) async throws -> GState {
        let body = try JSONEncoder().encode(Request(gameId: id, player: user))
        let path = "api/games/join"
        
        let url = baseUrl.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(GState.self, from: data)
    }
    
    func game(by id: String) async throws -> GState {
        let path = "api/games/game"
        
        var url = baseUrl.appendingPathComponent(path)
        url = url.appendingPathComponent(id)
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return try JSONDecoder().decode(GState.self, from: data)
    }
}

/*
 Skip does not support type declarations within functions. Consider making this an independent type
 func createRoom(with host: User) async throws -> String {
     struct Result: Codable {
         let id: String
     }
 */
