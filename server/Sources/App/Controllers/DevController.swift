//
//  DevController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 06.01.2025.
//

import Vapor

actor DevController: RouteCollection {
    
    nonisolated func boot(routes: any RoutesBuilder) throws {
        let dev = routes.grouped("api", "dev", "games")
        
        dev.get("add", ":id", use: addPlayer)
        dev.get("add", "red", "leader", ":id", use: addRedLeader)
        dev.get("add", "blue", "leader", ":id", use: addBlueLeader)
        dev.get("write", "word", ":id", use: writeWord)
        dev.get("select", "word", ":id", use: selectWord)
    }
    
    @Sendable private func addPlayer(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        let player = Game.Player(
            id: UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: ""),
            name: "DevPlayer \(Int.random(in: (0...10)))",
            icon: Int.random(in: (0...10))
        )
        
        _ = try await req.application.gameService.join(gameId: id, player: player)
        
        return HTTPStatus.ok
    }
    
    @Sendable private func addRedLeader(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        let playerId = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let player = Game.Player(
            id: playerId,
            name: "DevPlayer \(Int.random(in: (0...10)))",
            icon: Int.random(in: (0...10))
        )
        
        _ = try await req.application.gameService.join(gameId: id, player: player)
        
        guard let cmd = Cmd(rawValue: "becameTeamLeader:red") else { return HTTPStatus.badRequest }
        let state = try await req.application.gameService.game(by: id)
        guard let newState = GameActionResolver(state: state, userId: playerId, hostId: id).resolve(cmd: cmd)
        else {
            return HTTPStatus.badRequest
        }
        await req.application.gameService.newStateFor(gameId: id, newState: newState)
        
        return HTTPStatus.ok
    }
    
    @Sendable private func addBlueLeader(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        let playerId = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        let player = Game.Player(
            id: playerId,
            name: "DevPlayer \(Int.random(in: (0...10)))",
            icon: Int.random(in: (0...10))
        )
        
        _ = try await req.application.gameService.join(gameId: id, player: player)
        
        guard let cmd = Cmd(rawValue: "becameTeamLeader:blue") else { return HTTPStatus.badRequest }
        let state = try await req.application.gameService.game(by: id)
        guard let newState = GameActionResolver(state: state, userId: playerId, hostId: id).resolve(cmd: cmd)
        else {
            return HTTPStatus.badRequest
        }
        await req.application.gameService.newStateFor(gameId: id, newState: newState)
        
        return HTTPStatus.ok
    }
    
    @Sendable private func writeWord(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        guard let playerId: String = req.query["player"] else {
            throw Abort(.badRequest)
        }
                
        guard let cmd = Cmd(rawValue: "writeDownWord:blue:1") else { return HTTPStatus.badRequest }
        let state = try await req.application.gameService.game(by: id)
        guard let newState = GameActionResolver(state: state, userId: playerId, hostId: id).resolve(cmd: cmd)
        else {
            return HTTPStatus.badRequest
        }
        await req.application.gameService.newStateFor(gameId: id, newState: newState)
        
        return HTTPStatus.ok
    }
    
    @Sendable private func selectWord(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        guard let playerId: String = req.query["player"] else {
            throw Abort(.badRequest)
        }
        guard let index: String = req.query["index"] else {
            throw Abort(.badRequest)
        }
                
        guard let cmd = Cmd(rawValue: "selectWord:\(index)") else { return HTTPStatus.badRequest }
        let state = try await req.application.gameService.game(by: id)
        guard let newState = GameActionResolver(state: state, userId: playerId, hostId: id).resolve(cmd: cmd)
        else {
            return HTTPStatus.badRequest
        }
        await req.application.gameService.newStateFor(gameId: id, newState: newState)
        
        return HTTPStatus.ok
    }
}
