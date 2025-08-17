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
        struct Player: Content {
            let name: String
            let id: String
            let points: Int
        }
        
        let players: [Player] // first ten
        let position: Int? // current player place
        let points: Int? // current player points
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
        let playerName: String
        let challengeId: String
        let points: Int
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
            route.get("day-rating", use: dayRating)
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
    
    @Sendable private func dayRating(req: Request) async throws -> PlayerRatingResponse {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
        
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        var day: Int? = req.parameters.get("day")
        if day == nil {
            day = try await req.application.getDayNumber()
        }
        
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year!)
            .filter(\.$day == day!)
            .first() else { throw Abort(.badRequest) }
        
        let topTen = try await DayChamp.query(on: req.db)
            .filter(\.$challenge.$id == challenge.requireID())
            .sort(\.$points, .descending)
            .with(\.$player)
            .limit(10)
            .all()
            .compactMap { PlayerRatingResponse.Player(name: $0.player.id?.uuidString ?? "", id: $0.player.name, points: $0.points) }

        if let (position, points) = try? await dayPosition(by: id, challenge: challenge.requireID().uuidString, req: req) {
            return PlayerRatingResponse(players: topTen, position: position, points: points)
        } else {
            return PlayerRatingResponse(players: topTen, position: nil, points: nil)
        }
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
    
    @Sendable private func dayPosition(by playerId: String, challenge: String, req: Request) async throws -> (Int, Int) {
        guard let sql = req.db as? SQLDatabase else {
            throw Abort(.internalServerError, reason: "Database doesn't support raw SQL")
        }
                
        let query = """
        SELECT position, points FROM (
            SELECT 
                player_id,
                points, 
                ROW_NUMBER() OVER (ORDER BY points DESC) as position
            FROM DayChamp dc
            JOIN SolitaireChallenge c ON dc.challenge_id = c.id
            WHERE ic.id = \(challenge)
        ) ranked_results
        WHERE player_id = \(playerId)
        """
        
        struct RankingPosition: Decodable {
            let position: Int
            let points: Int
        }
        
        let row = try await sql.raw(SQLQueryString(query))
            .first(decoding: RankingPosition.self)
        
        guard let row = row else {
            throw Abort(.notFound, reason: "Could not determine ranking for player")
        }
        
        return (row.position, row.points)
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
        
        guard let playerId = UUID(uuidString: request.playerId), let challengeId = UUID(uuidString: request.challengeId)
        else { return HTTPStatus.badRequest }
        
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$id == challengeId)
            .first() else { return HTTPStatus.badRequest }
        
        // save new players, if needed
        let player = try await createOrUpdatePlayer(
            playerId:  playerId,
            playerName: request.playerName,
            on: req
        )
        
        // save result
        try await createOrUpdateDayChamp(
            player: player,
            challenge: challenge,
            points: request.points,
            on: req
        )
        
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
    
    // MARK: helpers
    
    @Sendable private func createOrUpdatePlayer(playerId: UUID, playerName: String, on req: Request) async throws -> SolitairePlayer {
        if let player = try await SolitairePlayer.query(on: req.db)
            .filter(\.$id == playerId)
            .first() {
            player.name = playerName
            try await  player.save(on: req.db)
            return player
        } else {
            let player = SolitairePlayer(
                id: playerId,
                name: playerName
            )
            try await  player.save(on: req.db)
            return player
        }
    }
    
    @Sendable private func createOrUpdateDayChamp(
        player: SolitairePlayer,
        challenge: SolitaireChallenge,
        points: Int,
        on req: Request
    ) async throws {
        let dayChamp = try await DayChamp.query(on: req.db)
            .filter(\.$challenge.$id == challenge.requireID())
            .filter(\.$player.$id == player.requireID())
            .first()
        ?? DayChamp(player: player, challenge: challenge, points: points)
        
        dayChamp.points = points
        
        try await dayChamp.save(on: req.db)
    }
}


/*

1) Проверка, что место работает
2) Кэширование таблицы лидеров дня
3) Таблица лидеров недели
4) Кэширование таблици лидеров недели
6) UI для просмотра
7) через gpt сделать на реакте, что бы был токен
8) кэщирование игры дня
9) job на переключение игры дня
10) добавить таблицу в UI
11) скрины и описание
12) онбординг, что появился новая механика
13) общие тесты
14) обновить сервер + тесты
15) подготовить сборку и отправить на ревью
 
*/
