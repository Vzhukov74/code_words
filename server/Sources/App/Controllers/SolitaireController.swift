//
//  SolitaireController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 06.04.2025.
//

import Foundation
import Vapor
import FluentKit
import FluentSQL
import FluentSQLiteDriver

actor SolitaireController: RouteCollection {
    
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
    
    struct UploadChallengeRequest: Content {
        let value: String
    }
    
    struct ChallengeResponse: Content {
        let id: UUID
        let value: String
        let year: Int
        let day: Int
    }
    
    struct ChallengesResponse: Content {
        let challenges: [Dto]
        
        struct Dto: Content {
            let value: String
            let day: Int
        }
    }
    
    struct ChallengesViewContext: Encodable {
        let year: Int
        let challenges: [ChallengeView]
        
        struct ChallengeView: Encodable {
            let day: Int
            let text: String
            let isToday: Bool
        }
    }
    
    nonisolated func boot(routes: any RoutesBuilder) throws {
        //        routes.get("solitaire", use: mainPage)
        
        routes.group("solitaire") { route in
            route.get("rating", use: rating)
            route.post("rating", use: updateRating)
            
            route.post("challenge", use: challenge)
            route.post("challenges", use: challenges)
            route.post("challenge", use: uploadChallenge)
            
            // MARK: for tests
            route.get("fill-with-test-data", use: fillWithTestData)
            route.get("leaderboard", use: leaderBoard)
            
            route.get("challenges", ":year", use: showChallengesForYear)
            route.post("api", "test-data", "generate", use: generateTestData)
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
        
        let player = try await SolitairePlayer.find(UUID(uuidString: id)!, on: req.db)
        
        let result = try await SolitairePlayerResult.query(on: req.db)
            .filter(\.$player.$id == UUID(uuidString: id)!)
            .filter(\.$year == year)
            .filter(\.$week == week)
            .first()
        
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
    
    @Sendable private func uploadChallenge(req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(UploadChallengeRequest.self)
        
        let calendar = Calendar.current
        let today = Date()
        var year = calendar.component(.year, from: today)
        var day = calendar.component(.day, from: today)
        
        // Find the latest challenge to determine if we need to increment
        if let latest = try await SolitaireChallenge.query(on: req.db)
            .sort(\.$year, .descending)
            .sort(\.$day, .descending)
            .first() {
            
            day = latest.day + 1
            year = latest.year
            
            let daysInYear = calendar.range(of: .day, in: .year, for: today)!.count
            if day > daysInYear {
                day = 1
                year += 1
            }
        }
        
        // Check if challenge for this day/year already exists
        if try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .filter(\.$day == day)
            .first() != nil {
            throw Abort(.conflict, reason: "Challenge already exists for day \(day), year \(year)")
        }
        
        // Validate challenge text is unique
        if try await SolitaireChallenge.query(on: req.db)
            .filter(\.$value == request.value)
            .first() != nil {
            throw Abort(.conflict, reason: "Challenge text must be unique")
        }
        
        // Create and save new challenge
        let challenge = SolitaireChallenge(value: request.value, year: year, day: day)
        try await challenge.save(on: req.db)
        
        return .ok
    }
    
    @Sendable private func challenge(req: Request) async throws -> ChallengeResponse {
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let day = calendar.component(.day, from: today)
                
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .filter(\.$day == day)
            .first() else {
                throw Abort(.notFound, reason: "No challenge found for today")
            }
        
        return ChallengeResponse(
            id: try challenge.requireID(),
            value: challenge.value,
            year: challenge.year,
            day: challenge.day
        )
    }
    
    @Sendable private func challenges(req: Request) async throws -> ChallengesResponse {
        guard let year = req.parameters.get("year", as: Int.self) else {
            throw Abort(.badRequest, reason: "Invalid year parameter")
        }
                
        let challenges = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .sort(\.$day, .ascending)
            .all()
                
        return ChallengesResponse(
            challenges: challenges.compactMap {
                ChallengesResponse.Dto(
                    value: $0.value,
                    day: $0.day
                )
            }
        )
    }
    
    @Sendable private func showChallengesForYear(req: Request) async throws -> View {
        guard let year = req.parameters.get("year", as: Int.self) else {
            throw Abort(.badRequest, reason: "Invalid year parameter")
        }
        
        // Get current day of year
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        // Get challenges from API
        let challenges = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .sort(\.$day, .ascending)
            .all()
        
        // Prepare view context
        let viewChallenges = challenges.map { challenge in
            ChallengesViewContext.ChallengeView(
                day: challenge.day,
                text: challenge.value,
                isToday: challenge.year == currentYear && challenge.day == currentDay
            )
        }
        
        let context = ChallengesViewContext(
            year: year,
            challenges: viewChallenges
        )
        
        return try await req.view.render("challenges", context)
    }
    
    func generateTestData(req: Request) async throws -> HTTPStatus {
        let year = try req.query.get(Int.self, at: "year")
        let daysInYear = Calendar.current.range(of: .day, in: .year, for: Date())!.count
        
        // Delete existing challenges for this year
        try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .delete()
        
        // Create test challenges for each day
        for day in 1...daysInYear {
            let challengeText = "Challenge for day \(day) of \(year)"
            let challenge = SolitaireChallenge(
                value: challengeText,
                year: year,
                day: day
            )
            try await challenge.save(on: req.db)
        }
        
        return .created
    }
}
