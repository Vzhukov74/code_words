//
//  IGameService.swift
//
//
//  Created by Владислав Жуков on 22.08.2024.
//

import Vapor

protocol IGameService: Sendable {
    func add(game: Game, on req: Request) throws -> EventLoopFuture<Void>
    func join(gameId: String, player: Game.Player, on req: Request) throws -> EventLoopFuture<Void>
    func game(by id: String, on req: Request) throws -> EventLoopFuture<Game.State>
    
    func connect(to gameId: String, playerId: String, ws: WebSocket, on req: Request) throws -> EventLoopFuture<Void>
    
    func games(on req: Request) throws -> EventLoopFuture<[String]>
    func players(gameId: String, on req: Request) throws -> EventLoopFuture<[Game.Player]>
}

// MARK: - Storage
struct GameServiceKey: StorageKey {
    typealias Value = IGameService
}

extension Application {
    var gameService: IGameService {
        get {
            self.storage[GameServiceKey.self]!
        }
        set {
            self.storage[GameServiceKey.self] = newValue
        }
    }
}
