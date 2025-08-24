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

struct LeaderboardResponse: Content {
    let year: Int
    let week: Int
    let players: [PlayerScore]
    
    struct PlayerScore: Content {
        let name: String
        let points: Int
    }
}

actor SolitairePlayerController: RouteCollection {
    
    struct PlayerRatingResponse: Content {
        struct Player: Content {
            let name: String
            let id: String
            let points: Int
        }
        struct PlayerPosition: Content {
            let position: Int
            let points: Int
        }
        
        let players: [Player] // first ten
        let position: PlayerPosition?
    }
    
    struct RankResult: Decodable {
        let rank: Int
    }
    
    struct UpdateRatingRequest: Content {
        let playerId: String
        let playerName: String
        let challengeId: String
        let points: Int
    }
    
    nonisolated func boot(routes: any RoutesBuilder) throws {
        routes.group("solitaire", "player") { route in
            route.post("rating", use: updateRating)
            
            route.get("day-rating", ":id", use: dayRating)
            route.get("week-rating", ":id", use: weekRating)
        }
    }
    
    // MARK: public routes

    @Sendable private func updateRating(req: Request) async throws -> HTTPStatus {
        let request = try req.content.decode(UpdateRatingRequest.self)
        
        guard let playerId = UUID(uuidString: request.playerId), let challengeId = UUID(uuidString: request.challengeId)
        else { return HTTPStatus.badRequest }
        
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$id == challengeId)
            .first() else { return HTTPStatus.badRequest }
        
        // save new players, if needed
        let player = try await SolitairePlayer.createOrUpdate(
            playerId:  playerId,
            playerName: request.playerName,
            on: req.db
        )
        
        // save result
        let weekChamp = try await WeekChamp.createOrUpdate(
            player: player,
            week: req.application.getWeekNumber(),
            year: req.application.getYearNumber(),
            on: req.db
        )

        let dayChamp = try await DayChamp.createOrUpdate(
            player: player,
            challenge: challenge,
            weekChamp: weekChamp,
            points: request.points,
            on: req.db
        )
        
        let topTen = try await req.application.cacheService.getDayLeaders() ?? []
        if topTen.isEmpty || (topTen.last?.points ?? 0) < dayChamp.points {
            try await updateAndCacheDayRating(day: challenge.day, year: challenge.year, req: req)
        }
        
        return .ok
    }

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
        
        let topTen = try await req.application.cacheService.getDayLeaders()?.compactMap {
            PlayerRatingResponse.Player(name: $0.name, id: $0.id.uuidString, points: $0.points)
        } ?? []

        let position = try? await dayPosition(by: id, challenge: challenge.requireID().uuidString, req: req)
        
        return PlayerRatingResponse(players: topTen, position: position)
    }

    @Sendable private func weekRating(req: Request) async throws -> PlayerRatingResponse {
        guard let id = req.parameters.get("id") else { throw Abort(.badRequest) }
        
        var year: Int? = req.parameters.get("year")
        if year == nil {
            year = try await req.application.getYearNumber()
        }
        
        let week = try await req.application.getPreviousWeekNumber()

        
        let topTen = try await req.application.cacheService.getWeekLeaders()?
            .compactMap { PlayerRatingResponse.Player(name: $0.name, id: $0.id.uuidString, points: $0.points) } ?? []

        let position = try? await weekPosition(by: id, year: year!, week: week, req: req)
        
        return PlayerRatingResponse(players: topTen, position: position)
    }

    // MARK: helpers
    @Sendable private func dayPosition(by playerId: String, challenge: String, req: Request) async throws -> PlayerRatingResponse.PlayerPosition {
        guard let playerResult = try await DayChamp.query(on: req.db)
            .filter(\.$challenge.$id == UUID(uuidString: challenge)!)
            .filter(\.$player.$id == UUID(uuidString: playerId)!)
            .first() else { throw Abort(.badRequest) }
        
        let position = try await DayChamp.query(on: req.db)
            .filter(\.$challenge.$id == UUID(uuidString: challenge)!)
            .filter(\.$points > playerResult.points)
            .count()
        
        return PlayerRatingResponse.PlayerPosition(position: position + 1, points: playerResult.points)
    }
    
    @Sendable private func weekPosition(by playerId: String, year: Int, week: Int, req: Request) async throws -> PlayerRatingResponse.PlayerPosition {
        guard let playerResult = try await WeekChamp.query(on: req.db)
            .filter(\.$player.$id == UUID(uuidString: playerId)!)
            .filter(\.$year == year)
            .filter(\.$week == week)
            .first() else { throw Abort(.badRequest) }
        
        let position = try await WeekChamp.query(on: req.db)
            .filter(\.$year == year)
            .filter(\.$week == week)
            .filter(\.$points > playerResult.points)
            .count()
        
        return PlayerRatingResponse.PlayerPosition(position: position + 1, points: playerResult.points)
    }
    
    @Sendable private func updateAndCacheDayRating(day: Int, year: Int, req: Request) async throws {
        guard let challenge = try await SolitaireChallenge.query(on: req.db)
            .filter(\.$year == year)
            .filter(\.$day == day)
            .first() else { throw Abort(.badRequest) }
        
        let topTen = try await DayChamp.query(on: req.db)
            .filter(\.$challenge.$id == challenge.requireID())
            .sort(\.$points, .descending)
            .with(\.$player)
            .limit(10)
            .all()
            .compactMap { try? LeaderResult(id: $0.player.requireID(), name: $0.player.name, points: $0.points) }
        
        try await req.application.cacheService.cacheDayLeaders(topTen)
    }
}


/*

1) Проверка, что место работает +
1.1) Добавить кнопку для добавления дня в неделю и перепроверить все таблицы +
3) Таблица лидеров недели +
9) job на переключение игры дня +

4) Кэширование таблици лидеров недели +
2) Кэширование таблицы лидеров дня +
8) кэщирование игры дня +
20) отрицательная неделя +
19) проверить (?)

10) добавить таблицу в UI
11) скрины и описание
12) онбординг, что появился новая механика

15) подготовить сборку и отправить на ревью
 
13) общие тесты
14) обновить сервер + тесты
 
 6) UI для просмотра
 7) через gpt сделать на реакте, что бы был токен
*/
