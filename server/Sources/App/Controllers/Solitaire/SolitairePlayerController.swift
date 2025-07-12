//
//  SolitairePlayerController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 06.04.2025.
//

import Foundation
@preconcurrency import Vapor
import FluentKit
import FluentSQL
import FluentSQLiteDriver

actor SolitairePlayerController: RouteCollection {
    
    struct PlayerRatingResponse: Content {
        let players: [SolitairePlayer] // first ten
        let position: Int? // current player place
    }
    
    struct RankResult: Decodable {
        let rank: Int
    }
    
    struct LeaderboardResponse: Content {
        let year: Int
        let week: Int
        let players: [PlayerScore]
        
        struct PlayerScore: Content {
            let name: String
            let points: Int
        }
    }
    
    struct UpdateRatingRequest: Content {
        let playerId: String
        let year: Int
        let week: Int
        let points: Int
        let challengeDay: Int
    }
    
    struct LeaderboardViewContext: Encodable {
        let year: Int
        let week: Int
        let players: [PlayerRanking]
        
        struct PlayerRanking: Encodable {
            let position: Int
            let name: String
            let points: Int
        }
    }
        
    nonisolated func boot(routes: any RoutesBuilder) throws {
        routes.group("solitaire", "player") { route in
            route.get("rating", use: rating)
            route.post("rating", use: updateRating)
        }
        
        // MARK: for tests
        routes.group("solitaire", "player", "api") { route in
            route.post("test-data", "generate", use: fillWithTestData)
            route.get("leaderboard", use: leaderBoard)
            route.get("leaderboard", ":year", ":week", use: showLeaderboard)
        }
    }
    
    // MARK: public routes
    
    @Sendable private func rating(req: Request) async throws -> PlayerRatingResponse {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
        
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        var week: Int? = req.parameters.get("week")
        if week == nil {
            week = try await req.application.getDayNumber()
        }
        
        let topTen = try await SolitairePlayerResult.query(on: req.db)
            .filter(\.$year == year!)
            .filter(\.$week == week!)
            .sort(\.$points, .descending)
            .with(\.$player)
            .limit(10)
            .all()
            .compactMap { $0.player }
        
        let position: Int? = try? await position(by: id, year: year!, week: week!, req: req)
        
        return PlayerRatingResponse(players: topTen, position: position)
    }
    
    @Sendable private func playerPosition(req: Request) async throws -> Int {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
        
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        var week: Int? = req.parameters.get("week")
        if week == nil {
            week = try await req.application.getDayNumber()
        }
        
        return try await position(by: id, year: year!, week: week!, req: req)
    }
    
    @Sendable private func position(by id: String, year: Int, week: Int, req: Request) async throws -> Int {
        guard let sql = req.db as? SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database doesn't support raw SQL")
        }
                
        let query = """
        SELECT position FROM (
            SELECT 
                player_id,
                ROW_NUMBER() OVER (ORDER BY points DESC) as position
            FROM solitaire_player_results
            WHERE year = \(year) AND week = \(week)
        ) ranked_results
        WHERE player_id = \(id)
        """
        
        struct RankingPosition: Decodable {
            let position: Int
        }
        
        let row = try await sql.raw(SQLQueryString(query))
            .first(decoding: RankingPosition.self)
        
        guard let row = row else {
            throw Abort(.notFound, reason: "Could not determine ranking for player")
        }
        
        return row.position
    }
    
    @Sendable private func fillWithTestData(req: Request) async throws -> HTTPStatus {
#if DEBUG
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = 2025
        }
        
        var week: Int? = req.parameters.get("week")
        if week == nil {
            week = 25
        }
        
        let playerCount = 16
        
        try await SolitairePlayerResult.query(on: req.db)
            .filter(\.$year == year!)
            .filter(\.$week == week!)
            .delete()
        
        for index in 0..<playerCount {
            let playerName = "Player \(index)"
            
            let player = try await SolitairePlayer.query(on: req.db)
                .filter(\.$name == playerName)
                .first()
            ?? SolitairePlayer(name: playerName)
            
            try await player.save(on: req.db)
            
            let result = SolitairePlayerResult(
                playerID: try player.requireID(),
                year: year!,
                week: week!
            )
            result.points = Int.random(in: 1000...2000)
            
            try await result.save(on: req.db)
        }
        
#endif
        return .ok
    }
    
    @Sendable private func leaderBoard(req: Request) async throws -> LeaderboardResponse {
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = 2025
        }
        
        var week: Int? = req.parameters.get("week")
        if week == nil {
            week = 25
        }
        
        let results = try await SolitairePlayerResult.query(on: req.db)
            .filter(\.$year == year!)
            .filter(\.$week == week!)
            .join(SolitairePlayer.self, on: \SolitairePlayerResult.$player.$id == \SolitairePlayer.$id)
            .sort(\.$points, .descending)
            .all()
            .map { result -> LeaderboardResponse.PlayerScore in
                let player = try result.joined(SolitairePlayer.self)
                return LeaderboardResponse.PlayerScore(
                    name: player.name,
                    points: result.points
                )
            }
        
        return LeaderboardResponse(
            year: year!,
            week: week!,
            players: results
        )
    }
    
    @Sendable private func updateRating(req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(UpdateRatingRequest.self)
        
        let result = try await SolitairePlayerResult.query(on: req.db)
            .filter(\.$player.$id == UUID(uuidString: request.playerId)!)
            .filter(\.$year == request.year)
            .filter(\.$week == request.week)
            .first()
        ?? SolitairePlayerResult(
            playerID: UUID(uuidString: request.playerId)!,
            year: request.year,
            week: request.week
        )
        
        if let existingPoints = result.dayPoints[request.challengeDay] {
            guard request.points > existingPoints else {
                return .ok
            }
        }
        
        result.dayPoints[request.challengeDay] = request.points
        result.points = result.dayPoints.values.reduce(0, +)
        
        try await result.save(on: req.db)
        
        return .ok
    }

    @Sendable private func showLeaderboard(req: Request) async throws -> View {
        guard let year = req.parameters.get("year", as: Int.self),
              let week = req.parameters.get("week", as: Int.self) else {
            throw Abort(.badRequest, reason: "Invalid year or week parameter")
        }
        
        let results = try await leaderBoard(req: req)
                
        let players = results.players.enumerated().compactMap { index in
            LeaderboardViewContext.PlayerRanking(
                position: index.offset + 1,
                name: index.element.name,
                points: index.element.points
            )
        }
        
        let context = LeaderboardViewContext(
            year: year,
            week: week,
            players: players
        )
        
        return try await req.view.render("leaderboard", context)
    }
}
