//
//  GameController..swift
//
//
//  Created by Владислав Жуков on 27.08.2024.
//

import Vapor

final class GameController: RouteCollection {
        
    private struct JoinRequest: Content {
        let gameId: String
        let player: Game.Player
    }
    
    struct GameCreateResult: Content {
        let id: String
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let games = routes.grouped("api", "games")
        
        games.post("create", use: create)
        games.post("join", use: join)

        games.get("game", ":id", use: game)
        
        let socket = routes.grouped("socket")
        socket.webSocket("connect", ":gameId", ":playerId", onUpgrade: socketHandler)
    }
    
    private func create(req: Request) async throws -> GameCreateResult {
        let host = try req.content.decode(Game.Player.self, as: .json)
        let id = "newgame"//UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let state = Game.State(id: id)
        let game = Game(id: id, hostId: host.id, state: state)
        
        try await req.application.gameService.add(game: game)
        
        return GameCreateResult(id: id)
    }
    
    private func game(req: Request) async throws -> Game.State {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        return try await req.application.gameService.game(by: id)
    }
        
    private func join(req: Request) async throws -> Game.State {
        let join = try req.content.decode(JoinRequest.self, as: .json)
        
        return try await req.application.gameService.join(gameId: join.gameId, player: join.player)
    }
    
    private func socketHandler(_ req: Request, _ ws: WebSocket) async {
       guard let gameId = req.parameters.get("gameId"),
             let playerId = req.parameters.get("playerId") else {
           _ = try? await ws.close(code: .protocolError)
           return
       }
       
       do {
           _ = try await req.application.gameService.connect(to: gameId, playerId: playerId, ws: ws, on: req)
       } catch {
           ws.send(error: .unknownError(error), fromUser: playerId)
           _ = try? await ws.close(code: .unexpectedServerError)
       }
    }
}
