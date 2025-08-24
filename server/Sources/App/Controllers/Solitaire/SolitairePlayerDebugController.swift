//
//  SolitairePlayerDebugController.swift
//  code_word_server
//
//  Created by Vladislav Zhukov on 18.08.2025.
//

import Foundation
@preconcurrency import Vapor
import FluentKit
import FluentSQL
import FluentSQLiteDriver

actor SolitairePlayerDebugController: RouteCollection {
    
    struct RatingViewContext: Encodable {
        let year: Int
        let day: Int
        var players: [PlayerRanking]
        
        struct PlayerRanking: Encodable {
            let name: String
            let points: Int
        }
    }
        
    nonisolated func boot(routes: any RoutesBuilder) throws {
        routes.group("solitaire", "player", "api") { route in
            // api
            route.post("test-data", "generate", use: fillWithTestData)
            route.post("test-data", "add-day-champ", use: addDayChampToCurrentWeek)
            
            // web page
            route.get("day-rating", use: showDayRating)
            route.get("week-rating", use: showWeekRating)
        }
    }
    
    @Sendable private func fillWithTestData(req: Request) async throws -> HTTPStatus {
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        var day: Int? = req.parameters.get("day")
        if day == nil {
            day = try await req.application.getDayNumber()
        }
        
        let playerCount = 16
        
        // find or create day challenge
        let challenge = SolitaireChallenge(
            value: "♦3|♠︎5♠︎1|♥︎8♣3♣4|♥︎7♣8♣K♠︎8|♠︎7♦4♦1♣6♣1|♣Q♥︎J♣A♠︎9♥︎Q♠︎6|♣2♦2♠︎4♥︎3♥︎K♦9♦K|♦Q♦6♦7♠︎K♠︎Q♥︎4♦J♠︎2♥︎9♥︎A♣J♥︎5♠︎A♠︎J♥︎6♦8♦5♣9♣7♥︎2♠︎3♥︎1♦A♣5|",
            year: year!,
            day: day!
        )
        try await challenge.save(on: req.db)
        
        var players: [SolitairePlayer] = []
        for index in 0..<playerCount {
            let playerName = "Player \(index)"
            let player = try await SolitairePlayer.query(on: req.db)
                .filter(\.$name == playerName)
                .first()
            ?? SolitairePlayer(name: playerName)
            
            try await player.save(on: req.db)
            
            players.append(player)
        }

        for player in players {
            let weekChamp = try await WeekChamp.createOrUpdate(
                player: player,
                week: req.application.getWeekNumber(),
                year: year!,
                on: req.db
            )
            _ = try await DayChamp.createOrUpdate(
                player: player,
                challenge: challenge,
                weekChamp: weekChamp,
                points: Int.random(in: 500...1500),
                on: req.db
            )
        }
        
        req.application.logger.info("fill bd with test data for one week/day champ")
        
        return .ok
    }
    
    @Sendable private func addDayChampToCurrentWeek(req: Request) async throws -> HTTPStatus {
        let year = try await req.application.getYearNumber()
        let week = try await req.application.getWeekNumber()

        let players = try await SolitairePlayer.query(on: req.db).all()
        
        guard !players.isEmpty else { return .badRequest }
        
        guard let lastChamp = try await WeekChamp.query(on: req.db)
            .filter(\.$player.$id == players.first!.requireID())
            .filter(\.$year == year)
            .filter(\.$week == week)
            .with(\.$dayChamps)
            .first()?.dayChamps.last else { return .badRequest }
        
        guard let lastDay = try await DayChamp.query(on: req.db)
            .filter(\.$id == lastChamp.requireID())
            .with(\.$challenge)
            .first()?.challenge.day else { return .badRequest }
        
        let day = lastDay + 1
        
        let challenge = SolitaireChallenge(
            value: "♦3|♠︎5♠︎1|♥︎8♣3♣4|♥︎7♣8♣K♠︎8|♠︎7♦4♦1♣6♣1|♣Q♥︎J♣A♠︎9♥︎Q♠︎6|♣2♦2♠︎4♥︎3♥︎K♦9♦K|♦Q♦6♦7♠︎K♠︎Q♥︎4♦J♠︎2♥︎9♥︎A♣J♥︎5♠︎A♠︎J♥︎6♦8♦5♣9♣7♥︎2♠︎3♥︎1♦A♣5|",
            year: year,
            day: day
        )
        try await challenge.save(on: req.db)
        
        for player in players {
            if let weekChamp = try await WeekChamp.query(on: req.db)
                .filter(\.$player.$id == player.requireID())
                .filter(\.$year == year)
                .filter(\.$week == week)
                .first() {
                _ = try await DayChamp.createOrUpdate(
                    player: player,
                    challenge: challenge,
                    weekChamp: weekChamp,
                    points: Int.random(in: 500...1200),
                    on: req.db
                )
                req.application.logger.info("create day champ for player: \(player.name)")
            } else {
                req.application.logger.info("fail to create day champ for player: \(player.name)")
            }
        }
        
        req.application.logger.info("fill bd with test data add to current week champ on day champ")
        
        return .ok
    }
    
    @Sendable private func showDayRating(req: Request) async throws -> View {
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        var day: Int? = req.parameters.get("day")
        if day == nil {
            day = try await req.application.getDayNumber()
        }
        
        var rating = RatingViewContext(year: year!, day: day!, players: [])
        
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year!)
            .filter(\.$day == day!)
            .first() else { return try await req.view.render("leaderboard", rating) }
        
        let results = try await DayChamp.query(on: req.db)
            .filter(\.$challenge.$id == challenge.requireID())
            .sort(\.$points, .descending)
            .with(\.$player)
            .all()
            .compactMap { result -> RatingViewContext.PlayerRanking in
                return RatingViewContext.PlayerRanking(
                    name: result.player.name,
                    points: result.points
                )
            }
        rating.players = results
        
        return try await req.view.render("leaderboard", rating)
    }
    
    @Sendable private func showWeekRating(req: Request) async throws -> View {
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        var week: Int? = req.parameters.get("week")
        if week == nil {
            week = try await req.application.getWeekNumber()
        }
        
        var rating = RatingViewContext(year: year!, day: week!, players: [])
                
        let results = try await WeekChamp.query(on: req.db)
            .filter(\.$year == year!)
            .filter(\.$week == week!)
            .sort(\.$points, .descending)
            .with(\.$player)
            .all()
            .compactMap { result -> RatingViewContext.PlayerRanking in
                let id = try? result.player.requireID().uuidString
                return RatingViewContext.PlayerRanking(
                    name: id ?? "",
                    points: result.points
                )
            }
        rating.players = results
        
        return try await req.view.render("week_rating_view", rating)
    }
}
